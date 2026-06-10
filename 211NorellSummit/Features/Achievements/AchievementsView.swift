import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 20) {
                        StatsSummaryCard(items: [
                            (value: "\(store.unlockedAchievementCount())/8", label: "Unlocked", icon: "rosette"),
                            (value: "\(store.recipesViewed)", label: "Viewed", icon: "eye.fill"),
                            (value: "\(store.streakDays)d", label: "Streak", icon: "flame.fill")
                        ])

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(AchievementDefinition.all) { achievement in
                                AchievementCell(
                                    achievement: achievement,
                                    isUnlocked: store.isAchievementUnlocked(achievement.id),
                                    unlockedDate: store.achievementsUnlocked[achievement.id]
                                )
                            }
                        }
                    }
                    .appScreenInsets()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
