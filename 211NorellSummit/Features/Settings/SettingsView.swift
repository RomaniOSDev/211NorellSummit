import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 20) {
                        StatsSummaryCard(items: [
                            (value: "\(store.totalSessionsCompleted)", label: "Entries", icon: "tray.full.fill"),
                            (value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "clock.fill"),
                            (value: "\(store.streakDays)d", label: "Streak", icon: "flame.fill")
                        ])

                        VStack(spacing: 0) {
                            settingsButton(title: "Rate Us", icon: "star.fill") {
                                rateApp()
                            }
                            settingsDivider
                            legalLinkButton(.privacyPolicy)
                            settingsDivider
                            legalLinkButton(.termsOfService)
                            settingsDivider
                            settingsButton(title: "Reset All Data", icon: "trash.fill", isDestructive: true) {
                                showResetAlert = true
                            }
                        }
                        .appCard()

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .appScreenInsets()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { HapticFeedback.lightTap() }
                Button("Reset", role: .destructive) {
                    HapticFeedback.mediumTap()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your recipes, pantry items, timers, and progress.")
            }
        }
    }

    private var settingsDivider: some View {
        Divider()
            .background(Color("AppTextSecondary").opacity(0.15))
            .padding(.leading, 56)
    }

    private func settingsButton(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            SettingsRowCell(title: title, icon: icon, isDestructive: isDestructive)
        }
    }

    private func legalLinkButton(_ link: AppLegalLinks) -> some View {
        settingsButton(title: link.title, icon: link.iconName) {
            openLink(link)
        }
    }

    private func openLink(_ link: AppLegalLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
