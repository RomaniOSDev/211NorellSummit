import Foundation

struct ShoppingListItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var recipeID: String?
    var isChecked: Bool
}
