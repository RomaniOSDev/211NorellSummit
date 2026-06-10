import SwiftUI

struct AddRecipeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var category = "Custom"
    @State private var cookTime = 30
    @State private var servings = 2
    @State private var ingredientsText = ""
    @State private var stepsText = ""
    @State private var selectedTags: Set<RecipeTag> = []
    @State private var shakeAmount: CGFloat = 0
    @State private var titleError = ""
    @State private var showSuccessCheck = false

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                Form {
                    Section {
                        TextField("Recipe title", text: $title)
                            .modifier(ShakeEffect(animatableData: shakeAmount))
                        if !titleError.isEmpty {
                            Text(titleError).font(.caption).foregroundStyle(.red)
                        }
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(2...4)
                        TextField("Category", text: $category)
                        Stepper("Cook time: \(cookTime) min", value: $cookTime, in: 5...180, step: 5)
                        Stepper("Servings: \(servings)", value: $servings, in: 1...12)
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section("Tags") {
                        ForEach(RecipeTag.allCases) { tag in
                            Toggle(tag.rawValue, isOn: Binding(
                                get: { selectedTags.contains(tag) },
                                set: { isOn in
                                    if isOn { selectedTags.insert(tag) } else { selectedTags.remove(tag) }
                                }
                            ))
                            .tint(Color("AppPrimary"))
                        }
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section("Ingredients (one per line)") {
                        TextField("400g pasta\n2 cups cream", text: $ingredientsText, axis: .vertical)
                            .lineLimit(4...10)
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section("Steps (one per line)") {
                        TextField("Boil pasta.\nAdd sauce.", text: $stepsText, axis: .vertical)
                            .lineLimit(4...10)
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleError = "Please enter a title."
            HapticFeedback.warning()
            withAnimation { shakeAmount += 1 }
            return
        }

        let ingredients = ingredientsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let steps = stepsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty, !steps.isEmpty else {
            titleError = "Add at least one ingredient and step."
            HapticFeedback.warning()
            withAnimation { shakeAmount += 1 }
            return
        }

        let recipe = Recipe(
            id: "custom-\(UUID().uuidString)",
            title: trimmed,
            description: description.isEmpty ? "My custom recipe." : description,
            ingredients: ingredients,
            steps: steps,
            cookTimeMinutes: cookTime,
            rating: 5.0,
            category: category,
            symbolName: "book.fill",
            popularity: 0,
            isRecommended: false,
            addedDate: Date(),
            defaultServings: servings,
            tags: Array(selectedTags),
            isCustom: true
        )

        HapticFeedback.mediumTap()
        store.addCustomRecipe(recipe)
        triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
        dismiss()
    }
}
