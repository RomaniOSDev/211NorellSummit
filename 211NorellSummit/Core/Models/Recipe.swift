import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let ingredients: [String]
    let steps: [String]
    let cookTimeMinutes: Int
    let rating: Double
    let category: String
    let symbolName: String
    let popularity: Int
    let isRecommended: Bool
    let addedDate: Date
    let defaultServings: Int
    let tags: [RecipeTag]
    let stepDurationsMinutes: [Int]
    let isCustom: Bool

    init(
        id: String,
        title: String,
        description: String,
        ingredients: [String],
        steps: [String],
        cookTimeMinutes: Int,
        rating: Double,
        category: String,
        symbolName: String,
        popularity: Int,
        isRecommended: Bool,
        addedDate: Date,
        defaultServings: Int = 2,
        tags: [RecipeTag] = [],
        stepDurationsMinutes: [Int] = [],
        isCustom: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.steps = steps
        self.cookTimeMinutes = cookTimeMinutes
        self.rating = rating
        self.category = category
        self.symbolName = symbolName
        self.popularity = popularity
        self.isRecommended = isRecommended
        self.addedDate = addedDate
        self.defaultServings = defaultServings
        self.tags = tags
        self.stepDurationsMinutes = stepDurationsMinutes.isEmpty
            ? Self.evenStepDurations(totalMinutes: cookTimeMinutes, stepCount: steps.count)
            : stepDurationsMinutes
        self.isCustom = isCustom
    }

    private static func evenStepDurations(totalMinutes: Int, stepCount: Int) -> [Int] {
        guard stepCount > 0 else { return [] }
        let base = max(1, totalMinutes / stepCount)
        return Array(repeating: base, count: stepCount)
    }
}

enum RecipeSortOption: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case popular = "Popular"
    case recommended = "Recommended"

    var id: String { rawValue }
}

enum RecipeBrowseSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case browse = "Browse"
    case plan = "Plan"
    case books = "Books"

    var id: String { rawValue }
}
