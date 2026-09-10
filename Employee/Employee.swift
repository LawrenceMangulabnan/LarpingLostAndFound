import SwiftUI

struct EmployeeShell: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            EmployeeDashboardScreen()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            EmployeeReportsScreen()
                .tabItem {
                    Label("Reports", systemImage: "doc.text.fill")
                }
                .tag(1)

            EmployeeClaimsScreen()
                .tabItem {
                    Label("Claims", systemImage: "checkmark.seal.fill")
                }
                .tag(2)

            EmployeeItemsScreen()
                .tabItem {
                    Label("Items", systemImage: "shippingbox.fill")
                }
                .tag(3)

            EmployeeProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

// MARK: Dashboard

struct EmployeeDashboardScreen: View {
    @EnvironmentObject var app: AppController

    var pendingReports: Int {
        app.allItems.filter {
            $0.status == .pendingVerification
        }.count
    }

    var pendingClaims: Int {
        app.allClaims.filter {
            $0.status == .pendingVerification
        }.count
    }

    var approvedItems: Int {
        app.allItems.filter {
            $0.status == .approved
        }.count
    }

    var claimedItems: Int {
        app.allItems.filter {
            $0.status == .claimed
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenHeader(
                        title: "Dashboard",
                        subtitle: "Manage campus lost and found."
                    )

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 12
                    ) {
                        NavigationLink {
                            EmployeeReportsScreen(
                                initialFilter: .pendingVerification
                            )
                        } label: {
                            StatCard(
                                title: "Pending Reports",
                                value: "\(pendingReports)",
                                icon: "doc.badge.clock"
                            ) {}
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            EmployeeClaimsScreen(
                                initialFilter: .pendingVerification
                            )
                        } label: {
                            StatCard(
                                title: "Pending Claims",
                                value: "\(pendingClaims)",
                                icon: "checkmark.shield"
                            ) {}
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            EmployeeItemsScreen(
                                initialFilter: .approved
                            )
                        } label: {
                            StatCard(
                                title: "Approved Items",
                                value: "\(approvedItems)",
                                icon: "checkmark.circle"
                            ) {}
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            EmployeeItemsScreen(
                                initialFilter: .claimed
                            )
                        } label: {
                            StatCard(
                                title: "Claimed Items",
                                value: "\(claimedItems)",
                                icon: "shippingbox"
                            ) {}
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeader(title: "Needs Attention")

                    if pendingReports == 0 && pendingClaims == 0 {
                        EmptyStateView(
                            icon: "checkmark.circle",
                            title: "All caught up",
                            message: "There are no pending reports or claims."
                        )
                    } else {
                        if pendingReports > 0 {
                            NavigationLink {
                                EmployeeReportsScreen(
                                    initialFilter: .pendingVerification
                                )
                            } label: {
                                AttentionRow(
                                    icon: "doc.text",
                                    title: "Reports waiting for review",
                                    count: pendingReports
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        if pendingClaims > 0 {
                            NavigationLink {
                                EmployeeClaimsScreen(
                                    initialFilter: .pendingVerification
                                )
                            } label: {
                                AttentionRow(
                                    icon: "checkmark.seal",
                                    title: "Claims waiting for review",
                                    count: pendingClaims
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
        }
    }
}

struct AttentionRow: View {
    let icon: String
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.crimson)
                .frame(width: 28)

            Text(title)
                .foregroundStyle(.white)

            Spacer()

            Text("\(count)")
                .font(.headline.bold())
                .foregroundStyle(AppTheme.crimson)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: Reports

struct EmployeeReportsScreen: View {
    @EnvironmentObject var app: AppController

    enum ReportFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case pendingVerification = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"

        var id: String { rawValue }

        func matches(_ status: ItemStatus) -> Bool {
            switch self {
            case .all:
                return true
            case .pendingVerification:
                return status == .pendingVerification
            case .approved:
                return status == .approved
            case .rejected:
                return status == .rejected
            }
        }
    }

    @State private var filter: ReportFilter
    @State private var search = ""
    @State private var selectedItem: LostFoundItem?

    init(
        initialFilter: ReportFilter = .all
    ) {
        _filter = State(initialValue: initialFilter)
    }

    private var reports: [LostFoundItem] {
        app.allItems
            .filter { filter.matches($0.status) }
            .filter {
                search.isEmpty ||
                $0.itemName.localizedCaseInsensitiveContains(search) ||
                $0.location.localizedCaseInsensitiveContains(search)
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Reports",
                    subtitle: "Review student lost and found reports."
                )

                SearchBar(
                    text: $search,
                    placeholder: "Search reports"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ReportFilter.allCases) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                selected: self.filter == filter
                            ) {
                                self.filter = filter
                            }
                        }
                    }
                }

                if reports.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No reports",
                        message: "No reports match this filter."
                    )
                } else {
                    ForEach(reports) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            ItemCard(
                                item: item,
                                reporterName: app.userName(
                                    for: item.userID
                                )
                            ) {}
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .appBackground()
        .sheet(item: $selectedItem) { item in
            EmployeeReportReviewScreen(item: item)
        }
    }
}

// MARK: Review Report

struct EmployeeReportReviewScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    let item: LostFoundItem

    @State private var showReject = false
    @State private var rejectionReason = ""

    var currentItem: LostFoundItem {
        app.allItems.first(where: { $0.id == item.id }) ?? item
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        title: "Review Report",
                        subtitle: "Verify the information before approving."
                    )

                    ItemCard(
                        item: currentItem,
                        reporterName: app.userName(
                            for: currentItem.userID
                        )
                    ) {}

                    if currentItem.status == .pendingVerification {
                        PrimaryButton(
                            title: "Approve Report",
                            icon: "checkmark.circle.fill"
                        ) {
                            app.approveItem(currentItem)
                            dismiss()
                        }

                        Button {
                            showReject = true
                        } label: {
                            Label(
                                "Reject Report",
                                systemImage: "xmark.circle.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.red)
                            .background(.red.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    } else {
                        StatusBadge(
                            status: currentItem.status.rawValue
                        )
                    }
                }
                .padding(20)
            }
            .appBackground()
            .alert(
                "Reject Report",
                isPresented: $showReject
            ) {
                TextField(
                    "Reason",
                    text: $rejectionReason
                )

                Button("Cancel", role: .cancel) {}

                Button("Reject", role: .destructive) {
                    app.rejectItem(
                        currentItem,
                        reason: rejectionReason
                    )
                    dismiss()
                }
            } message: {
                Text("Provide a reason for rejecting this report.")
            }
        }
    }
}

// MARK: Claims

struct EmployeeClaimsScreen: View {
    @EnvironmentObject var app: AppController

    @State private var filter: EmployeeReportsScreen.ReportFilter
    @State private var selectedClaim: Claim?

    init(
        initialFilter: EmployeeReportsScreen.ReportFilter = .all
    ) {
        _filter = State(initialValue: initialFilter)
    }

    private var claims: [Claim] {
        app.allClaims
            .filter { filter.matches($0.status) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Claims",
                    subtitle: "Review ownership claims submitted by students."
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(
                            EmployeeReportsScreen.ReportFilter.allCases
                        ) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                selected: self.filter == filter
                            ) {
                                self.filter = filter
                            }
                        }
                    }
                }

                if claims.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.seal",
                        title: "No claims",
                        message: "There are no claims for this filter."
                    )
                } else {
                    ForEach(claims) { claim in
                        Button {
                            selectedClaim = claim
                        } label: {
                            ClaimCard(
                                claim: claim,
                                itemName: app.itemName(
                                    for: claim.itemID
                                ),
                                studentName: app.userName(
                                    for: claim.studentID
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .appBackground()
        .sheet(item: $selectedClaim) { claim in
            EmployeeClaimReviewScreen(claim: claim)
        }
    }
}

struct ClaimCard: View {
    let claim: Claim
    let itemName: String
    let studentName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AppTheme.crimson)

                Text(itemName)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                StatusBadge(status: claim.status.rawValue)
            }

            Text("Claimed by \(studentName)")
                .foregroundStyle(AppTheme.secondaryPrimaryText)

            Text(claim.verificationInformation)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: Claim Review

struct EmployeeClaimReviewScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    let claim: Claim

    @State private var showReject = false
    @State private var reason = ""

    var currentClaim: Claim {
        app.allClaims.first(where: { $0.id == claim.id }) ?? claim
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        title: "Review Claim",
                        subtitle: "Verify the student's ownership information."
                    )

                    ClaimCard(
                        claim: currentClaim,
                        itemName: app.itemName(
                            for: currentClaim.itemID
                        ),
                        studentName: app.userName(
                            for: currentClaim.studentID
                        )
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("VERIFICATION INFORMATION")
                            .font(.caption.bold())
                            .tracking(1)
                            .foregroundStyle(AppTheme.secondaryText)

                        Text(currentClaim.verificationInformation)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(AppTheme.card)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }

                    if currentClaim.status == .pendingVerification {
                        PrimaryButton(
                            title: "Approve Claim",
                            icon: "checkmark.circle.fill"
                        ) {
                            app.approveClaim(currentClaim)
                            dismiss()
                        }

                        Button {
                            showReject = true
                        } label: {
                            Label(
                                "Reject Claim",
                                systemImage: "xmark.circle.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.red)
                            .background(.red.opacity(0.12))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .alert(
                "Reject Claim",
                isPresented: $showReject
            ) {
                TextField("Reason", text: $reason)

                Button("Cancel", role: .cancel) {}

                Button("Reject", role: .destructive) {
                    app.rejectClaim(
                        currentClaim,
                        reason: reason
                    )
                    dismiss()
                }
            } message: {
                Text("Provide a reason for rejecting this claim.")
            }
        }
    }
}

// MARK: Items

struct EmployeeItemsScreen: View {
    @EnvironmentObject var app: AppController

    @State private var filter: ItemStatus?
    @State private var search = ""

    init(initialFilter: ItemStatus? = nil) {
        _filter = State(initialValue: initialFilter)
    }

    private var items: [LostFoundItem] {
        app.allItems
            .filter {
                guard let filter else {
                    return true
                }

                return $0.status == filter
            }
            .filter {
                search.isEmpty ||
                $0.itemName.localizedCaseInsensitiveContains(search) ||
                $0.location.localizedCaseInsensitiveContains(search)
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Items",
                    subtitle: "Manage verified campus items."
                )

                SearchBar(
                    text: $search,
                    placeholder: "Search items"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(
                            title: "All",
                            selected: filter == nil
                        ) {
                            filter = nil
                        }

                        ForEach(ItemStatus.allCases) { status in
                            FilterChip(
                                title: status.rawValue,
                                selected: filter == status
                            ) {
                                filter = status
                            }
                        }
                    }
                }

                if items.isEmpty {
                    EmptyStateView(
                        icon: "shippingbox",
                        title: "No items",
                        message: "No items match the selected filter."
                    )
                } else {
                    ForEach(items) { item in
                        EmployeeItemRow(item: item) {
                            app.updateItemStatus(
                                item,
                                to: nextStatus(for: item.status)
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .appBackground()
    }

    private func nextStatus(
        for status: ItemStatus
    ) -> ItemStatus {
        switch status {
        case .approved:
            return .claimed
        case .claimed:
            return .returned
        default:
            return .approved
        }
    }
}

struct EmployeeItemRow: View {
    let item: LostFoundItem
    let update: () -> Void

    private var buttonTitle: String {
        switch item.status {
        case .approved:
            return "Mark Claimed"
        case .claimed:
            return "Mark Returned"
        default:
            return "Approve"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ItemCard(item: item) {}

            Button {
                update()
            } label: {
                Label(
                    buttonTitle,
                    systemImage: "arrow.triangle.2.circlepath"
                )
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.crimson)
            }
        }
    }
}

// MARK: Employee Profile

struct EmployeeProfileScreen: View {
    @EnvironmentObject var app: AppController

    @State private var showLogout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(AppTheme.crimsonSoft)
                            .frame(width: 90, height: 90)
                            .overlay {
                                Image(
                                    systemName: "person.badge.shield.checkmark"
                                )
                                .font(.system(size: 36))
                                .foregroundStyle(AppTheme.crimson)
                            }

                        Text(app.currentUser?.fullName ?? "Employee")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text(app.currentUser?.email ?? "")
                            .foregroundStyle(AppTheme.secondaryText)

                        Text("Lost & Found Employee")
                            .font(.caption)
                            .foregroundStyle(AppTheme.crimson)
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
                        Label(
                            "Logout",
                            systemImage:
                                "rectangle.portrait.and.arrow.right"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.red)
                        .background(AppTheme.card)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
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