import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showSuccessCheck = false
    @State private var newItemName = ""
    @State private var showAddItem = false

    private var checkedCount: Int { store.shoppingListItems.filter(\.isChecked).count }
    private var totalCount: Int { store.shoppingListItems.count }

    var body: some View {
        VStack(spacing: 0) {
            if store.shoppingListItems.isEmpty {
                AppEmptyState(
                    icon: "cart.fill",
                    title: "Shopping list is empty",
                    message: "Add items from a recipe or tap + to add manually.",
                    buttonTitle: "Add Item"
                ) { showAddItem = true }
            } else {
                VStack(spacing: 12) {
                    progressHeader
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(store.shoppingListItems) { item in
                                ShoppingItemCell(item: item)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .appCard(cornerRadius: 12)
                                    .padding(.horizontal, 16)
                                    .onTapGesture { store.toggleShoppingItem(item.id) }
                                    .contextMenu {
                                        Button("Delete", role: .destructive) { store.removeShoppingItem(item.id) }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                if checkedCount > 0 {
                    AppPrimaryButton("Clear Checked (\(checkedCount))", icon: "checkmark.circle") {
                        HapticFeedback.mediumTap()
                        store.clearCheckedShoppingItems()
                        triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationTitle("Shopping List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.lightTap()
                    showAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .alert("Add Item", isPresented: $showAddItem) {
            TextField("Item name", text: $newItemName)
            Button("Cancel", role: .cancel) { newItemName = "" }
            Button("Add") {
                let name = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                store.shoppingListItems.append(ShoppingListItem(id: UUID().uuidString, name: name, recipeID: nil, isChecked: false))
                newItemName = ""
                HapticFeedback.mediumTap()
            }
        }
        .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
    }

    private var progressHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color("AppBackground"), lineWidth: 4)
                    .frame(width: 44, height: 44)
                Circle()
                    .trim(from: 0, to: totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0)
                    .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                Text("\(checkedCount)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color("AppAccent"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(totalCount - checkedCount) items left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(checkedCount) of \(totalCount) checked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
        .padding(16)
        .appCard()
        .padding(.horizontal, 16)
        .padding(.top, AppLayout.contentTop)
    }
}
