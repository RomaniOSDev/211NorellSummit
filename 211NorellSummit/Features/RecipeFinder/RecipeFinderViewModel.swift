import SwiftUI
import Combine

final class RecipeFinderViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var sortOption: RecipeSortOption = .latest
    @Published var selectedTags: Set<RecipeTag> = []

    func filteredRecipes(store: AppStore) -> [Recipe] {
        var results = store.allRecipes()

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query) ||
                $0.category.lowercased().contains(query) ||
                $0.ingredients.joined(separator: " ").lowercased().contains(query)
            }
        }

        if !selectedTags.isEmpty {
            results = results.filter { recipe in
                selectedTags.isSubset(of: Set(recipe.tags))
            }
        }

        switch sortOption {
        case .latest:
            results.sort { $0.addedDate > $1.addedDate }
        case .popular:
            results.sort { $0.popularity > $1.popularity }
        case .recommended:
            results.sort { lhs, rhs in
                if lhs.isRecommended != rhs.isRecommended { return lhs.isRecommended && !rhs.isRecommended }
                return lhs.rating > rhs.rating
            }
        }
        return results
    }

    func toggleTag(_ tag: RecipeTag) {
        HapticFeedback.lightTap()
        if selectedTags.contains(tag) { selectedTags.remove(tag) }
        else { selectedTags.insert(tag) }
    }
}
