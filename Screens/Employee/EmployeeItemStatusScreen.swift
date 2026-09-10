import SwiftUI

struct EmployeeItemStatusScreen: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 18) {
                    ItemDetails(item: live)
                    Text("Change Status").font(.title2.bold())
                    ForEach(ItemStatus.allCases) { status in
                        Button {
                            app.updateItemStatus(live, to: status)
                        } label: {
                            HStack {
                                Text(status.rawValue)
                                Spacer()
                                if live.status == status { Image(systemName: "checkmark") }
                            }.padding()
                        }.buttonStyle(.bordered).disabled(live.status == status)
                    }
                }.padding()
            } else { ContentUnavailableView("Item deleted", systemImage: "tray") }
        }.appBackground().navigationTitle("Item Status").navigationBarTitleDisplayMode(.inline)
    }
}


