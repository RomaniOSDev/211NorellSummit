import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = HomeViewModel()
    var onNavigate: (HomeDestination) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroBanner
                statsRow
                quickActions
                todaysMealsWidget
                featuredRecipeWidget
                alertsRow
                if let timer = viewModel.nextTimer(from: store) {
                    activeTimerWidget(timer)
                }
            }
            .appScreenInsets(bottom: 24)
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.greeting())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text("What's cooking today?")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(viewModel.formattedDate())
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(18)
        }
        .frame(height: 200)
        .appHeroCard(cornerRadius: 20)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            miniStat(value: "\(store.streakDays)", label: "Day Streak", icon: "flame.fill")
            miniStat(value: "\(store.recipesViewed)", label: "Recipes", icon: "eye.fill")
            miniStat(value: "\(store.uncheckedShoppingCount())", label: "To Buy", icon: "cart.fill")
        }
    }

    private func miniStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .appCard(cornerRadius: 14, elevation: .soft)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", icon: "bolt.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(HomeQuickAction.allCases) { action in
                    Button {
                        HapticFeedback.lightTap()
                        onNavigate(.quickAction(action))
                    } label: {
                        HStack(spacing: 10) {
                            AppIconBadge(symbol: action.icon, size: 36, iconSize: .caption)
                            Text(action.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .appCard(cornerRadius: 12)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    // MARK: - Today's Meals Widget

    private var todaysMealsWidget: some View {
        Button {
            HapticFeedback.lightTap()
            onNavigate(.mealPlan)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Today's Meals", icon: "calendar")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                HStack(spacing: 12) {
                    Image("WidgetMeals")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(spacing: 8) {
                        ForEach(viewModel.todaysMeals(from: store), id: \.slot.id) { item in
                            HStack(spacing: 8) {
                                Image(systemName: item.slot.symbolName)
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppAccent"))
                                    .frame(width: 16)
                                Text(item.slot.rawValue)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .frame(width: 62, alignment: .leading)
                                Text(item.recipe?.title ?? "Not planned")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(item.recipe != nil ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.6))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .appCard(elevation: .medium)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Featured Recipe Widget

    private var featuredRecipeWidget: some View {
        Group {
            if let recipe = viewModel.featuredRecipe(from: store) {
                NavigationLink(value: recipe) {
                    featuredRecipeContent(recipe)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func featuredRecipeContent(_ recipe: Recipe) -> some View {
        HStack(spacing: 0) {
            Image("WidgetFeatured")
                .resizable()
                .scaledToFill()
                .frame(width: 120)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text("Featured Recipe")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 6) {
                    MetaPill(icon: "clock", text: "\(recipe.cookTimeMinutes) min")
                    MetaPill(icon: "star.fill", text: String(format: "%.1f", recipe.rating))
                }
                Text("Tap to view recipe →")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(14)
            Spacer(minLength: 0)
        }
        .frame(minHeight: 120)
        .appCard(cornerRadius: 16)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Alerts Row

    private var alertsRow: some View {
        HStack(spacing: 10) {
            pantryAlertWidget
            shoppingAlertWidget
        }
    }

    private var pantryAlertWidget: some View {
        Button {
            HapticFeedback.lightTap()
            onNavigate(.pantry)
        } label: {
            HStack(spacing: 10) {
                Image("WidgetPantry")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Pantry")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    if store.expiringSoonCount() > 0 {
                        Text("\(store.expiringSoonCount()) expiring")
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                    } else {
                        Text("\(store.pantryItems.count) items")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .appCard(cornerRadius: 14)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var shoppingAlertWidget: some View {
        Button {
            HapticFeedback.lightTap()
            onNavigate(.shopping)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    AppIconBadge(symbol: "cart.fill", size: 36, iconSize: .caption)
                    Spacer()
                    if store.uncheckedShoppingCount() > 0 {
                        Text("\(store.uncheckedShoppingCount())")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("AppPrimary"))
                            .clipShape(Capsule())
                    }
                }
                Text("Shopping")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(store.uncheckedShoppingCount() > 0 ? "Items to buy" : "List empty")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard(cornerRadius: 14)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Active Timer Widget

    private func activeTimerWidget(_ timer: CookingTimer) -> some View {
        Button {
            HapticFeedback.lightTap()
            onNavigate(.timers)
        } label: {
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                let remaining = timer.remainingSeconds(at: timeline.date)
                let progress = timer.progress(at: timeline.date)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Color("AppBackground"), lineWidth: 4)
                            .frame(width: 48, height: 48)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(-90))
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Active Timer")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppAccent"))
                        Text(timer.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(formatTime(remaining))
                            .font(.title3.bold())
                            .foregroundStyle(timer.isRunning ? Color("AppAccent") : Color("AppTextSecondary"))
                            .monospacedDigit()
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(16)
                .appCard(elevation: .medium)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

enum HomeDestination {
    case browse
    case mealPlan
    case pantry
    case shopping
    case timers
    case quickAction(HomeQuickAction)
}
