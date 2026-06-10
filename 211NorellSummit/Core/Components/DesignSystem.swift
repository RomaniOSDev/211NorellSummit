import SwiftUI

// MARK: - Buttons

struct AppPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppVisualStyle.primaryButton)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppVisualStyle.primaryButtonSheen)
                    }
            }
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct AppSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .appCard(cornerRadius: 14, elevation: .soft)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 58, height: 58)
                .background {
                    Circle()
                        .fill(AppVisualStyle.primaryButton)
                        .overlay { Circle().fill(AppVisualStyle.primaryButtonSheen) }
                }
                .compositingGroup()
                .shadow(color: Color("AppPrimary").opacity(0.45), radius: 10, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Search & Tags

struct AppSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search recipes..."

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppAccent"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                    HapticFeedback.lightTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .appCard(cornerRadius: 14, elevation: .soft)
    }
}

struct AppTagChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.caption2)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .background {
                Group {
                    if isSelected {
                        Capsule().fill(AppVisualStyle.primaryButton)
                    } else {
                        Capsule().fill(AppVisualStyle.cardSurface)
                    }
                }
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? Color("AppAccent").opacity(0.4) : Color("AppAccent").opacity(0.18),
                        lineWidth: 1
                    )
            }
            .compositingGroup()
            .shadow(color: isSelected ? Color("AppPrimary").opacity(0.28) : .clear, radius: 5, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct MetaPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(Color("AppTextSecondary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color("AppBackground").opacity(0.7), Color("AppBackground").opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .overlay {
            Capsule().strokeBorder(Color("AppAccent").opacity(0.12), lineWidth: 0.5)
        }
    }
}

// MARK: - Section & Empty

struct AppSectionHeader: View {
    let title: String
    let icon: String
    var trailing: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                if let trailing {
                    Text(trailing)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AppPrimary").opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            LinearGradient(
                colors: [Color("AppAccent").opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 2)
            .clipShape(Capsule())
        }
    }
}

struct AppEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppVisualStyle.glowRing(isActive: true))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(AppVisualStyle.cardSurface)
                    .frame(width: 96, height: 96)
                    .overlay {
                        Circle().strokeBorder(AppVisualStyle.cardBorder, lineWidth: 1.5)
                    }
                Image(systemName: icon)
                    .font(.system(size: 38))
                    .foregroundStyle(Color("AppAccent"))
            }
            .compositingGroup()
            .appSoftElevation(.medium)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let buttonTitle, let action {
                AppPrimaryButton(buttonTitle, icon: "plus", action: action)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

struct AppAlertBanner: View {
    let icon: String
    let message: String
    var accent: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(accent ? Color("AppAccent") : Color("AppPrimary"))
            Text(message)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard(cornerRadius: 12, elevation: .soft)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

// MARK: - Icon Badge

struct AppIconBadge: View {
    let symbol: String
    var size: CGFloat = 44
    var iconSize: Font = .title3

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(AppVisualStyle.iconBadge)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .strokeBorder(Color("AppAccent").opacity(0.2), lineWidth: 0.5)
                }
                .frame(width: size, height: size)
            Image(systemName: symbol)
                .font(iconSize)
                .foregroundStyle(Color("AppAccent"))
        }
        .compositingGroup()
        .shadow(color: Color("AppBackground").opacity(0.35), radius: 4, y: 2)
    }
}

// MARK: - Stats

struct StatsSummaryCard: View {
    let items: [(value: String, label: String, icon: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(Color("AppTextSecondary").opacity(0.15))
                        .frame(width: 1, height: 44)
                }
                VStack(spacing: 6) {
                    Image(systemName: item.icon)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(item.value)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(item.label)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .appCard(elevation: .medium)
    }
}

// MARK: - Segment Tabs

struct AppSegmentTabs<T: Hashable & Identifiable>: View where T: RawRepresentable, T.RawValue == String {
    @Binding var selection: T
    let items: [T]
    let icon: (T) -> String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    segmentPill(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func segmentPill(_ item: T) -> some View {
        let isSelected = selection.id == item.id
        Button {
            HapticFeedback.lightTap()
            SystemSound.tick()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = item
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon(item))
                Text(item.rawValue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background {
                Group {
                    if isSelected {
                        Capsule().fill(AppVisualStyle.primaryButton)
                            .overlay { Capsule().fill(AppVisualStyle.primaryButtonSheen) }
                    } else {
                        Capsule().fill(AppVisualStyle.cardSurface)
                    }
                }
            }
            .overlay {
                Capsule().strokeBorder(
                    isSelected ? Color("AppAccent").opacity(0.35) : Color("AppAccent").opacity(0.12),
                    lineWidth: 1
                )
            }
            .compositingGroup()
            .shadow(color: isSelected ? Color("AppPrimary").opacity(0.32) : .clear, radius: 6, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let text: String
    let isPositive: Bool

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(isPositive ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule().fill(
                    isPositive
                        ? LinearGradient(colors: [Color("AppPrimary").opacity(0.45), Color("AppPrimary").opacity(0.25)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color("AppBackground"), Color("AppBackground").opacity(0.8)], startPoint: .top, endPoint: .bottom)
                )
            }
            .overlay {
                Capsule().strokeBorder(
                    isPositive ? Color("AppAccent").opacity(0.35) : Color.clear,
                    lineWidth: 0.5
                )
            }
    }
}
