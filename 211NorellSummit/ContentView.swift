import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var store = AppStore.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard scenePhase == .active else { return }
            handleTimerTick()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            handleTimerTick()
        }
    }

    private func handleTimerTick() {
        if store.refreshRunningTimers() {
            HapticFeedback.lightTap()
            SystemSound.timerComplete()
        }
    }
}

#Preview {
    ContentView()
}
