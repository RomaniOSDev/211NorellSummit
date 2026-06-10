import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showNewCollection = false
    @State private var newCollectionName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if store.recipeCollections.isEmpty {
                    AppEmptyState(
                        icon: "books.vertical.fill",
                        title: "Create your first cookbook",
                        message: "Organize recipes into custom collections.",
                        buttonTitle: "New Collection"
                    ) { showNewCollection = true }
                } else {
                    ForEach(store.recipeCollections) { collection in
                        NavigationLink { CollectionDetailView(collection: collection) } label: {
                            CollectionCell(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .appScreenInsets()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.lightTap()
                    showNewCollection = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .alert("New Collection", isPresented: $showNewCollection) {
            TextField("Name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { newCollectionName = "" }
            Button("Create") {
                let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                store.addCollection(name: name)
                newCollectionName = ""
                HapticFeedback.mediumTap()
            }
        }
    }
}

struct CollectionDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let collection: RecipeCollection
    @State private var showAddRecipe = false

    private var currentCollection: RecipeCollection? {
        store.recipeCollections.first { $0.id == collection.id }
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                let recipes = (currentCollection?.recipeIDs ?? []).compactMap { store.recipe(id: $0) }
                if recipes.isEmpty {
                    AppEmptyState(
                        icon: "book.closed",
                        title: "No recipes yet",
                        message: "Add recipes to this collection from the menu.",
                        buttonTitle: "Add Recipe"
                    ) { showAddRecipe = true }
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeListCell(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Remove", role: .destructive) {
                                    store.removeRecipe(recipe.id, fromCollection: collection.id)
                                }
                            }
                        }
                    }
                    .appScreenInsets()
                }
            }
        }
        .navigationTitle(currentCollection?.name ?? collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Recipe") { showAddRecipe = true }
                    Button("Delete Collection", role: .destructive) {
                        store.deleteCollection(id: collection.id)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            RecipePickerSheet { recipe in
                store.addRecipe(recipe.id, toCollection: collection.id)
                HapticFeedback.mediumTap()
            }
        }
    }
}
