import SwiftUI

struct StudentItemDetailScreen: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 18) {
                    ItemDetails(item: live)
                    if live.status == .approved && app.currentUser?.role == .student && live.userID != app.currentUser?.id {
                        NavigationLink("I Think This Is Mine") { StudentClaimScreen(item: live) }
                            .buttonStyle(.borderedProminent)
                    }
                }.padding()
            } else { ContentUnavailableView("Report deleted", systemImage: "tray") }
        }.appBackground().navigationTitle("Item Details").navigationBarTitleDisplayMode(.inline)
    }
}

