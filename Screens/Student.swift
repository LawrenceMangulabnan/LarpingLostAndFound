import SwiftUI
import UIKit

struct StudentShell: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StudentHomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            StudentBrowseScreen()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
                .tag(1)

            StudentReportScreen()
                .tabItem {
                    Label("Report", systemImage: "plus.circle.fill")
                }
                .tag(2)

            StudentMyItemsScreen()
                .tabItem {
                    Label("My Items", systemImage: "shippingbox.fill")
                }
                .tag(3)

            StudentProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

// MARK: Home

struct StudentHomeScreen: View {
    @EnvironmentObject var app: AppController

    @State private var search = ""
    @State private var showNotifications = false

    private var approvedItems: [LostFoundItem] {
        app.allItems
            .filter { $0.status == .approved }
            .filter {
                search.isEmpty ||
                $0.itemName.localizedCaseInsensitiveContains(search)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back,")
                                .foregroundStyle(AppTheme.secondaryText)

                            Text(app.currentUser?.fullName ?? "Student")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Button {
                            showNotifications = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(AppTheme.card)
                                    .clipShape(Circle())

                                if app.unreadCount() > 0 {
                                    Circle()
                                        .fill(AppTheme.crimson)
                                        .frame(width: 9, height: 9)
                                }
                            }
                        }
                    }

                    SearchBar(
                        text: $search,
                        placeholder: "Search lost & found items"
                    )

                    HStack(spacing: 12) {
                        NavigationLink {
                            StudentReportScreen(initialType: .lost)
                        } label: {
                            QuickAction(
                                title: "Report Lost",
                                icon: "magnifyingglass"
                            )
                        }

                        NavigationLink {
                            StudentReportScreen(initialType: .found)
                        } label: {
                            QuickAction(
                                title: "Report Found",
                                icon: "shippingbox"
                            )
                        }
                    }

                    SectionHeader(
                        title: "Recently Verified"
                    )

                    if approvedItems.isEmpty {
                        EmptyStateView(
                            icon: "shippingbox",
                            title: "No items found",
                            message: "There are no matching verified items."
                        )
                    } else {
                        ForEach(approvedItems.prefix(5)) { item in
                            NavigationLink {
                                StudentItemDetailScreen(item: item)
                            } label: {
                                ItemCard(item: item) {}
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("")
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsScreen()
            }
        }
    }
}

struct QuickAction: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.crimson)

            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: Browse

struct StudentBrowseScreen: View {
    @EnvironmentObject var app: AppController

    @State private var search = ""
    @State private var selectedType: ItemType? = nil
    @State private var selectedCategory: ItemCategory? = nil
    @State private var sortNewest = true

    private var filteredItems: [LostFoundItem] {
        var result = app.allItems.filter {
            $0.status == .approved
        }

        if let selectedType {
            result = result.filter { $0.type == selectedType }
        }

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if !search.isEmpty {
            result = result.filter {
                $0.itemName.localizedCaseInsensitiveContains(search) ||
                $0.location.localizedCaseInsensitiveContains(search) ||
                $0.displayCategory.localizedCaseInsensitiveContains(search)
            }
        }

        if sortNewest {
            result.sort { $0.date > $1.date }
        } else {
            result.sort {
                $0.itemName.localizedCaseInsensitiveCompare($1.itemName)
                == .orderedAscending
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        title: "Browse Items",
                        subtitle: "Find verified lost and found items."
                    )

                    SearchBar(text: $search)

                    Text("TYPE")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(
                                title: "All",
                                selected: selectedType == nil
                            ) {
                                selectedType = nil
                            }

                            ForEach(ItemType.allCases) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    selected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }

                    Text("CATEGORY")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(
                                title: "All",
                                selected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(ItemCategory.allCases) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    selected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }

                    HStack {
                        Text("\(filteredItems.count) items")
                            .foregroundStyle(AppTheme.secondaryText)

                        Spacer()

                        Button {
                            sortNewest.toggle()
                        } label: {
                            Label(
                                sortNewest ? "Newest" : "A-Z",
                                systemImage: "arrow.up.arrow.down"
                            )
                            .foregroundStyle(AppTheme.crimson)
                        }
                    }

                    if filteredItems.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No matching items",
                            message: "Try another search or filter."
                        )
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                StudentItemDetailScreen(item: item)
                            } label: {
                                ItemCard(item: item) {}
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("")
        }
    }
}

// MARK: Report

struct StudentReportScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    @State private var type: ItemType
    @State private var itemName = ""
    @State private var category: ItemCategory = .electronics
    @State private var customCategory = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var description = ""
    @State private var imageData: Data?
    @State private var showCamera = false
    @State private var showLocationPicker = false
    @State private var showSuccess = false
    @State private var showError = false

    init(initialType: ItemType = .lost) {
        _type = State(initialValue: initialType)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Report \(type.rawValue) Item",
                    subtitle: "Provide accurate information for verification."
                )

                Picker("Report Type", selection: $type) {
                    ForEach(ItemType.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)

                formField(
                    title: "ITEM NAME"
                ) {
                    TextField(
                        "e.g. Black Wallet",
                        text: $itemName
                    )
                    .textFieldStyle(AppTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("CATEGORY")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if category == .other {
                    formField(title: "CUSTOM CATEGORY") {
                        TextField(
                            "Enter category",
                            text: $customCategory
                        )
                        .textFieldStyle(AppTextFieldStyle())
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("PHOTO")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    PhotoPickerButton(imageData: $imageData)

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        } else {
                            app.errorMessage = "Camera is not available on this device."
                            showError = true
                        }
                    } label: {
                        Label(
                            "Take Photo",
                            systemImage: "camera.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("LOCATION")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    Button {
                        showLocationPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "mappin.circle.fill")

                            Text(
                                location.isEmpty
                                ? "Select campus location"
                                : location
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(
                            location.isEmpty
                            ? AppTheme.secondaryText
                            : .white
                        )
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("DATE")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                formField(title: "DESCRIPTION") {
                    TextEditor(text: $description)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .frame(height: 130)
                        .padding(10)
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                PrimaryButton(
                    title: "Submit Report",
                    icon: "paperplane.fill"
                ) {
                    submit()
                }
            }
            .padding(20)
        }
        .appBackground()
        .sheet(isPresented: $showCamera) {
            CameraPicker(imageData: $imageData)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selectedLocation: $location)
        }
        .alert(
            "Report Submitted",
            isPresented: $showSuccess
        ) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your report is now Pending Verification.")
        }
        .alert(
            "Unable to Submit",
            isPresented: $showError
        ) {
            Button("OK") {}
        } message: {
            Text(app.errorMessage ?? "Please check the form.")
        }
    }

    @ViewBuilder
    private func formField<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(AppTheme.secondaryText)

            content()
        }
    }

    private func submit() {
        let success = app.addItem(
            itemName: itemName,
            category: category,
            customCategory: customCategory,
            location: location,
            date: date,
            description: description,
            type: type,
            photoData: imageData
        )

        if success {
            showSuccess = true
        } else {
            showError = true
        }
    }
}

struct LocationPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: String

    private let locations = [
        "Main Building",
        "Library",
        "Computer Laboratory",
        "Cafeteria",
        "Gymnasium",
        "Student Center",
        "Parking Area",
        "Administration Building",
        "Classroom Building",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            List(locations, id: \.self) { location in
                Button {
                    selectedLocation = location
                    dismiss()
                } label: {
                    HStack {
                        Text(location)
                            .foregroundStyle(.white)

                        Spacer()

                        if selectedLocation == location {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.crimson)
                        }
                    }
                }
                .listRowBackground(AppTheme.card)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: Item Detail

struct StudentItemDetailScreen: View {
    @EnvironmentObject var app: AppController

    let item: LostFoundItem

    @State private var showClaim = false

    var currentItem: LostFoundItem {
        app.allItems.first(where: { $0.id == item.id }) ?? item
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Group {
                    if let data = currentItem.photoData,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            AppTheme.card

                            Image(
                                systemName: currentItem.type == .lost
                                ? "magnifyingglass"
                                : "shippingbox.fill"
                            )
                            .font(.system(size: 55))
                            .foregroundStyle(AppTheme.crimson)
                        }
                    }
                }
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(currentItem.itemName)
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        Text(currentItem.type.rawValue)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Spacer()

                    StatusBadge(status: currentItem.status.rawValue)
                }

                detailRow(
                    icon: "square.grid.2x2",
                    title: "Category",
                    value: currentItem.displayCategory
                )

                detailRow(
                    icon: "mappin.circle",
                    title: "Location",
                    value: currentItem.location
                )

                detailRow(
                    icon: "calendar",
                    title: "Date",
                    value: currentItem.date.formatted(
                        date: .long,
                        time: .omitted
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIPTION")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    Text(currentItem.description.isEmpty
                         ? "No description provided."
                         : currentItem.description)
                        .foregroundStyle(AppTheme.secondaryPrimaryText)
                }
                .padding()
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                if currentItem.type == .found &&
                    currentItem.status == .approved {

                    PrimaryButton(
                        title: "I Think This Is Mine",
                        icon: "checkmark.seal.fill"
                    ) {
                        showClaim = true
                    }
                }
            }
            .padding(20)
        }
        .appBackground()
        .navigationTitle("")
        .sheet(isPresented: $showClaim) {
            StudentClaimScreen(item: currentItem)
        }
    }

    private func detailRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.crimson)
                .frame(width: 25)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)

                Text(value)
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: Claim

struct StudentClaimScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    let item: LostFoundItem

    @State private var verification = ""
    @State private var submitted = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        title: "Claim Item",
                        subtitle: "Provide information that verifies ownership."
                    )

                    ItemCard(item: item) {}

                    Text("OWNERSHIP VERIFICATION")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(AppTheme.secondaryText)

                    TextEditor(text: $verification)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .frame(height: 180)
                        .padding(10)
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text(
                        "Describe distinguishing marks, contents, serial numbers, purchase information, or other details that can help verify that this item belongs to you."
                    )
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)

                    PrimaryButton(
                        title: "Submit Claim",
                        icon: "checkmark.shield.fill"
                    ) {
                        submitClaim()
                    }
                }
                .padding(20)
            }
            .appBackground()
            .alert(
                "Claim Submitted",
                isPresented: $submitted
            ) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your claim is now Pending Verification.")
            }
            .alert(
                "Unable to Submit",
                isPresented: $showError
            ) {
                Button("OK") {}
            } message: {
                Text(app.errorMessage ?? "Please provide verification information.")
            }
        }
    }

    private func submitClaim() {
        let success = app.submitClaim(
            item: item,
            verification: verification
        )

        if success {
            submitted = true
        } else {
            showError = true
        }
    }
}

// MARK: My Items

struct StudentMyItemsScreen: View {
    @EnvironmentObject var app: AppController

    @State private var selectedFilter = "All"
    @State private var itemToDelete: LostFoundItem?
    @State private var showDelete = false

    private var myItems: [LostFoundItem] {
        guard let userID = app.currentUser?.id else {
            return []
        }

        let items = app.allItems.filter {
            $0.userID == userID
        }

        if selectedFilter == "All" {
            return items
        }

        return items.filter {
            $0.type.rawValue == selectedFilter
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        title: "My Items",
                        subtitle: "Manage your lost and found reports."
                    )

                    HStack {
                        ForEach(
                            ["All", "Lost", "Found"],
                            id: \.self
                        ) { filter in
                            FilterChip(
                                title: filter,
                                selected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }

                    if myItems.isEmpty {
                        EmptyStateView(
                            icon: "shippingbox",
                            title: "No reports yet",
                            message: "Your submitted reports will appear here."
                        )
                    } else {
                        ForEach(myItems) { item in
                            VStack(spacing: 8) {
                                NavigationLink {
                                    StudentEditReportScreen(item: item)
                                } label: {
                                    ItemCard(item: item) {}
                                }
                                .buttonStyle(.plain)

                                HStack {
                                    Spacer()

                                    Button {
                                        itemToDelete = item
                                        showDelete = true
                                    } label: {
                                        Label(
                                            "Delete",
                                            systemImage: "trash"
                                        )
                                        .font(.caption.bold())
                                        .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .alert(
                "Delete Report?",
                isPresented: $showDelete,
                presenting: itemToDelete
            ) { item in
                Button("Cancel", role: .cancel) {}

                Button("Delete", role: .destructive) {
                    app.deleteItem(item)
                }
            } message: { item in
                Text("Delete \(item.itemName)? This action cannot be undone.")
            }
        }
    }
}

// MARK: Edit Report

struct StudentEditReportScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    let originalItem: LostFoundItem

    @State private var itemName: String
    @State private var category: ItemCategory
    @State private var customCategory: String
    @State private var location: String
    @State private var date: Date
    @State private var description: String
    @State private var imageData: Data?
    @State private var showLocation = false
    @State private var showCamera = false
    @State private var saved = false

    init(item: LostFoundItem) {
        originalItem = item

        _itemName = State(initialValue: item.itemName)
        _category = State(initialValue: item.category)
        _customCategory = State(initialValue: item.customCategory)
        _location = State(initialValue: item.location)
        _date = State(initialValue: item.date)
        _description = State(initialValue: item.description)
        _imageData = State(initialValue: item.photoData)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Edit Report",
                    subtitle: "Update your report information."
                )

                TextField("Item Name", text: $itemName)
                    .textFieldStyle(AppTextFieldStyle())

                Picker("Category", selection: $category) {
                    ForEach(ItemCategory.allCases) { category in
                        Text(category.rawValue)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if category == .other {
                    TextField(
                        "Custom Category",
                        text: $customCategory
                    )
                    .textFieldStyle(AppTextFieldStyle())
                }

                Button {
                    showLocation = true
                } label: {
                    HStack {
                        Image(systemName: "mappin.circle.fill")

                        Text(location)

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                .padding()
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                PhotoPickerButton(imageData: $imageData)

                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    }
                } label: {
                    Label(
                        "Take Photo",
                        systemImage: "camera.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                TextEditor(text: $description)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .frame(height: 140)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                PrimaryButton(
                    title: "Save Changes",
                    icon: "checkmark"
                ) {
                    save()
                }
            }
            .padding(20)
        }
        .appBackground()
        .sheet(isPresented: $showLocation) {
            LocationPicker(selectedLocation: $location)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(imageData: $imageData)
                .ignoresSafeArea()
        }
        .alert(
            "Saved",
            isPresented: $saved
        ) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your report has been updated.")
        }
    }

    private func save() {
        var updated = originalItem

        updated.itemName = itemName
        updated.category = category
        updated.customCategory = customCategory
        updated.location = location
        updated.date = date
        updated.description = description
        updated.photoData = imageData

        app.updateItem(updated)
        saved = true
    }
}

// MARK: Profile

struct StudentProfileScreen: View {
    @EnvironmentObject var app: AppController

    @State private var showLogout = false
    @State private var showNotifications = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(AppTheme.crimsonSoft)
                            .frame(width: 90, height: 90)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(AppTheme.crimson)
                            }

                        Text(app.currentUser?.fullName ?? "")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text(app.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)

                        Text(app.currentUser?.universityID ?? "")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .appCard()

                    SettingsSection(title: "Account") {
                        NavigationLink {
                            EditProfileScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "Edit Profile",
                                icon: "person.crop.circle"
                            )
                        }

                        Divider()

                        NavigationLink {
                            ChangePasswordScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "Change Password",
                                icon: "lock"
                            )
                        }
                    }

                    SettingsSection(title: "Support") {
                        NavigationLink {
                            NotificationsScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "Notifications",
                                icon: "bell"
                            )
                        }

                        Divider()

                        NavigationLink {
                            HelpSupportScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "Help & Support",
                                icon: "questionmark.circle"
                            )
                        }

                        Divider()

                        NavigationLink {
                            AboutScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "About",
                                icon: "info.circle"
                            )
                        }

                        Divider()

                        NavigationLink {
                            RateAppScreen()
                        } label: {
                            SettingsRowLabel(
                                title: "Rate the App",
                                icon: "star"
                            )
                        }
                    }

                    Button {
                        showLogout = true
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.red)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
            }
            .appBackground()
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogout,
                titleVisibility: .visible
            ) {
                Button("Logout", role: .destructive) {
                    app.logout()
                }

                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct SettingsRowLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.crimson)
                .frame(width: 25)

            Text(title)
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(16)
    }
}