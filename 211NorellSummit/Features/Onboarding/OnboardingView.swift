import SwiftUI

struct OnboardingPage {
    let headline: String
    let description: String
    let symbol: String
    let highlights: [String]

    static let all: [OnboardingPage] = [
        OnboardingPage(
            headline: "Get Inspired",
            description: "Discover new recipes tailored to your preferences and cooking style.",
            symbol: "sparkles",
            highlights: ["Browse", "Favorites", "Filters"]
        ),
        OnboardingPage(
            headline: "Organize Meals",
            description: "Plan your weekly meals with an intuitive calendar and smart shopping lists.",
            symbol: "calendar",
            highlights: ["Weekly Plan", "Shopping", "Pantry"]
        ),
        OnboardingPage(
            headline: "Start Cooking",
            description: "Jump into cook mode, set timers, and track your kitchen progress.",
            symbol: "flame.fill",
            highlights: ["Cook Mode", "Timers", "Badges"]
        )
    ]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var currentPage = 0

    private let pages = OnboardingPage.all

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                OnboardingProgressHeader(currentPage: currentPage, totalPages: pages.count)
                    .padding(.horizontal, 20)
                    .padding(.top, AppLayout.contentTop)
                    .padding(.bottom, 4)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                OnboardingFooter(
                    currentPage: currentPage,
                    totalPages: pages.count,
                    isLastPage: currentPage == pages.count - 1,
                    onAdvance: advance
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    private func advance() {
        HapticFeedback.lightTap()
        SystemSound.tick()
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
        } else {
            HapticFeedback.mediumTap()
            store.completeOnboarding()
        }
    }
}

// MARK: - Progress Header

private struct OnboardingProgressHeader: View {
    let currentPage: Int
    let totalPages: Int

    private var progress: CGFloat {
        CGFloat(currentPage + 1) / CGFloat(totalPages)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Welcome")
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("Step \(currentPage + 1) of \(totalPages)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AppPrimary").opacity(0.2))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground").opacity(0.6))
                        .frame(height: 6)
                    Capsule()
                        .fill(AppVisualStyle.primaryButton)
                        .frame(width: max(geo.size.width * progress, 6), height: 6)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: currentPage)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .appCard(cornerRadius: 16, elevation: .soft)
    }
}

// MARK: - Page

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                OnboardingIllustration(symbolName: page.symbol)
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(page.headline)
                            .font(.title.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.leading)

                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.6), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 64, height: 3)
                        .clipShape(Capsule())
                    }

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .fixedSize(horizontal: false, vertical: true)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(page.highlights, id: \.self) { highlight in
                                MetaPill(icon: "checkmark.circle.fill", text: highlight)
                            }
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard(cornerRadius: 18, elevation: .medium)
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .onAppear { animateIn() }
        .onChange(of: pageIndex) { _ in
            appeared = false
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            appeared = true
        }
    }
}

// MARK: - Illustration

struct OnboardingIllustration: View {
    let symbolName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppSurface"),
                            Color("AppPrimary").opacity(0.22),
                            Color("AppBackground").opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppVisualStyle.cardTopSheen)
                }
                .frame(height: 240)

            ZStack {
                Circle()
                    .fill(AppVisualStyle.glowRing(isActive: true))
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppSurface"), Color("AppPrimary").opacity(0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay { Circle().fill(AppVisualStyle.cardTopSheen) }
                    .frame(width: 148, height: 148)
                Circle()
                    .strokeBorder(AppVisualStyle.cardBorder, lineWidth: 2.5)
                    .frame(width: 168, height: 168)
                Image(systemName: symbolName)
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(Color("AppAccent"))
                    .symbolRenderingMode(.hierarchical)
            }
            .compositingGroup()
            .appSoftElevation(.medium)
        }
        .appHeroCard(cornerRadius: 24)
    }
}

// MARK: - Footer

private struct OnboardingFooter: View {
    let currentPage: Int
    let totalPages: Int
    let isLastPage: Bool
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    OnboardingPageDot(isActive: index == currentPage)
                }
            }

            AppPrimaryButton(
                isLastPage ? "Get Started" : "Continue",
                icon: isLastPage ? "checkmark" : "arrow.right"
            ) {
                onAdvance()
            }
        }
        .padding(20)
        .appCard(cornerRadius: 20, elevation: .raised)
    }
}

private struct OnboardingPageDot: View {
    let isActive: Bool

    var body: some View {
        Capsule()
            .fill(
                isActive
                    ? AppVisualStyle.primaryButton
                    : LinearGradient(
                        colors: [Color("AppTextSecondary").opacity(0.25), Color("AppTextSecondary").opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
            .frame(width: isActive ? 28 : 8, height: 8)
            .compositingGroup()
            .shadow(color: isActive ? Color("AppPrimary").opacity(0.35) : .clear, radius: 4, y: 2)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
    }
}
