import Foundation

enum MealSlot: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        }
    }
}

struct MealPlanEntry: Identifiable, Codable, Hashable {
    var id: String
    var dayStart: Date
    var slot: MealSlot
    var recipeID: String
}
