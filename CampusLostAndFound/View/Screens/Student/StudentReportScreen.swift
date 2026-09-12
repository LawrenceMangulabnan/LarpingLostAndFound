import SwiftUI

struct StudentReportScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var draft = ItemDraft()
    @State private var camera = false
    @State private var submitted = false
    @State private var loading = false
    private var progress: Double {
        [draft.photoData != nil, !draft.name.isEmpty, draft.category != nil, !draft.location.isEmpty].filter { $0 }.count.double / 4
    }
    private var ready: Bool {
        draft.name.trimmingCharacters(in: .whitespaces).count > 1 && draft.category != nil && !draft.location.isEmpty && !draft.description.trimmingCharacters(in: .whitespaces).isEmpty && (draft.category != .other || !draft.customCategory.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    var body: some View {
        ScrollView {
            if submitted {
                submittedView
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Report an Item").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                    CapsuleSegment(options: [(ItemType.lost, "🔍  Lost"), (.found, "✋  Found")], value: $draft.type)
                    GeometryReader { geo in
                        Capsule().fill(AppColors.cardHi).overlay(alignment: .leading) {
                            Capsule().fill(AppColors.red).frame(width: geo.size.width * progress)
                        }
                    }.frame(height: 4)
                    ReportPhotoWell(imageData: $draft.photoData, camera: $camera)
                    field("Item Name") {
                        TextField("", text: $draft.name, prompt: Text("e.g. Black leather wallet…").foregroundStyle(AppColors.placeholder))
                            .foregroundStyle(AppColors.label).padding(.horizontal, 16).padding(.vertical, 13)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(ItemCategory.allCases) { category in
                                Button {
                                    draft.category = category
                                    if category != .other { draft.customCategory = "" }
                                } label: {
                                    VStack(spacing: 2) {
                                        Text(category.emoji).font(.system(size: 20))
                                        Text(category.rawValue).font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundStyle(draft.category == category ? .white : AppColors.label)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(draft.category == category ? AppColors.red : AppColors.card)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(draft.category == category ? AppColors.red : AppColors.sep, lineWidth: 1.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }.buttonStyle(.plain)
                            }
                        }
                        if draft.category == .other {
                            field("Custom Category") {
                                TextField("", text: $draft.customCategory, prompt: Text("Enter item category").foregroundStyle(AppColors.placeholder))
                                    .foregroundStyle(AppColors.label).padding(.horizontal, 16).padding(.vertical, 13)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Campus Location").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        Picker("Location", selection: $draft.location) {
                            Text("Select a location…").tag("")
                            ForEach(Campus.locations, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.label)
                        .padding(.horizontal, 12).frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        DatePicker("Date", selection: $draft.date, in: ...Date(), displayedComponents: .date)
                            .labelsHidden().colorScheme(.dark)
                            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    field("Description") {
                        TextField("", text: $draft.description, prompt: Text("Describe the item — color, brand, identifying marks, exact location…").foregroundStyle(AppColors.placeholder), axis: .vertical)
                            .foregroundStyle(AppColors.label).lineLimit(4...8).padding(16)
                    }
                    AppButton(title: loading ? "Submitting…" : "Submit Report", enabled: ready, loading: loading) {
                        guard let category = draft.category else { return }
                        loading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            loading = false
                            if app.addItem(photoData: draft.photoData, itemName: draft.name, category: category, customCategory: draft.customCategory, location: draft.location, date: draft.date, description: draft.description, type: draft.type) {
                                submitted = true
                            }
                        }
                    }
                }
                .padding(16).padding(.bottom, 32)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { draft.type = app.reportPrefillType }
        .sheet(isPresented: $camera) { CameraImagePicker(imageData: $draft.photoData).ignoresSafeArea() }
    }

    private var submittedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Circle().fill(AppColors.greenLight).frame(width: 96, height: 96)
                .overlay(Image(systemName: "checkmark").font(.system(size: 36, weight: .bold)).foregroundStyle(AppColors.green))
            Text("Report Submitted").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
            Text("Your report is awaiting verification by the Lost & Found team.").foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
            HStack {
                Text("Status").foregroundStyle(AppColors.label3)
                Spacer()
                StatusBadge(text: ItemStatus.pending.rawValue)
            }
            .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 18))
            Text("A staff member will review your report within 24 hours.").font(.system(size: 13)).foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
            AppButton(title: "Back to Home") { submitted = false; draft = ItemDraft(); app.openStudent(.home) }
            Button("View My Reports") { submitted = false; draft = ItemDraft(); app.openStudent(.myItems) }
                .font(.system(size: 17, weight: .medium)).foregroundStyle(AppColors.red)
            Spacer()
        }.padding(32)
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
            content().background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private extension Int { var double: Double { Double(self) } }
