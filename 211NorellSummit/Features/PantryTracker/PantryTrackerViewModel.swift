import SwiftUI
import Combine

final class PantryTrackerViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingItem: PantryItem?
    @Published var showingStats = false
    @Published var addCategory: String = PantryCategory.grains.rawValue

    func items(for category: String, in store: AppStore) -> [PantryItem] {
        store.pantryItems.filter { $0.category == category }
    }

    func isExpanded(_ category: String, store: AppStore) -> Bool {
        store.categoriesExpandedState[category, default: true]
    }

    func toggleExpanded(_ category: String, store: AppStore) {
        HapticFeedback.lightTap()
        var state = store.categoriesExpandedState
        state[category] = !(state[category] ?? true)
        store.categoriesExpandedState = state
    }

    func deleteItem(_ item: PantryItem, store: AppStore) {
        HapticFeedback.lightTap()
        store.pantryItems.removeAll { $0.id == item.id }
    }

    func markOutOfStock(_ item: PantryItem, store: AppStore) {
        guard let index = store.pantryItems.firstIndex(where: { $0.id == item.id }) else { return }
        store.pantryItems[index].status = .outOfStock
        HapticFeedback.success()
        SystemSound.vibrate()
    }

    func saveItem(_ item: PantryItem, store: AppStore, isNew: Bool) {
        if isNew {
            store.pantryItems.append(item)
        } else if let index = store.pantryItems.firstIndex(where: { $0.id == item.id }) {
            store.pantryItems[index] = item
        }
        store.recordActivity(minutes: 2)
    }
}
