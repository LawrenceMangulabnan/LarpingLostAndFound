import SwiftUI

struct StudentBrowseScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var type: String = "all"
    @State private var search = ""
    @State private var category: ItemCategory?
    @State private var location = ""
    @State private var status: ItemStatus?
    @State private var sort: BrowseSort = .newest
    @State private var filters = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Lost & Found").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                    .padding(.horizontal, 16).padding(.top, 16)
                HStack(spacing: 8) {
                    SearchBar(text: $search, placeholder: "Search items…")
                    Button { filters = true } label: {
                        Image(systemName: "line.3.horizontal.decrease").foregroundStyle(AppColors.label)
                            .frame(width: 40, height: 40)
                            .background(AppColors.card)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.sep))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("Filter")
                }
                .padding(.horizontal, 16).padding(.top, 12)
                CapsuleSegment(options: [("all", "All"), ("lost", "Lost"), ("found", "Found")], value: $type)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip("All", on: category == nil) { category = nil }
                        ForEach(ItemCategory.allCases) { item in
                            chip("\(item.emoji) \(item.rawValue)", on: category == item) { category = category == item ? nil : item }
                        }
                    }.padding(.horizontal, 16)
                }
                .padding(.vertical, 10)
                .background(AppColors.card)

                let list = results
                HStack {
                    Text("\(list.count) item\(list.count == 1 ? "" : "s")").font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.label3)
                    Spacer()
                    Button(sort == .newest ? "↓ Newest" : sort == .oldest ? "↑ Oldest" : "A-Z") {
                        sort = sort == .newest ? .oldest : sort == .oldest ? .nameAZ : .newest
                    }.font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColors.red)
                }
                .padding(.horizontal, 16).padding(.top, 14)

                if list.isEmpty {
                    EmptyState(emoji: "🔍", title: "No items found", button: "Clear Filters", action: clear)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(list) { item in
                            NavigationLink { StudentItemDetailScreen(item: item) } label: {
                                ItemCard(item: item, statusLabel: app.visualStatusLabel(for: item))
                            }.buttonStyle(.plain)
                        }
                    }.padding(16)
                }
            }
            .padding(.bottom, 24)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !app.browseSearch.isEmpty { search = app.browseSearch; app.browseSearch = "" }
            if let preset = app.browseCategory { category = preset; app.browseCategory = nil }
        }
        .sheet(isPresented: $filters) {
            NavigationStack {
                Form {
                    Section("Sort") { Picker("Sort", selection: $sort) { ForEach(BrowseSort.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented) }
                    Section("Type") { Picker("Type", selection: $type) { Text("All").tag("all"); Text("Lost").tag("lost"); Text("Found").tag("found") }.pickerStyle(.segmented) }
                    Section("Category") {
                        Picker("Category", selection: $category) {
                            Text("All").tag(nil as ItemCategory?)
                            ForEach(ItemCategory.allCases) { Text($0.rawValue).tag(Optional($0)) }
                        }
                    }
                    Section("Location") {
                        Picker("Location", selection: $location) {
                            Text("All locations").tag("")
                            ForEach(Campus.locations, id: \.self) { Text($0).tag($0) }
                        }
                    }
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            Text("All statuses").tag(nil as ItemStatus?)
                            ForEach(ItemStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
                        }
                    }
                    Button("Apply Filters") { filters = false }
                    Button("Clear Filters", role: .destructive) { clear(); filters = false }
                }
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
                .navigationTitle("Filter & Sort")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { filters = false } } }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var results: [LostFoundItem] {
        var list = app.items.filter { $0.status != .rejected && $0.status != .archived }
        if type == "lost" { list = list.filter { $0.type == .lost } }
        if type == "found" { list = list.filter { $0.type == .found } }
        if let category { list = list.filter { $0.category == category } }
        if !location.isEmpty { list = list.filter { $0.location.localizedCaseInsensitiveContains(location) } }
        if let status { list = list.filter { $0.status == status } }
        if !search.isEmpty {
            list = list.filter { $0.itemName.localizedCaseInsensitiveContains(search) || $0.displayCategory.localizedCaseInsensitiveContains(search) }
        }
        switch sort {
        case .newest: return list.sorted { $0.createdAt > $1.createdAt }
        case .oldest: return list.sorted { $0.createdAt < $1.createdAt }
        case .nameAZ: return list.sorted { $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == .orderedAscending }
        }
    }

    private func clear() { search = ""; category = nil; type = "all"; location = ""; status = nil; sort = .newest }

    private func chip(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: 13, weight: .semibold))
                .foregroundStyle(on ? .white : AppColors.label)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(on ? AppColors.red : AppColors.cardHi)
                .overlay(Capsule().stroke(on ? AppColors.red : AppColors.sep))
                .clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}
