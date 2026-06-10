import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe

    @State private var heartScale: CGFloat = 1
    @State private var showSuccessCheck = false
    @State private var servings: Int = 2
    @State private var noteText = ""
    @State private var showCookMode = false
    @State private var showCollectionPicker = false
    @State private var addedToShopping = false

    private var scaledIngredients: [String] {
        IngredientScaler.scaledIngredients(recipe.ingredients, from: recipe.defaultServings, to: servings)
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    RecipeHeroHeader(recipe: recipe)

                    HStack(spacing: 8) {
                        MetaPill(icon: "clock.fill", text: "\(recipe.cookTimeMinutes) min")
                        MetaPill(icon: "star.fill", text: String(format: "%.1f", recipe.rating))
                        MetaPill(icon: "tag.fill", text: recipe.category)
                    }

                    if !recipe.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(recipe.tags) { tag in
                                    AppTagChip(title: tag.rawValue, icon: tag.symbolName, isSelected: true) {}
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }

                    servingsCard
                    ingredientsCard
                    notesCard
                    stepsCard
                    actionButtons
                }
                .appScreenInsets(bottom: 90)
            }
            .overlay(alignment: .bottomTrailing) { favoriteButton }
            .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add to Collection") { showCollectionPicker = true }
                    if recipe.isCustom {
                        Button("Delete Recipe", role: .destructive) {
                            store.deleteCustomRecipe(id: recipe.id)
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .fullScreenCover(isPresented: $showCookMode) {
            CookModeView(recipe: recipe, servings: servings)
        }
        .sheet(isPresented: $showCollectionPicker) {
            CollectionPickerSheet(recipeID: recipe.id)
        }
        .onAppear {
            servings = recipe.defaultServings
            store.markRecipeViewed(recipe.id)
            store.lastViewedCategory = recipe.category
            noteText = store.note(for: recipe.id)
        }
        .onChange(of: noteText) { store.setNote($0, for: recipe.id) }
    }

    private var servingsCard: some View {
        HStack {
            Label("Servings", systemImage: "person.2.fill")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            HStack(spacing: 16) {
                Button {
                    guard servings > 1 else { return }
                    servings -= 1
                    HapticFeedback.lightTap()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(servings > 1 ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                }
                Text("\(servings)")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .frame(minWidth: 28)
                Button {
                    guard servings < 12 else { return }
                    servings += 1
                    HapticFeedback.lightTap()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(servings < 12 ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                }
            }
        }
        .padding(16)
        .appCard()
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Ingredients", icon: "list.bullet")
            ForEach(scaledIngredients, id: \.self) { item in
                IngredientCell(
                    name: item,
                    isInPantry: PantryMatcher.isAvailableInPantry(ingredient: item, pantryItems: store.pantryItems)
                )
            }
        }
        .padding(16)
        .appCard()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "My Notes", icon: "note.text")
            TextField("Added extra garlic, cook 5 min longer...", text: $noteText, axis: .vertical)
                .lineLimit(2...5)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(12)
                .background(Color("AppBackground").opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .appCard()
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppSectionHeader(title: "Steps", icon: "list.number")
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                StepCell(number: index + 1, text: step)
            }
        }
        .padding(16)
        .appCard()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            AppPrimaryButton(
                addedToShopping ? "Added to Shopping List" : "Add to Shopping List",
                icon: "cart.badge.plus"
            ) {
                HapticFeedback.mediumTap()
                store.addRecipeToShoppingList(recipe, servings: servings)
                addedToShopping = true
                triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
            }
            AppSecondaryButton("Start Cook Mode", icon: "play.circle.fill") {
                HapticFeedback.mediumTap()
                showCookMode = true
            }
        }
    }

    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: store.isFavorite(recipeID: recipe.id) ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(Color("AppTextPrimary"))
                .scaleEffect(heartScale)
                .frame(width: 58, height: 58)
                .background {
                    Circle()
                        .fill(AppVisualStyle.primaryButton)
                        .overlay { Circle().fill(AppVisualStyle.primaryButtonSheen) }
                }
                .compositingGroup()
                .appSoftElevation(.medium)
        }
        .padding(24)
    }

    private func toggleFavorite() {
        HapticFeedback.lightTap()
        let added = store.toggleFavorite(recipeID: recipe.id)
        if added {
            SystemSound.favorite()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { heartScale = 1.3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { heartScale = 1 }
            }
        }
    }
}

struct CollectionPickerSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let recipeID: String

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.recipeCollections) { collection in
                            Button {
                                store.addRecipe(recipeID, toCollection: collection.id)
                                HapticFeedback.mediumTap()
                                dismiss()
                            } label: {
                                CollectionCell(collection: collection)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
