import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case recipes, kitchen, achievements, settings
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .recipes: return "Home"
        case .kitchen: return "Kitchen"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }
    var symbolName: String {
        switch self {
        case .recipes: return "house.fill"
        case .kitchen: return "refrigerator.fill"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab: AppTab = .recipes
    @State private var pressedTab: AppTab?
    @State private var recipesSection: RecipeBrowseSection = .home
    @State private var kitchenSection: KitchenSection = .pantry

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                tabContent
                customTabBar
            }
        }
        .achievementBanner()
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .recipes:
            RecipesRootView(section: $recipesSection, onHomeNavigate: handleHomeNavigation)
        case .kitchen:
            NavigationStack {
                KitchenHubView(selectedSection: $kitchenSection)
            }
        case .achievements:
            AchievementsView()
        case .settings:
            SettingsView()
        }
    }

    private func handleHomeNavigation(_ destination: HomeDestination) {
        switch destination {
        case .browse:
            recipesSection = .browse
        case .mealPlan:
            recipesSection = .plan
        case .pantry:
            kitchenSection = .pantry
            selectedTab = .kitchen
        case .shopping:
            kitchenSection = .shop
            selectedTab = .kitchen
        case .timers:
            kitchenSection = .alarms
            selectedTab = .kitchen
        case .quickAction(let action):
            switch action {
            case .browse:
                recipesSection = .browse
            case .plan:
                recipesSection = .plan
            case .pantry:
                kitchenSection = .pantry
                selectedTab = .kitchen
            case .timer:
                kitchenSection = .alarms
                selectedTab = .kitchen
            }
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            AppVisualStyle.tabBarSurface
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppAccent").opacity(0.2), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        }
        .compositingGroup()
        .shadow(color: Color("AppBackground").opacity(0.45), radius: 10, y: -4)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        let badgeCount = tab == .kitchen ? store.expiringSoonCount() : 0

        return Button {
            HapticFeedback.lightTap()
            SystemSound.tick()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedTab = tab }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 5) {
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color("AppPrimary").opacity(0.2))
                                .frame(width: 36, height: 36)
                        }
                        Image(systemName: tab.symbolName)
                            .font(.system(size: isSelected ? 22 : 20, weight: isSelected ? .semibold : .regular))
                    }
                    Text(tab.title)
                        .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected
                              ? AppVisualStyle.primaryButton
                              : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom))
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppVisualStyle.primaryButtonSheen)
                            }
                        }
                )
                .compositingGroup()
                .shadow(color: isSelected ? Color("AppPrimary").opacity(0.35) : .clear, radius: 6, y: 3)
                .scaleEffect(pressedTab == tab ? 0.94 : 1)

                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Color("AppAccent"))
                        .clipShape(Capsule())
                        .offset(x: 6, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }
}
