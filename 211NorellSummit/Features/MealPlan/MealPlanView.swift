import SwiftUI

struct MealPlanView: View {
    @EnvironmentObject private var store: AppStore
    @State private var weekOffset = 0
    @State private var pickerSlot: MealSlot?
    @State private var pickerDay: Date?
    @State private var showRecipePicker = false

    private var weekStart: Date {
        let base = store.startOfWeek(containing: Date())
        return Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: base) ?? base
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                weekNavigation
                weekGrid
                recipePalette
            }
            .appScreenInsets()
        }
        .sheet(isPresented: $showRecipePicker) {
            RecipePickerSheet { recipe in
                if let day = pickerDay, let slot = pickerSlot {
                    store.setMealPlan(recipeID: recipe.id, day: day, slot: slot)
                    triggerSuccessFeedback()
                }
            }
        }
    }

    private var weekNavigation: some View {
        HStack {
            Button {
                HapticFeedback.lightTap()
                withAnimation { weekOffset -= 1 }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
            }

            VStack(spacing: 2) {
                Text(weekTitle)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if weekOffset == 0 {
                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                HapticFeedback.lightTap()
                withAnimation { weekOffset += 1 }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
            }
        }
        .padding(14)
        .appCard()
    }

    private var weekTitle: String {
        let days = store.weekDays(startingFrom: weekStart)
        guard let first = days.first, let last = days.last else { return "Week" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first)) – \(f.string(from: last))"
    }

    private var weekGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                Color.clear.frame(width: 64)
                ForEach(store.weekDays(startingFrom: weekStart), id: \.self) { day in
                    VStack(spacing: 3) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.caption2.weight(.medium))
                        Text(day.formatted(.dateTime.day()))
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(Calendar.current.isDateInToday(day) ? Color("AppAccent") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Calendar.current.isDateInToday(day) ? Color("AppAccent").opacity(0.12) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }

            ForEach(MealSlot.allCases) { slot in
                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: slot.symbolName)
                            .font(.caption2)
                        Text(slot.rawValue)
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(width: 64, alignment: .leading)

                    ForEach(store.weekDays(startingFrom: weekStart), id: \.self) { day in
                        mealCell(day: day, slot: slot)
                    }
                }
            }
        }
        .padding(12)
        .appCard()
    }

    private func mealCell(day: Date, slot: MealSlot) -> some View {
        let entry = store.mealPlanEntry(day: day, slot: slot)
        let recipe = entry.flatMap { store.recipe(id: $0.recipeID) }

        return MealPlanCell(
            recipe: recipe,
            slot: slot,
            isToday: Calendar.current.isDateInToday(day),
            hasEntry: entry != nil
        )
        .frame(maxWidth: .infinity)
        .onTapGesture {
            HapticFeedback.lightTap()
            pickerDay = day
            pickerSlot = slot
            showRecipePicker = true
        }
        .dropDestination(for: String.self) { items, _ in
            guard let recipeID = items.first else { return false }
            store.setMealPlan(recipeID: recipeID, day: day, slot: slot)
            HapticFeedback.mediumTap()
            SystemSound.success()
            return true
        }
        .contextMenu {
            if entry != nil {
                Button("Clear", role: .destructive) { store.clearMealPlan(day: day, slot: slot) }
            }
        }
    }

    private var recipePalette: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Drag to Plan", icon: "hand.draw.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.allRecipes().prefix(10)) { recipe in
                        MealPlanPaletteCell(recipe: recipe)
                            .draggable(recipe.id)
                    }
                }
            }
        }
    }
}

struct RecipePickerSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Recipe) -> Void

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.allRecipes()) { recipe in
                            Button {
                                HapticFeedback.lightTap()
                                onSelect(recipe)
                                dismiss()
                            } label: {
                                RecipeListCell(recipe: recipe, showChevron: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .appScreenInsets()
                }
            }
            .navigationTitle("Pick Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
