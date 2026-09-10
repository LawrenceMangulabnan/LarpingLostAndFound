import SwiftUI

struct ItemStatusFilter: View {
    @Binding var status: ItemStatus?
    var body: some View {
        Picker("Status", selection: $status) {
            Text("All Statuses").tag(nil as ItemStatus?)
            ForEach(ItemStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
        }
    }
}

