import Foundation

enum RecipeRepository {
    static func allRecipes(custom: [Recipe]) -> [Recipe] {
        RecipeCatalog.recipes + custom
    }

    static func recipe(id: String, custom: [Recipe]) -> Recipe? {
        allRecipes(custom: custom).first { $0.id == id }
    }

    static func recipes(ids: [String], custom: [Recipe]) -> [Recipe] {
        ids.compactMap { recipe(id: $0, custom: custom) }
    }
}

enum IngredientScaler {
    static func scaledIngredients(_ ingredients: [String], from baseServings: Int, to targetServings: Int) -> [String] {
        guard baseServings > 0, targetServings > 0, targetServings != baseServings else {
            return ingredients
        }
        let factor = Double(targetServings) / Double(baseServings)
        return ingredients.map { scaleIngredient($0, factor: factor) }
    }

    private static func scaleIngredient(_ text: String, factor: Double) -> String {
        let pattern = #"^(\d+(?:\.\d+)?)\s*(.*)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let numberRange = Range(match.range(at: 1), in: text),
              let restRange = Range(match.range(at: 2), in: text),
              let value = Double(text[numberRange]) else {
            return text
        }

        let scaled = value * factor
        let formatted = scaled.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", scaled)
            : String(format: "%.1f", scaled)
        return "\(formatted) \(text[restRange])".trimmingCharacters(in: .whitespaces)
    }
}

enum PantryMatcher {
    static func isAvailableInPantry(ingredient: String, pantryItems: [PantryItem]) -> Bool {
        let normalized = normalize(ingredient)
        return pantryItems.contains { item in
            item.status == .inStock && (
                normalized.contains(normalize(item.name)) ||
                normalize(item.name).contains(normalized)
            )
        }
    }

    static func missingIngredients(from recipe: Recipe, pantryItems: [PantryItem]) -> [String] {
        recipe.ingredients.filter { !isAvailableInPantry(ingredient: $0, pantryItems: pantryItems) }
    }

    private static func normalize(_ text: String) -> String {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
            .joined(separator: " ")
    }
}

enum BatchTimelineBuilder {
    static func buildSession(name: String, recipes: [Recipe]) -> BatchCookSession {
        var steps: [BatchTimelineStep] = []
        var order = 0

        let maxSteps = recipes.map(\.steps.count).max() ?? 0
        for stepIndex in 0..<maxSteps {
            for recipe in recipes {
                guard stepIndex < recipe.steps.count else { continue }
                let duration = stepIndex < recipe.stepDurationsMinutes.count
                    ? recipe.stepDurationsMinutes[stepIndex]
                    : max(1, recipe.cookTimeMinutes / max(recipe.steps.count, 1))

                var hint: String?
                if duration >= 5, recipes.count > 1 {
                    let others = recipes.filter { $0.id != recipe.id }.map(\.title).joined(separator: ", ")
                    hint = "While this runs, prep: \(others)"
                }

                steps.append(BatchTimelineStep(
                    id: UUID().uuidString,
                    recipeID: recipe.id,
                    recipeTitle: recipe.title,
                    stepIndex: stepIndex,
                    instruction: recipe.steps[stepIndex],
                    durationMinutes: duration,
                    orderIndex: order,
                    isCompleted: false,
                    parallelHint: hint
                ))
                order += 1
            }
        }

        return BatchCookSession(
            id: UUID().uuidString,
            name: name,
            recipeIDs: recipes.map(\.id),
            timelineSteps: steps,
            createdDate: Date(),
            isCompleted: false
        )
    }
}
