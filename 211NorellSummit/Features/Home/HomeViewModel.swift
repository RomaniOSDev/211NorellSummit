import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    func featuredRecipe(from store: AppStore) -> Recipe? {
        let recommended = store.allRecipes().filter(\.isRecommended)
        if let pick = recommended.randomElement() { return pick }
        return store.allRecipes().randomElement()
    }

    func todaysMeals(from store: AppStore) -> [(slot: MealSlot, recipe: Recipe?)] {
        let today = Calendar.current.startOfDay(for: Date())
        return MealSlot.allCases.map { slot in
            let entry = store.mealPlanEntry(day: today, slot: slot)
            let recipe = entry.flatMap { store.recipe(id: $0.recipeID) }
            return (slot, recipe)
        }
    }

    func nextTimer(from store: AppStore) -> CookingTimer? {
        store.timers.min { $0.liveRemainingSeconds < $1.liveRemainingSeconds }
    }

    func formattedDate() -> String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

enum HomeQuickAction: String, CaseIterable, Identifiable {
    case browse = "Browse"
    case plan = "Plan Meals"
    case pantry = "Pantry"
    case timer = "New Timer"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .browse: return "fork.knife"
        case .plan: return "calendar"
        case .pantry: return "basket.fill"
        case .timer: return "timer"
        }
    }
}
