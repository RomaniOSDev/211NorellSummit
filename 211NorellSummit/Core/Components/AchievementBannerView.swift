import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    @Binding var isVisible: Bool

    var body: some View {
        VStack {
            if isVisible {
                HStack(spacing: 12) {
                    Image(systemName: achievement.symbolName)
                        .font(.title2)
                        .foregroundStyle(Color("AppTextPrimary"))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                        Text(achievement.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .appCard(cornerRadius: 14, elevation: .raised)
                .padding(.horizontal, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
    }
}

struct AchievementBannerModifier: ViewModifier {
    @EnvironmentObject private var store: AppStore
    @State private var showBanner = false

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let achievement = store.pendingAchievementBanner {
                AchievementBannerView(achievement: achievement, isVisible: $showBanner)
                    .onAppear {
                        showBanner = true
                        HapticFeedback.success()
                        SystemSound.success()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showBanner = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                store.dismissAchievementBanner()
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func achievementBanner() -> some View {
        modifier(AchievementBannerModifier())
    }
}
