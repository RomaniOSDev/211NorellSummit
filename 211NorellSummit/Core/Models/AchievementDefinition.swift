import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let symbolName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_dish", title: "First Dish", description: "Viewed your first recipe.", symbolName: "fork.knife"),
        AchievementDefinition(id: "recipe_explorer", title: "Recipe Explorer", description: "Viewed 10 recipes.", symbolName: "book.fill"),
        AchievementDefinition(id: "chefs_choice", title: "Chef's Choice", description: "'Favourite' marked 5 recipes.", symbolName: "heart.fill"),
        AchievementDefinition(id: "culinary_enthusiast", title: "Culinary Enthusiast", description: "'Favourite' marked 20 recipes.", symbolName: "star.fill"),
        AchievementDefinition(id: "pantry_master", title: "Pantry Master", description: "Completed your first ingredient list.", symbolName: "basket.fill"),
        AchievementDefinition(id: "shopping_expert", title: "Shopping Expert", description: "Completed five grocery lists.", symbolName: "cart.fill"),
        AchievementDefinition(id: "timing_perfectionist", title: "Timing Perfectionist", description: "Finished your first cooking timer.", symbolName: "timer"),
        AchievementDefinition(id: "timekeeper_pro", title: "Timekeeper Pro", description: "Successfully completed ten timers.", symbolName: "clock.fill")
    ]
}
