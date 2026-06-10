import SwiftUI

struct RecipesRootView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var section: RecipeBrowseSection
    var onHomeNavigate: (HomeDestination) -> Void

    init(
        section: Binding<RecipeBrowseSection> = .constant(.home),
        onHomeNavigate: @escaping (HomeDestination) -> Void = { _ in }
    ) {
        _section = section
        self.onHomeNavigate = onHomeNavigate
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    AppSegmentTabs(
                        selection: $section,
                        items: RecipeBrowseSection.allCases,
                        icon: { s in
                            switch s {
                            case .home: return "house.fill"
                            case .browse: return "square.grid.2x2.fill"
                            case .plan: return "calendar"
                            case .books: return "books.vertical.fill"
                            }
                        }
                    )

                    switch section {
                    case .home:
                        HomeView(onNavigate: handleHomeNavigation)
                    case .browse:
                        RecipeBrowseContent()
                    case .plan:
                        MealPlanView()
                    case .books:
                        CollectionsView()
                    }
                }
            }
            .navigationTitle(section == .home ? "Home" : "Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }

    private func handleHomeNavigation(_ destination: HomeDestination) {
        switch destination {
        case .browse:
            section = .browse
        case .mealPlan:
            section = .plan
        case .pantry, .shopping, .timers, .quickAction:
            onHomeNavigate(destination)
        }
    }
}

struct RecipeBrowseContent: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = RecipeFinderViewModel()
    @State private var showAddRecipe = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !store.recentlyViewedRecipes().isEmpty {
                    recipeCarousel(title: "Recently Viewed", icon: "clock.arrow.circlepath", recipes: store.recentlyViewedRecipes())
                }
                if !store.cookedRecipes().isEmpty {
                    recipeCarousel(title: "Cooked Before", icon: "checkmark.seal.fill", recipes: store.cookedRecipes())
                }

                AppSearchBar(text: $viewModel.searchText)
                tagFilters
                sortControl

                let recipes = viewModel.filteredRecipes(store: store)
                if recipes.isEmpty {
                    AppEmptyState(
                        icon: "fork.knife.circle",
                        title: "Explore new flavors!",
                        message: "Try adjusting filters or search for something new."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeGridCell(recipe: recipe, isFavorite: store.isFavorite(recipeID: recipe.id))
                            }
                            .buttonStyle(.plain)
                            .draggable(recipe.id)
                        }
                    }
                }
            }
            .appScreenInsets()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.lightTap()
                    showAddRecipe = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .sheet(isPresented: $showAddRecipe) { AddRecipeView() }
    }

    private func recipeCarousel(title: String, icon: String, recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: title, icon: icon, trailing: "\(recipes.count)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeCompactCell(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var tagFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RecipeTag.allCases) { tag in
                    AppTagChip(
                        title: tag.rawValue,
                        icon: tag.symbolName,
                        isSelected: viewModel.selectedTags.contains(tag)
                    ) { viewModel.toggleTag(tag) }
                }
            }
        }
    }

    private var sortControl: some View {
        Picker("Sort", selection: $viewModel.sortOption) {
            ForEach(RecipeSortOption.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.sortOption) { _ in
            HapticFeedback.lightTap()
            SystemSound.tick()
        }
    }
}
