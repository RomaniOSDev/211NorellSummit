import Foundation

struct CookedRecipeEntry: Identifiable, Codable, Hashable {
    var id: String
    var recipeID: String
    var cookedDate: Date
}
