import SwiftUI

struct StudentMyItemsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var showClaims = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("My Items").font(.largeTitle.bold())
                Picker("Show", selection: $showClaims) {
                    Text("My Reports").tag(false)
                    Text("My Claims").tag(true)
                }.pickerStyle(.segmented)
                if let user = app.currentUser {
                    if showClaims {
                        ForEach(app.claims(for: user.id)) { claim in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(app.itemName(for: claim.itemID)).font(.headline)
                                StatusBadge(text: claim.status.rawValue)
                                Text(claim.verificationInformation)
                            }.frame(maxWidth: .infinity, alignment: .leading).appCard()
                        }
                        if app.claims(for: user.id).isEmpty { Text("No claims submitted yet.") }
                    } else {
                        ForEach(app.items.filter { $0.userID == user.id }.sorted { $0.createdAt > $1.createdAt }) { item in
                            NavigationLink { EditItemScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                        }
                        if !app.items.contains(where: { $0.userID == user.id }) { Text("No reports submitted yet.") }
                    }
                }
            }.padding()
        }.appBackground()
    }
}
