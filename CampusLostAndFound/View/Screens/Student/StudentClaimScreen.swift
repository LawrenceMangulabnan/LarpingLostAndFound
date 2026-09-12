import SwiftUI

struct StudentClaimScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    let item: LostFoundItem
    @State private var appearance = ""
    @State private var contents = ""
    @State private var context = ""
    @State private var submitted = false
    @State private var loading = false
    private var canSubmit: Bool { appearance.count > 3 || contents.count > 3 }
    var body: some View {
        ScrollView {
            if submitted {
                VStack(spacing: 20) {
                    Spacer()
                    Circle().fill(AppColors.greenLight).frame(width: 96, height: 96)
                        .overlay(Image(systemName: "checkmark").font(.system(size: 36, weight: .bold)).foregroundStyle(AppColors.green))
                    Text("Claim Submitted!").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
                    Text("Your claim has been submitted for verification.").foregroundStyle(AppColors.label3)
                    VStack(spacing: 12) {
                        HStack { Text("Claim Status").foregroundStyle(AppColors.label3); Spacer(); StatusBadge(text: "Claim Pending") }
                        HStack { Text("Item").foregroundStyle(AppColors.label3); Spacer(); Text(item.itemName).foregroundStyle(AppColors.label).fontWeight(.medium) }
                    }.padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 18))
                    AppButton(title: "Done") { dismiss() }
                    Spacer()
                }.padding(32)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    if let live = app.items.first(where: { $0.id == item.id }) {
                        HStack(spacing: 12) {
                            ItemPhoto(item: live).frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(live.itemName).font(.system(size: 16, weight: .bold)).foregroundStyle(AppColors.label)
                                Text(live.building).foregroundStyle(AppColors.label3).font(.system(size: 13))
                                StatusBadge(text: app.visualStatusLabel(for: live))
                            }
                        }.padding(12).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("How claiming works").font(.system(size: 14, weight: .bold)).foregroundStyle(AppColors.red)
                        Text("Provide details only the true owner would know. A staff member will verify your claim within 24 hours.").font(.system(size: 13)).foregroundStyle(AppColors.label2)
                    }.padding(16).background(AppColors.redGhost).overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.red.opacity(0.13))).clipShape(RoundedRectangle(cornerRadius: 14))
                    area("Appearance *", "Color, brand, condition, markings…", $appearance)
                    area("Contents / Identifying Details *", "Only the real owner would know this…", $contents)
                    area("How & When You Lost It (optional)", "Context about when/where you lost it…", $context)
                    AppButton(title: loading ? "Submitting…" : "Submit Claim", enabled: canSubmit, loading: loading) {
                        loading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            loading = false
                            if app.submitClaim(item: item, verification: "", appearance: appearance, contents: contents, context: context) {
                                submitted = true
                            }
                        }
                    }
                    Text("By submitting, you confirm you are the rightful owner.").font(.system(size: 12)).foregroundStyle(AppColors.label3).frame(maxWidth: .infinity)
                }.padding(16)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Submit Claim")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func area(_ title: String, _ placeholder: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
            TextField("", text: text, prompt: Text(placeholder).foregroundStyle(AppColors.placeholder), axis: .vertical)
                .foregroundStyle(AppColors.label).lineLimit(3...6)
                .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
