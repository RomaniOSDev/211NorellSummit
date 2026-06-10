import Foundation
import Combine

final class AppStore: ObservableObject {
    static let shared = AppStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let favoriteRecipes = "favoriteRecipes"
        static let lastViewedCategory = "lastViewedCategory"
        static let recipesViewed = "recipesViewed"
        static let favouritesAdded = "favouritesAdded"
        static let viewedRecipeIDs = "viewedRecipeIDs"
        static let recentlyViewedRecipeIDs = "recentlyViewedRecipeIDs"
        static let pantryItems = "pantryItems"
        static let categoriesExpandedState = "categoriesExpandedState"
        static let listsCompleted = "listsCompleted"
        static let timers = "timers"
        static let timersFinished = "timersFinished"
        static let customRecipes = "customRecipes"
        static let mealPlanEntries = "mealPlanEntries"
        static let shoppingListItems = "shoppingListItems"
        static let recipeNotes = "recipeNotes"
        static let recipeCollections = "recipeCollections"
        static let cookedRecipeHistory = "cookedRecipeHistory"
        static let batchCookSessions = "batchCookSessions"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }
    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }
    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }
    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }
    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }
    @Published var favoriteRecipes: [String] {
        didSet { defaults.set(favoriteRecipes, forKey: Keys.favoriteRecipes) }
    }
    @Published var lastViewedCategory: String {
        didSet { defaults.set(lastViewedCategory, forKey: Keys.lastViewedCategory) }
    }
    @Published var recipesViewed: Int {
        didSet { defaults.set(recipesViewed, forKey: Keys.recipesViewed) }
    }
    @Published var favouritesAdded: Int {
        didSet { defaults.set(favouritesAdded, forKey: Keys.favouritesAdded) }
    }
    @Published var viewedRecipeIDs: Set<String> {
        didSet { defaults.set(Array(viewedRecipeIDs), forKey: Keys.viewedRecipeIDs) }
    }
    @Published var recentlyViewedRecipeIDs: [String] {
        didSet { defaults.set(recentlyViewedRecipeIDs, forKey: Keys.recentlyViewedRecipeIDs) }
    }
    @Published var pantryItems: [PantryItem] {
        didSet { saveArray(pantryItems, key: Keys.pantryItems) }
    }
    @Published var categoriesExpandedState: [String: Bool] {
        didSet { saveDictionary(categoriesExpandedState, key: Keys.categoriesExpandedState) }
    }
    @Published var listsCompleted: Int {
        didSet { defaults.set(listsCompleted, forKey: Keys.listsCompleted) }
    }
    @Published var timers: [CookingTimer] {
        didSet {
            guard !isSyncingTimers else { return }
            saveArray(timers, key: Keys.timers)
        }
    }
    @Published var timersFinished: Int {
        didSet { defaults.set(timersFinished, forKey: Keys.timersFinished) }
    }
    @Published var customRecipes: [Recipe] {
        didSet { saveArray(customRecipes, key: Keys.customRecipes) }
    }
    @Published var mealPlanEntries: [MealPlanEntry] {
        didSet { saveArray(mealPlanEntries, key: Keys.mealPlanEntries) }
    }
    @Published var shoppingListItems: [ShoppingListItem] {
        didSet { saveArray(shoppingListItems, key: Keys.shoppingListItems) }
    }
    @Published var recipeNotes: [String: String] {
        didSet { saveStringDictionary(recipeNotes, key: Keys.recipeNotes) }
    }
    @Published var recipeCollections: [RecipeCollection] {
        didSet { saveArray(recipeCollections, key: Keys.recipeCollections) }
    }
    @Published var cookedRecipeHistory: [CookedRecipeEntry] {
        didSet { saveArray(cookedRecipeHistory, key: Keys.cookedRecipeHistory) }
    }
    @Published var batchCookSessions: [BatchCookSession] {
        didSet { saveArray(batchCookSessions, key: Keys.batchCookSessions) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?
    private var achievementQueue: [AchievementDefinition] = []
    private var isSyncingTimers = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDateDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        favoriteRecipes = defaults.stringArray(forKey: Keys.favoriteRecipes) ?? []
        lastViewedCategory = defaults.string(forKey: Keys.lastViewedCategory) ?? "All"
        recipesViewed = defaults.integer(forKey: Keys.recipesViewed)
        favouritesAdded = defaults.integer(forKey: Keys.favouritesAdded)
        viewedRecipeIDs = Set(defaults.stringArray(forKey: Keys.viewedRecipeIDs) ?? [])
        recentlyViewedRecipeIDs = defaults.stringArray(forKey: Keys.recentlyViewedRecipeIDs) ?? []
        pantryItems = Self.loadArray(key: Keys.pantryItems, defaults: defaults)
        categoriesExpandedState = Self.loadBoolDictionary(key: Keys.categoriesExpandedState, defaults: defaults)
        listsCompleted = defaults.integer(forKey: Keys.listsCompleted)
        timers = Self.loadArray(key: Keys.timers, defaults: defaults)
        timersFinished = defaults.integer(forKey: Keys.timersFinished)
        customRecipes = Self.loadArray(key: Keys.customRecipes, defaults: defaults)
        mealPlanEntries = Self.loadArray(key: Keys.mealPlanEntries, defaults: defaults)
        shoppingListItems = Self.loadArray(key: Keys.shoppingListItems, defaults: defaults)
        recipeNotes = Self.loadStringDictionary(key: Keys.recipeNotes, defaults: defaults)
        recipeCollections = Self.loadArray(key: Keys.recipeCollections, defaults: defaults)
        cookedRecipeHistory = Self.loadArray(key: Keys.cookedRecipeHistory, defaults: defaults)
        batchCookSessions = Self.loadArray(key: Keys.batchCookSessions, defaults: defaults)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataReset), name: .dataReset, object: nil
        )
        evaluateAchievements()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Recipe access

    func allRecipes() -> [Recipe] {
        RecipeRepository.allRecipes(custom: customRecipes)
    }

    func recipe(id: String) -> Recipe? {
        RecipeRepository.recipe(id: id, custom: customRecipes)
    }

    // MARK: - Activity

    @objc private func handleDataReset() { reloadFromDefaults() }

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity(minutes: 1)
    }

    func recordActivity(minutes: Int = 1) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 { streakDays += 1 }
            else if dayDiff > 1 { streakDays = 1 }
        } else { streakDays = 1 }
        lastActivityDate = today
        totalSessionsCompleted += 1
        totalMinutesUsed += minutes
        evaluateAchievements()
    }

    func markRecipeViewed(_ recipeID: String) {
        var recent = recentlyViewedRecipeIDs.filter { $0 != recipeID }
        recent.insert(recipeID, at: 0)
        recentlyViewedRecipeIDs = Array(recent.prefix(20))
        if !viewedRecipeIDs.contains(recipeID) {
            viewedRecipeIDs.insert(recipeID)
            recipesViewed += 1
        }
        recordActivity(minutes: 1)
        evaluateAchievements()
    }

    func markRecipeCooked(_ recipeID: String) {
        cookedRecipeHistory.insert(
            CookedRecipeEntry(id: UUID().uuidString, recipeID: recipeID, cookedDate: Date()),
            at: 0
        )
        recordActivity(minutes: 5)
    }

    func cookedRecipes(limit: Int = 10) -> [Recipe] {
        var seen = Set<String>()
        var result: [Recipe] = []
        for entry in cookedRecipeHistory {
            guard !seen.contains(entry.recipeID), let recipe = recipe(id: entry.recipeID) else { continue }
            seen.insert(entry.recipeID)
            result.append(recipe)
            if result.count >= limit { break }
        }
        return result
    }

    func recentlyViewedRecipes(limit: Int = 10) -> [Recipe] {
        recentlyViewedRecipeIDs.prefix(limit).compactMap { recipe(id: $0) }
    }

    func toggleFavorite(recipeID: String) -> Bool {
        if favoriteRecipes.contains(recipeID) {
            favoriteRecipes.removeAll { $0 == recipeID }
            return false
        }
        favoriteRecipes.append(recipeID)
        favouritesAdded += 1
        recordActivity(minutes: 1)
        evaluateAchievements()
        return true
    }

    func isFavorite(recipeID: String) -> Bool { favoriteRecipes.contains(recipeID) }

    // MARK: - Custom recipes

    func addCustomRecipe(_ recipe: Recipe) {
        customRecipes.append(recipe)
        recordActivity(minutes: 3)
    }

    func updateCustomRecipe(_ recipe: Recipe) {
        guard let index = customRecipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        customRecipes[index] = recipe
    }

    func deleteCustomRecipe(id: String) {
        customRecipes.removeAll { $0.id == id }
        mealPlanEntries.removeAll { $0.recipeID == id }
        recipeCollections = recipeCollections.map { collection in
            var updated = collection
            updated.recipeIDs.removeAll { $0 == id }
            return updated
        }
    }

    // MARK: - Meal plan

    func setMealPlan(recipeID: String, day: Date, slot: MealSlot) {
        let dayStart = Calendar.current.startOfDay(for: day)
        mealPlanEntries.removeAll { Calendar.current.isDate($0.dayStart, inSameDayAs: dayStart) && $0.slot == slot }
        mealPlanEntries.append(MealPlanEntry(id: UUID().uuidString, dayStart: dayStart, slot: slot, recipeID: recipeID))
        recordActivity(minutes: 2)
    }

    func clearMealPlan(day: Date, slot: MealSlot) {
        let dayStart = Calendar.current.startOfDay(for: day)
        mealPlanEntries.removeAll { Calendar.current.isDate($0.dayStart, inSameDayAs: dayStart) && $0.slot == slot }
    }

    func mealPlanEntry(day: Date, slot: MealSlot) -> MealPlanEntry? {
        let dayStart = Calendar.current.startOfDay(for: day)
        return mealPlanEntries.first { Calendar.current.isDate($0.dayStart, inSameDayAs: dayStart) && $0.slot == slot }
    }

    func weekDays(startingFrom weekStart: Date) -> [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStart) }
    }

    func startOfWeek(containing date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? Calendar.current.startOfDay(for: date)
    }

    // MARK: - Shopping list

    func addRecipeToShoppingList(_ recipe: Recipe, servings: Int) {
        let scaled = IngredientScaler.scaledIngredients(
            recipe.ingredients, from: recipe.defaultServings, to: servings
        )
        for name in scaled {
            guard !PantryMatcher.isAvailableInPantry(ingredient: name, pantryItems: pantryItems) else { continue }
            let exists = shoppingListItems.contains {
                $0.name.lowercased() == name.lowercased() && !$0.isChecked
            }
            guard !exists else { continue }
            shoppingListItems.append(
                ShoppingListItem(id: UUID().uuidString, name: name, recipeID: recipe.id, isChecked: false)
            )
        }
        recordActivity(minutes: 2)
    }

    func toggleShoppingItem(_ id: String) {
        guard let index = shoppingListItems.firstIndex(where: { $0.id == id }) else { return }
        shoppingListItems[index].isChecked.toggle()
        HapticFeedback.lightTap()
    }

    func removeShoppingItem(_ id: String) {
        shoppingListItems.removeAll { $0.id == id }
    }

    func clearCheckedShoppingItems() {
        shoppingListItems.removeAll { $0.isChecked }
    }

    func uncheckedShoppingCount() -> Int {
        shoppingListItems.filter { !$0.isChecked }.count
    }

    // MARK: - Notes & collections

    func note(for recipeID: String) -> String { recipeNotes[recipeID] ?? "" }

    func setNote(_ text: String, for recipeID: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            recipeNotes.removeValue(forKey: recipeID)
        } else {
            recipeNotes[recipeID] = text
        }
    }

    func addCollection(name: String) {
        recipeCollections.append(RecipeCollection(
            id: UUID().uuidString, name: name, recipeIDs: [], createdDate: Date()
        ))
    }

    func addRecipe(_ recipeID: String, toCollection collectionID: String) {
        guard let index = recipeCollections.firstIndex(where: { $0.id == collectionID }) else { return }
        guard !recipeCollections[index].recipeIDs.contains(recipeID) else { return }
        recipeCollections[index].recipeIDs.append(recipeID)
    }

    func removeRecipe(_ recipeID: String, fromCollection collectionID: String) {
        guard let index = recipeCollections.firstIndex(where: { $0.id == collectionID }) else { return }
        recipeCollections[index].recipeIDs.removeAll { $0 == recipeID }
    }

    func deleteCollection(id: String) {
        recipeCollections.removeAll { $0.id == id }
    }

    // MARK: - Batch cooking

    func addBatchSession(_ session: BatchCookSession) {
        batchCookSessions.insert(session, at: 0)
        recordActivity(minutes: 3)
    }

    func updateBatchSession(_ session: BatchCookSession) {
        guard let index = batchCookSessions.firstIndex(where: { $0.id == session.id }) else { return }
        batchCookSessions[index] = session
    }

    func completeBatchSession(_ sessionID: String) {
        guard let index = batchCookSessions.firstIndex(where: { $0.id == sessionID }) else { return }
        batchCookSessions[index].isCompleted = true
        for recipeID in batchCookSessions[index].recipeIDs {
            markRecipeCooked(recipeID)
        }
        HapticFeedback.success()
        SystemSound.success()
    }

    func startBatchTimers(for session: BatchCookSession) {
        var newTimers = timers
        for recipeID in session.recipeIDs {
            guard let recipe = recipe(id: recipeID) else { continue }
            newTimers.append(CookingTimer(
                id: UUID().uuidString, name: recipe.title,
                durationSeconds: recipe.cookTimeMinutes * 60,
                remainingSeconds: recipe.cookTimeMinutes * 60,
                endDate: nil, isRunning: false, isPaused: false
            ))
        }
        timers = newTimers
        HapticFeedback.mediumTap()
    }

    // MARK: - Pantry

    func completeShoppingList() {
        let outOfStock = pantryItems.filter { $0.status == .outOfStock }
        guard !outOfStock.isEmpty else { return }
        pantryItems = pantryItems.map { item in
            var updated = item
            if updated.status == .outOfStock { updated.status = .inStock }
            return updated
        }
        listsCompleted += 1
        recordActivity(minutes: 5)
        evaluateAchievements()
    }

    func outOfStockCount() -> Int { pantryItems.filter { $0.status == .outOfStock }.count }

    func expiringSoonItems(withinDays days: Int = 7) -> [PantryItem] {
        let limit = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return pantryItems.filter { item in
            guard let expiry = item.expiryDate, item.status == .inStock else { return false }
            return expiry <= limit
        }.sorted { ($0.expiryDate ?? Date()) < ($1.expiryDate ?? Date()) }
    }

    func expiringSoonCount(withinDays days: Int = 7) -> Int { expiringSoonItems(withinDays: days).count }

    // MARK: - Timers

    func addTimer(_ timer: CookingTimer) {
        timers = timers + [timer]
        recordActivity(minutes: 1)
    }

    func updateTimer(_ timer: CookingTimer) {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        var updated = timers
        updated[index] = timer
        timers = updated
    }

    func deleteTimer(id: String) {
        timers = timers.filter { $0.id != id }
    }

    func startCookingTimer(id: String) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        var updated = timers
        updated[index].isRunning = true
        updated[index].isPaused = false
        updated[index].endDate = Date().addingTimeInterval(TimeInterval(updated[index].remainingSeconds))
        timers = updated
    }

    func pauseCookingTimer(id: String) {
        guard let index = timers.firstIndex(where: { $0.id == id }),
              let endDate = timers[index].endDate else { return }
        var updated = timers
        updated[index].remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow))
        updated[index].isRunning = false
        updated[index].isPaused = true
        updated[index].endDate = nil
        timers = updated
    }

    @discardableResult
    func refreshRunningTimers(now: Date = Date()) -> Bool {
        guard timers.contains(where: \.isRunning) else { return false }

        var updated = timers
        var expiredIDs: [String] = []

        for index in updated.indices {
            guard updated[index].isRunning, let endDate = updated[index].endDate else { continue }
            let remaining = max(0, Int(endDate.timeIntervalSince(now)))
            updated[index].remainingSeconds = remaining
            if remaining <= 0 {
                expiredIDs.append(updated[index].id)
            }
        }

        let hasExpired = !expiredIDs.isEmpty
        if hasExpired {
            updated.removeAll { expiredIDs.contains($0.id) }
        }

        isSyncingTimers = true
        timers = updated
        isSyncingTimers = false

        if hasExpired {
            saveArray(timers, key: Keys.timers)
            timersFinished += expiredIDs.count
            recordActivity(minutes: 3)
            evaluateAchievements()
            return true
        }

        return false
    }

    func finishTimer(id: String) {
        timers = timers.filter { $0.id != id }
        timersFinished += 1
        recordActivity(minutes: 3)
        evaluateAchievements()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func isAchievementUnlocked(_ id: String) -> Bool { achievementsUnlocked[id] != nil }
    func unlockedAchievementCount() -> Int { achievementsUnlocked.count }

    func dismissAchievementBanner() {
        pendingAchievementBanner = nil
        if !achievementQueue.isEmpty { pendingAchievementBanner = achievementQueue.removeFirst() }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDateDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        favoriteRecipes = defaults.stringArray(forKey: Keys.favoriteRecipes) ?? []
        lastViewedCategory = defaults.string(forKey: Keys.lastViewedCategory) ?? "All"
        recipesViewed = defaults.integer(forKey: Keys.recipesViewed)
        favouritesAdded = defaults.integer(forKey: Keys.favouritesAdded)
        viewedRecipeIDs = Set(defaults.stringArray(forKey: Keys.viewedRecipeIDs) ?? [])
        recentlyViewedRecipeIDs = defaults.stringArray(forKey: Keys.recentlyViewedRecipeIDs) ?? []
        pantryItems = Self.loadArray(key: Keys.pantryItems, defaults: defaults)
        categoriesExpandedState = Self.loadBoolDictionary(key: Keys.categoriesExpandedState, defaults: defaults)
        listsCompleted = defaults.integer(forKey: Keys.listsCompleted)
        timers = Self.loadArray(key: Keys.timers, defaults: defaults)
        timersFinished = defaults.integer(forKey: Keys.timersFinished)
        customRecipes = Self.loadArray(key: Keys.customRecipes, defaults: defaults)
        mealPlanEntries = Self.loadArray(key: Keys.mealPlanEntries, defaults: defaults)
        shoppingListItems = Self.loadArray(key: Keys.shoppingListItems, defaults: defaults)
        recipeNotes = Self.loadStringDictionary(key: Keys.recipeNotes, defaults: defaults)
        recipeCollections = Self.loadArray(key: Keys.recipeCollections, defaults: defaults)
        cookedRecipeHistory = Self.loadArray(key: Keys.cookedRecipeHistory, defaults: defaults)
        batchCookSessions = Self.loadArray(key: Keys.batchCookSessions, defaults: defaults)
        pendingAchievementBanner = nil
        achievementQueue = []
    }

    private func evaluateAchievements() {
        let conditions: [(String, Bool)] = [
            ("first_dish", recipesViewed >= 1),
            ("recipe_explorer", recipesViewed >= 10),
            ("chefs_choice", favouritesAdded >= 5),
            ("culinary_enthusiast", favouritesAdded >= 20),
            ("pantry_master", listsCompleted >= 1),
            ("shopping_expert", listsCompleted >= 5),
            ("timing_perfectionist", timersFinished >= 1),
            ("timekeeper_pro", timersFinished >= 10)
        ]
        for (id, met) in conditions where met && achievementsUnlocked[id] == nil {
            unlockAchievement(id: id)
        }
    }

    private func unlockAchievement(id: String) {
        achievementsUnlocked[id] = Date()
        guard let achievement = AchievementDefinition.all.first(where: { $0.id == id }) else { return }
        if pendingAchievementBanner == nil { pendingAchievementBanner = achievement }
        else { achievementQueue.append(achievement) }
    }

    private func saveArray<T: Codable>(_ value: [T], key: String) {
        if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
    }

    private func saveDictionary(_ value: [String: Date], key: String) {
        if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
    }

    private func saveDictionary(_ value: [String: Bool], key: String) {
        if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
    }

    private func saveStringDictionary(_ value: [String: String], key: String) {
        if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
    }

    private static func loadArray<T: Codable>(key: String, defaults: UserDefaults) -> [T] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return decoded
    }

    private static func loadDateDictionary(key: String, defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else { return [:] }
        return decoded
    }

    private static func loadBoolDictionary(key: String, defaults: UserDefaults) -> [String: Bool] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) else { return [:] }
        return decoded
    }

    private static func loadStringDictionary(key: String, defaults: UserDefaults) -> [String: String] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        return decoded
    }
}
