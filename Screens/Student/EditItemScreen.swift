import SwiftUI

struct EditItemScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    let item: LostFoundItem
    @State private var draft: ItemDraft
    @State private var confirmDelete = false
    private var isClosed: Bool {
        guard let live = app.items.first(where: { $0.id == item.id }) else { return true }
        return [ItemStatus.claimed, .returned, .archived].contains(live.status)
    }
    init(item: LostFoundItem) {
        self.item = item
        _draft = State(initialValue: ItemDraft(name: item.itemName, category: item.category, customCategory: item.customCategory, location: item.location, date: item.date, description: item.description, type: item.type, photoData: item.photoData))
    }
    var body: some View {
        Form {
            ItemFormFields(draft: $draft).disabled(isClosed)
            Text(isClosed ? "This report is completed or unavailable. Contact staff for corrections." : "Editing an approved or rejected report sends it back for verification.").font(.caption)
            AppButton(title: "Save Report") {
                var updated = item
                updated.itemName = draft.name; updated.category = draft.category
                updated.customCategory = draft.customCategory; updated.location = draft.location
                updated.date = draft.date; updated.description = draft.description; updated.type = draft.type
                if app.updateItem(updated) { dismiss() }
            }.disabled(isClosed)
            Button("Delete Report", role: .destructive) { confirmDelete = true }.disabled(isClosed)
        }.appBackground().navigationTitle("Edit Report")
            .confirmationDialog("Delete this report and its claims?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete Report", role: .destructive) { if app.deleteItem(item) { dismiss() } }
                Button("Cancel", role: .cancel) { confirmDelete = false }
            }
    }
}
