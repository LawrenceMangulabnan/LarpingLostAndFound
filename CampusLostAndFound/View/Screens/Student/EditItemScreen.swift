import SwiftUI

struct EditItemScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    let item: LostFoundItem
    @State private var draft: ItemDraft
    @State private var camera = false
    private var closed: Bool {
        guard let live = app.items.first(where: { $0.id == item.id }) else { return true }
        return [ItemStatus.claimed, .returned, .archived].contains(live.status)
    }
    init(item: LostFoundItem) {
        self.item = item
        _draft = State(initialValue: ItemDraft(name: item.itemName, category: item.category, customCategory: item.customCategory, location: item.location, date: item.date, description: item.description, type: item.type, photoData: item.photoData))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(closed ? "This report is completed. Contact staff for corrections." : "Editing an approved or rejected report sends it back for verification.")
                    .font(.caption).foregroundStyle(AppColors.label3)
                CapsuleSegment(options: [(ItemType.lost, "Lost"), (.found, "Found")], value: $draft.type).disabled(closed)
                ReportPhotoWell(imageData: $draft.photoData, camera: $camera).disabled(closed)
                LabeledField(label: "Item Name", placeholder: "Item name", text: $draft.name)
                Picker("Category", selection: Binding(get: { draft.category ?? .other }, set: { draft.category = $0 })) {
                    ForEach(ItemCategory.allCases) { Text($0.rawValue).tag($0) }
                }.disabled(closed)
                if draft.category == .other { LabeledField(label: "Custom Category", placeholder: "Enter item category", text: $draft.customCategory) }
                Picker("Location", selection: $draft.location) { ForEach(Campus.locations, id: \.self) { Text($0).tag($0) } }.disabled(closed)
                DatePicker("Date", selection: $draft.date, in: ...Date(), displayedComponents: .date).disabled(closed)
                LabeledField(label: "Description", placeholder: "Description", text: $draft.description)
                AppButton(title: "Save Report", enabled: !closed) {
                    var updated = item
                    updated.itemName = draft.name; updated.category = draft.category ?? item.category
                    updated.customCategory = draft.customCategory; updated.location = draft.location
                    updated.date = draft.date; updated.description = draft.description; updated.type = draft.type
                    updated.photoData = draft.photoData
                    if app.updateItem(updated) { dismiss() }
                }
            }.padding(16).disabled(closed)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Edit Report")
        .sheet(isPresented: $camera) { CameraImagePicker(imageData: $draft.photoData).ignoresSafeArea() }
    }
}
