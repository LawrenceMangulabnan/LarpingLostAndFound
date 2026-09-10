import SwiftUI

struct ItemFormFields: View {
    @Binding var draft: ItemDraft
    @State private var customLocation = false
    private let locations = ["Main Library", "Student Center", "CCMS Building", "CCMS Hallway", "Cafeteria", "Gymnasium", "Registrar", "Administration Building", "Parking Area", "Main Gate"]
    var body: some View {
        Section("Item") {
            Picker("Type", selection: $draft.type) { ForEach(ItemType.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
            TextField("Item name", text: $draft.name)
            Picker("Category", selection: $draft.category) { ForEach(ItemCategory.allCases) { Text($0.rawValue).tag($0) } }
            if draft.category == .other { TextField("Custom category", text: $draft.customCategory) }
        }
        Section("Details") {
            Toggle("Custom location", isOn: $customLocation)
                .onChange(of: customLocation) { _, custom in
                    if !custom && !locations.contains(draft.location) { draft.location = locations[0] }
                }
            if customLocation || !locations.contains(draft.location) {
                TextField("Location", text: $draft.location)
            } else {
                Picker("Location", selection: $draft.location) { ForEach(locations, id: \.self) { Text($0).tag($0) } }
            }
            DatePicker("Date", selection: $draft.date, in: ...Date(), displayedComponents: .date)
            TextField("Description", text: $draft.description, axis: .vertical).lineLimit(4...8)
        }
        .onAppear { customLocation = !locations.contains(draft.location) }
    }
}


