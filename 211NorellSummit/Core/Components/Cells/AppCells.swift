import SwiftUI

// MARK: - Recipe Cells

struct RecipeGridCell: View {
    let recipe: Recipe
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppBackground"), Color("AppPrimary").opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppVisualStyle.cardTopSheen)
                    }
                    .frame(height: 96)
                    .overlay(
                        Image(systemName: recipe.symbolName)
                            .font(.system(size: 36))
                            .foregroundStyle(Color("AppAccent"))
                    )

                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(6)
                        .background(Color("AppPrimary"))
                        .clipShape(Circle())
                        .padding(8)
                }

                HStack(spacing: 4) {
                    MetaPill(icon: "clock.fill", text: "\(recipe.cookTimeMinutes)m")
                    if recipe.isCustom {
                        MetaPill(icon: "person.fill", text: "Yours")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(8)
            }

            Text(recipe.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(recipe.description)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            if !recipe.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(recipe.tags.prefix(2)) { tag in
                        Text(tag.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color("AppBackground"))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .appCard(cornerRadius: 18, elevation: .medium)
    }
}

struct RecipeCompactCell: View {
    let recipe: Recipe
    var width: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppBackground"), Color("AppPrimary").opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width - 16, height: 72)
                Image(systemName: recipe.symbolName)
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
            }

            Text(recipe.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(width: width - 16, alignment: .leading)

            MetaPill(icon: "clock", text: "\(recipe.cookTimeMinutes) min")
        }
        .padding(10)
        .frame(width: width)
        .appCard(cornerRadius: 14)
    }
}

struct RecipeListCell: View {
    let recipe: Recipe
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: recipe.symbolName, size: 48, iconSize: .body)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 8) {
                    MetaPill(icon: "clock", text: "\(recipe.cookTimeMinutes) min")
                    MetaPill(icon: "star.fill", text: String(format: "%.1f", recipe.rating))
                }
            }

            Spacer(minLength: 0)

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .appCard(cornerRadius: 14, elevation: .soft)
    }
}

struct IngredientCell: View {
    let name: String
    let isInPantry: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isInPantry ? Color("AppPrimary").opacity(0.25) : Color("AppBackground"))
                    .frame(width: 28, height: 28)
                Image(systemName: isInPantry ? "checkmark" : "circle")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isInPantry ? Color("AppAccent") : Color("AppTextSecondary"))
            }
            Text(name)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if isInPantry {
                Text("In Pantry")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .padding(.vertical, 4)
    }
}

struct StepCell: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.black))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 28, height: 28)
                .background(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Pantry & Shopping

struct PantryItemCell: View {
    let item: PantryItem
    let categoryIcon: String

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: categoryIcon, size: 42, iconSize: .callout)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(item.quantity)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                if let expiry = item.expiryDate {
                    Text("Exp: \(expiry.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                }
            }

            Spacer(minLength: 0)

            StatusBadge(
                text: item.status.rawValue,
                isPositive: item.status == .inStock
            )
        }
        .padding(14)
        .appCard(cornerRadius: 14, elevation: .soft)
    }
}

struct ExpiringItemCell: View {
    let item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let expiry = item.expiryDate {
                    Text("Expires \(expiry.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                }
            }

            Spacer()

            Text(item.quantity)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.18), Color("AppAccent").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppVisualStyle.cardTopSheen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color("AppAccent").opacity(0.35), lineWidth: 1)
                }
        }
        .compositingGroup()
        .appSoftElevation(.soft)
    }
}

struct ShoppingItemCell: View {
    let item: ShoppingListItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(item.isChecked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4), lineWidth: 2)
                    .frame(width: 26, height: 26)
                if item.isChecked {
                    Circle()
                        .fill(Color("AppAccent"))
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(item.isChecked ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(item.isChecked)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                if item.recipeID != nil {
                    Text("From recipe")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Timer

struct TimerCell: View {
    let timer: CookingTimer
    let onPlayPause: () -> Void
    let onEdit: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            timerContent(at: timeline.date)
        }
    }

    private func timerContent(at date: Date) -> some View {
        let remaining = timer.remainingSeconds(at: date)
        let progress = timer.progress(at: date)
        let formattedTime = String(format: "%02d:%02d", remaining / 60, remaining % 60)

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color("AppBackground"), lineWidth: 5)
                    .frame(width: 58, height: 58)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        timer.isRunning ? Color("AppAccent") : Color("AppPrimary"),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 58, height: 58)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(timer.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(formattedTime)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(timer.isRunning ? Color("AppAccent") : Color("AppTextSecondary"))
                    .monospacedDigit()
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Button(action: onPlayPause) {
                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(AppVisualStyle.primaryButton)
                                .overlay { Circle().fill(AppVisualStyle.primaryButtonSheen) }
                        }
                }
                .buttonStyle(PressableButtonStyle())

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(width: 44, height: 44)
                        .background(Color("AppBackground"))
                        .clipShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(16)
        .appCard(elevation: .medium)
    }
}

// MARK: - Meal Plan

struct MealPlanCell: View {
    let recipe: Recipe?
    let slot: MealSlot
    let isToday: Bool
    let hasEntry: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(hasEntry ? Color("AppPrimary").opacity(0.2) : Color("AppSurface"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isToday ? Color("AppAccent").opacity(0.6) : Color("AppAccent").opacity(hasEntry ? 0.3 : 0.1),
                            lineWidth: isToday ? 2 : 1
                        )
                )

            if let recipe {
                VStack(spacing: 4) {
                    Image(systemName: recipe.symbolName)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(recipe.title)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                }
                .padding(4)
            } else {
                VStack(spacing: 3) {
                    Image(systemName: slot.symbolName)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.4))
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.35))
                }
            }
        }
        .frame(minHeight: 58)
    }
}

struct MealPlanPaletteCell: View {
    let recipe: Recipe

    var body: some View {
        VStack(spacing: 6) {
            AppIconBadge(symbol: recipe.symbolName, size: 40, iconSize: .callout)
            Text(recipe.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .frame(width: 76)
        }
        .padding(10)
        .appCard(cornerRadius: 12)
    }
}

// MARK: - Collections & Batch

struct CollectionCell: View {
    let collection: RecipeCollection

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.3), Color("AppBackground")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "book.closed.fill")
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(collection.recipeIDs.count) recipes")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .appCard(elevation: .medium)
    }
}

struct BatchSelectCell: View {
    let recipe: Recipe
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                if isSelected {
                    Circle()
                        .fill(Color("AppPrimary"))
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }

            AppIconBadge(symbol: recipe.symbolName, size: 44, iconSize: .body)

            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                MetaPill(icon: "clock", text: "\(recipe.cookTimeMinutes) min")
            }

            Spacer()
        }
        .padding(14)
        .appCard(cornerRadius: 14, elevation: .soft)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color("AppPrimary").opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

struct BatchSessionCell: View {
    let session: BatchCookSession

    private var stepsLeft: Int {
        session.timelineSteps.filter { !$0.isCompleted }.count
    }

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: "flame.fill", size: 48, iconSize: .body)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(session.recipeIDs.count) recipes · \(stepsLeft) steps left")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .appCard(elevation: .medium)
    }
}

struct BatchTimelineCell: View {
    let step: BatchTimelineStep
    let isLast: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(step.isCompleted ? Color("AppAccent") : Color("AppPrimary"))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color("AppTextPrimary").opacity(0.2), lineWidth: 2)
                    )
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppAccent").opacity(0.5), Color("AppTextSecondary").opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 14)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(step.recipeTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                    Spacer()
                    MetaPill(icon: "clock", text: "\(step.durationMinutes) min")
                }

                Text(step.instruction)
                    .font(.subheadline)
                    .foregroundStyle(step.isCompleted ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(step.isCompleted)

                if let hint = step.parallelHint {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.caption2)
                        Text(hint)
                            .font(.caption2)
                            .italic()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                    .padding(8)
                    .background(Color("AppPrimary").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                if !step.isCompleted {
                    Button(action: onComplete) {
                        Text("Mark Done")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color("AppPrimary"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard(cornerRadius: 14)
        }
    }
}

// MARK: - Settings & Achievements

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isDestructive ? Color.red.opacity(0.15) : Color("AppPrimary").opacity(0.2))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(isDestructive ? .red : Color("AppAccent"))
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    let unlockedDate: Date?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppVisualStyle.glowRing(isActive: isUnlocked))
                    .frame(width: 72, height: 72)
                Circle()
                    .fill(
                        isUnlocked
                            ? AppVisualStyle.primaryButton
                            : LinearGradient(colors: [Color("AppBackground"), Color("AppBackground")], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 56, height: 56)
                    .overlay {
                        if isUnlocked {
                            Circle().fill(AppVisualStyle.primaryButtonSheen)
                        }
                    }
                Image(systemName: achievement.symbolName)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.4))
            }
            .compositingGroup()
            .appSoftElevation(isUnlocked ? .soft : .soft)

            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            if isUnlocked, let date = unlockedDate {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("AppAccent").opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 170)
        .appCard()
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

struct RecipeHeroHeader: View {
    let recipe: Recipe

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppSurface"), Color("AppPrimary").opacity(0.25), Color("AppBackground").opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppVisualStyle.cardTopSheen)
                }
                .frame(height: 180)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppVisualStyle.glowRing(isActive: true))
                        .frame(width: 100, height: 100)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppBackground").opacity(0.6), Color("AppPrimary").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay {
                            Circle().strokeBorder(Color("AppAccent").opacity(0.25), lineWidth: 1)
                        }
                    Image(systemName: recipe.symbolName)
                        .font(.system(size: 40))
                        .foregroundStyle(Color("AppAccent"))
                }
                .compositingGroup()
                .appSoftElevation(.medium)

                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .appHeroCard(cornerRadius: 20)
    }
}
