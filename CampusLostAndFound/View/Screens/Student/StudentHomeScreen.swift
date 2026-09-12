import SwiftUI

struct StudentHomeScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var search = ""
    private var approved: [LostFoundItem] {
        app.items.filter { $0.status == .approved || ($0.status == .claimed) }.sorted { $0.createdAt > $1.createdAt }
    }
    private var results: [LostFoundItem] {
        approved.filter {
            $0.itemName.localizedCaseInsensitiveContains(search) ||
            $0.displayCategory.localizedCaseInsensitiveContains(search) ||
            $0.description.localizedCaseInsensitiveContains(search)
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Good morning 👋").font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.4))
                            Text(app.currentUser?.fullName ?? "Student").font(.system(size: 24, weight: .black)).foregroundStyle(.white)
                        }
                        Spacer()
                        Button { app.openStudent(.profile) } label: {
                            Text(app.currentUser?.initials ?? "A")
                                .font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(AppColors.red.opacity(0.25))
                                .overlay(Circle().stroke(AppColors.red.opacity(0.4), lineWidth: 1.5))
                                .clipShape(Circle())
                        }
                    }
                    SearchBar(text: $search, placeholder: "Search lost or found items…")
                        .background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 13))
                    if search.count < 1 {
                        HStack(spacing: 12) {
                            reportTile("🔍", "Report Lost Item", "I lost something", .lost)
                            reportTile("✋", "Report Found Item", "I found something", .found)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
                .crimsonHeader()

                if search.count > 1 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(results.count) result\(results.count == 1 ? "" : "s") for \"\(search)\"").font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.label3)
                        if results.isEmpty {
                            EmptyState(emoji: "🔍", title: "No items found", button: "Browse All Items") { search = ""; app.openStudent(.browse) }
                        } else {
                            ForEach(results) { item in
                                NavigationLink { StudentItemDetailScreen(item: item) } label: { ItemCard(item: item, statusLabel: app.visualStatusLabel(for: item)) }.buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                } else {
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            StatCard(title: "Lost Items", value: app.items.filter { $0.type == .lost }.count, color: AppColors.red, bg: AppColors.redLight)
                            Rectangle().fill(AppColors.sep).frame(width: 1, height: 40)
                            StatCard(title: "Found Items", value: app.items.filter { $0.type == .found }.count, color: AppColors.green, bg: AppColors.greenLight)
                            Rectangle().fill(AppColors.sep).frame(width: 1, height: 40)
                            StatCard(title: "Returned", value: app.items.filter { $0.status == .returned }.count, color: AppColors.blue, bg: AppColors.blueLight)
                        }
                        .padding(12)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)
                        .offset(y: -12)

                        section("Categories", action: "See All") { app.openStudent(.browse) } content: {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(ItemCategory.allCases) { category in
                                    Button { app.openBrowse(category: category) } label: {
                                        VStack(spacing: 6) {
                                            Text(category.emoji).font(.system(size: 24))
                                            Text(category.rawValue).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label).multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(AppColors.card)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        section("Recently Reported", action: "See All") { app.openStudent(.browse) } content: {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(approved) { item in
                                        NavigationLink { StudentItemDetailScreen(item: item) } label: {
                                            HorizontalItemCard(item: item, statusLabel: app.visualStatusLabel(for: item))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        section("Active Listings", action: nil, onAction: nil) {
                            VStack(spacing: 10) {
                                ForEach(Array(approved.prefix(3))) { item in
                                    NavigationLink { StudentItemDetailScreen(item: item) } label: { ItemCard(item: item, statusLabel: app.visualStatusLabel(for: item)) }.buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func reportTile(_ emoji: String, _ title: String, _ sub: String, _ type: ItemType) -> some View {
        Button { app.openReport(type) } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(emoji).font(.system(size: 26))
                Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                Text(sub).font(.system(size: 12)).foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.white.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12)))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(_ title: String, action: String?, onAction: (() -> Void)?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).font(.system(size: 17, weight: .bold)).foregroundStyle(AppColors.label)
                Spacer()
                if let action, let onAction { Button(action, action: onAction).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColors.red) }
            }
            content()
        }
        .padding(.horizontal, 16)
    }
}
