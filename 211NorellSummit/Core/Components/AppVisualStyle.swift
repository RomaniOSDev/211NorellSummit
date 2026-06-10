import SwiftUI

// MARK: - Shared gradients (computed once per access, no Color extension)

enum AppVisualStyle {
    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var ambientGlowTopTrailing: RadialGradient {
        RadialGradient(
            colors: [Color("AppPrimary").opacity(0.14), Color.clear],
            center: .topTrailing,
            startRadius: 20,
            endRadius: 320
        )
    }

    static var ambientGlowBottomLeading: RadialGradient {
        RadialGradient(
            colors: [Color("AppAccent").opacity(0.08), Color.clear],
            center: .bottomLeading,
            startRadius: 10,
            endRadius: 280
        )
    }

    static var cardSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface"),
                Color("AppBackground").opacity(0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.35),
                Color("AppPrimary").opacity(0.12),
                Color("AppBackground").opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardTopSheen: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.07), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonSheen: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.18), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var iconBadge: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary").opacity(0.45), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var tabBarSurface: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppBackground").opacity(0.95)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func glowRing(isActive: Bool) -> RadialGradient {
        RadialGradient(
            colors: isActive
                ? [Color("AppAccent").opacity(0.35), Color.clear]
                : [Color.clear, Color.clear],
            center: .center,
            startRadius: 8,
            endRadius: 40
        )
    }
}

enum AppLayout {
    static let horizontal: CGFloat = 16
    static let contentTop: CGFloat = 8
    static let bottom: CGFloat = 16
}

enum AppElevation {
    case soft
    case medium
    case raised

    var radius: CGFloat {
        switch self {
        case .soft: return 6
        case .medium: return 10
        case .raised: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .soft: return 3
        case .medium: return 5
        case .raised: return 8
        }
    }

    var opacity: Double {
        switch self {
        case .soft: return 0.35
        case .medium: return 0.48
        case .raised: return 0.58
        }
    }
}

// MARK: - Reusable card background (single composited layer)

struct AppCardBackground: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppVisualStyle.cardSurface)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppVisualStyle.cardTopSheen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppVisualStyle.cardBorder, lineWidth: 1)
            }
    }
}

struct AppCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var elevation: AppElevation = .medium

    func body(content: Content) -> some View {
        content
            .background { AppCardBackground(cornerRadius: cornerRadius) }
            .compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(elevation.opacity),
                radius: elevation.radius,
                y: elevation.y
            )
    }
}

struct AppHeroCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppVisualStyle.cardBorder, lineWidth: 1)
            }
            .compositingGroup()
            .shadow(color: Color("AppBackground").opacity(0.6), radius: 14, y: 8)
    }
}

extension View {
    func appCard(cornerRadius: CGFloat = 16, elevation: AppElevation = .medium) -> some View {
        modifier(AppCardModifier(cornerRadius: cornerRadius, elevation: elevation))
    }

    func appHeroCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(AppHeroCardModifier(cornerRadius: cornerRadius))
    }

    func appSoftElevation(_ elevation: AppElevation = .soft) -> some View {
        compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(elevation.opacity),
                radius: elevation.radius,
                y: elevation.y
            )
    }

    func appScreenInsets(bottom: CGFloat = AppLayout.bottom) -> some View {
        padding(.horizontal, AppLayout.horizontal)
            .padding(.top, AppLayout.contentTop)
            .padding(.bottom, bottom)
    }
}
