import SwiftUI
import Combine

final class CookingAlarmsViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingTimer: CookingTimer?

    func addTimer(name: String, durationSeconds: Int, store: AppStore) {
        let timer = CookingTimer(
            id: UUID().uuidString,
            name: name,
            durationSeconds: durationSeconds,
            remainingSeconds: durationSeconds,
            endDate: nil,
            isRunning: false,
            isPaused: false
        )
        store.addTimer(timer)
    }

    func updateTimer(_ timer: CookingTimer, store: AppStore) {
        store.updateTimer(timer)
    }

    func deleteTimer(_ timer: CookingTimer, store: AppStore) {
        HapticFeedback.lightTap()
        store.deleteTimer(id: timer.id)
    }

    func startTimer(_ timer: CookingTimer, store: AppStore) {
        HapticFeedback.mediumTap()
        SystemSound.tick()
        store.startCookingTimer(id: timer.id)
    }

    func pauseTimer(_ timer: CookingTimer, store: AppStore) {
        HapticFeedback.lightTap()
        store.pauseCookingTimer(id: timer.id)
    }

    func completeTimer(_ timer: CookingTimer, store: AppStore) {
        HapticFeedback.lightTap()
        SystemSound.timerComplete()
        store.finishTimer(id: timer.id)
    }

    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
