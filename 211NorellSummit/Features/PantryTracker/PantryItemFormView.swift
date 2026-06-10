import SwiftUI

struct PantryItemFormView: View {
    @Environment(\.dismiss) private var dismiss

    let item: PantryItem?
    let defaultCategory: String
    let onSave: (PantryItem, Bool) -> Void

    @State private var name = ""
    @State private var quantity = ""
    @State private var category = ""
    @State private var status: PantryItemStatus = .inStock
    @State private var hasExpiry = false
    @State private var expiryDate = Date()
    @State private var shakeAmount: CGFloat = 0
    @State private var nameError = ""

    private var isNew: Bool { item == nil }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                Form {
                    Section {
                        TextField("Item name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: shakeAmount))

                        if !nameError.isEmpty {
                            Text(nameError)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        TextField("Quantity (e.g. 2 kg)", text: $quantity)
                            .foregroundStyle(Color("AppTextPrimary"))

                        Picker("Category", selection: $category) {
                            ForEach(PantryCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat.rawValue)
                            }
                        }

                        Picker("Status", selection: $status) {
                            ForEach(PantryItemStatus.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }

                        Toggle("Expiry Date", isOn: $hasExpiry)
                            .tint(Color("AppPrimary"))

                        if hasExpiry {
                            DatePicker("Expires", selection: $expiryDate, displayedComponents: .date)
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isNew ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticFeedback.lightTap()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let item {
                    name = item.name
                    quantity = item.quantity
                    category = item.category
                    status = item.status
                    if let expiry = item.expiryDate {
                        hasExpiry = true
                        expiryDate = expiry
                    }
                } else {
                    category = defaultCategory
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            nameError = "Please enter an item name."
            HapticFeedback.warning()
            withAnimation { shakeAmount += 1 }
            return
        }

        HapticFeedback.mediumTap()
        let saved = PantryItem(
            id: item?.id ?? UUID().uuidString,
            name: trimmed,
            quantity: quantity.isEmpty ? "1 unit" : quantity,
            category: category,
            status: status,
            expiryDate: hasExpiry ? expiryDate : nil
        )
        onSave(saved, isNew)
        dismiss()
    }
}
