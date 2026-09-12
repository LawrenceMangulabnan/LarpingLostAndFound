import SwiftUI
import UIKit

struct StudentItemDetailScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.openURL) private var openURL
    let item: LostFoundItem
    @State private var more = false
    @State private var contact = false
    @State private var flag = false
    @State private var flagReason = ""
    @State private var hours = false
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        ItemPhoto(item: live).frame(height: 240).clipped()
                        LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                        HStack {
                            StatusBadge(text: app.visualStatusLabel(for: live))
                            Spacer()
                            if live.isNew {
                                Text("NEW TODAY").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                    .padding(.horizontal, 10).padding(.vertical, 4).background(AppColors.red).clipShape(Capsule())
                            }
                        }.padding(16)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(live.itemName).font(.system(size: 24, weight: .black)).foregroundStyle(AppColors.label)
                        HStack {
                            Text("Reported by ").foregroundStyle(AppColors.label3) + Text(app.userName(for: live.userID)).foregroundStyle(AppColors.label2).fontWeight(.medium)
                            if app.pendingClaimCount(for: live) > 0 {
                                Text("\(app.pendingClaimCount(for: live)) claims").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.orange)
                                    .padding(.horizontal, 8).padding(.vertical, 2).background(AppColors.orangeLight).clipShape(Capsule())
                            }
                        }.font(.system(size: 14))
                    }.padding(.horizontal, 16)

                    infoCard(live)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        Text(live.description).font(.system(size: 15)).foregroundStyle(AppColors.label2)
                    }
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    if live.type == .found && live.status == .approved && live.userID != app.currentUser?.id && app.currentUser?.role == .student {
                        NavigationLink { StudentClaimScreen(item: live) } label: {
                            Text("🙋 I Think This Is Mine").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 15)
                                .background(AppColors.red).clipShape(RoundedRectangle(cornerRadius: 14))
                        }.padding(.horizontal, 16)
                    }
                    GhostButton(title: "💬 Contact Lost & Found") { contact = true }.padding(.horizontal, 16)
                    Button("🚩 Report this item") { flag = true }
                        .font(.system(size: 14, weight: .medium)).foregroundStyle(AppColors.label3)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 32)
            } else {
                ContentUnavailableView("Report deleted", systemImage: "tray")
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button { app.toggleWatchlist(item) } label: {
                        Image(systemName: app.watchlist.contains(item.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(app.watchlist.contains(item.id) ? AppColors.red : AppColors.label3)
                    }
                    Button { more = true } label: { Image(systemName: "ellipsis") }
                }
            }
        }
        .confirmationDialog("More", isPresented: $more) {
            Button("Share Item") { share() }
            Button("Save to Watchlist") { app.toggleWatchlist(item) }
            Button("Copy Item Link") { UIPasteboard.general.string = app.copyItemLink(item); app.succeed("Item link copied.") }
            Button("Report Inappropriate", role: .destructive) { flag = true }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Contact Lost & Found Office", isPresented: $contact) {
            Button("Call Office") { open(Campus.phone) }
            Button("Send Email") { open(Campus.email) }
            Button("Visit Office Hours") { hours = true }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Lost & Found Office Hours", isPresented: $hours) {
            Button("OK", role: .cancel) {}
        } message: { Text(Campus.hours) }
        .sheet(isPresented: $flag) {
            NavigationStack {
                Form {
                    Text("Flag this item as inappropriate or incorrect. Staff will review it.")
                    TextField("Reason", text: $flagReason, axis: .vertical).lineLimit(3...6)
                    Button("Submit Report") {
                        app.flagItem(item, reason: flagReason); flag = false
                    }
                }
                .navigationTitle("Report this item?")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { flag = false } } }
            }
            .presentationDetents([.medium])
        }
    }

    private func infoCard(_ live: LostFoundItem) -> some View {
        VStack(spacing: 0) {
            row("📂", "Category", live.displayCategory)
            Divider().background(AppColors.sep)
            row("📍", "Location", live.location)
            Divider().background(AppColors.sep)
            row("📅", "Date", live.date.formatted(date: .abbreviated, time: .omitted))
            Divider().background(AppColors.sep)
            row("⏱", "Reported", live.createdAt.formatted(date: .abbreviated, time: .omitted))
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func row(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Text(icon).frame(width: 24)
            Text(label).foregroundStyle(AppColors.label3)
            Spacer()
            Text(value).foregroundStyle(AppColors.label).fontWeight(.medium).multilineTextAlignment(.trailing)
        }
        .font(.system(size: 15))
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private func open(_ value: String) {
        guard let url = URL(string: value) else { return }
        openURL(url) { if !$0 { app.errorMessage = "This device cannot open that contact action." } }
    }

    private func share() {
        let text = "\(item.itemName) — \(item.location) via Campus Lost & Found"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first?.rootViewController?.present(av, animated: true)
    }
}
