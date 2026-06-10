import Foundation

enum RecipeTag: String, Codable, CaseIterable, Identifiable {
    case vegetarian = "Vegetarian"
    case quick = "Quick"
    case highProtein = "High Protein"
    case onePot = "One-Pot"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .vegetarian: return "leaf.fill"
        case .quick: return "bolt.fill"
        case .highProtein: return "figure.strengthtraining.traditional"
        case .onePot: return "frying.pan.fill"
        }
    }
}
