import Foundation

struct RecipeCollection: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var recipeIDs: [String]
    var createdDate: Date
}
