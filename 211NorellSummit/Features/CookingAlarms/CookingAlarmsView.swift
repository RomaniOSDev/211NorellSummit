import SwiftUI

struct CookingAlarmsView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = CookingAlarmsViewModel()
    @State private var fadingTimerID: String?
    @State private var showSuccessCheck = false

    var body: some View {
        AppBackgroundView {
            ZStack(alignment: .bottomTrailing) {
                if store.timers.isEmpty {
                    AppEmptyState(
                        icon: "clock.fill",
                        title: "No Active Timers",
                        message: "Add your first dish and keep track of cooking times!",
                        buttonTitle: "Add Timer"
                    ) {
                        viewModel.editingTimer = nil
                        viewModel.showingAddSheet = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.timers) { timer in
                                TimerCell(
                                    timer: timer,
                                    onPlayPause: {
                                        if timer.isRunning { viewModel.pauseTimer(timer, store: store) }
                                        else { viewModel.startTimer(timer, store: store) }
                                    },
                                    onEdit: {
                                        HapticFeedback.lightTap()
                                        viewModel.editingTimer = timer
                                        viewModel.showingAddSheet = true
                                    }
                                )
                                .opacity(fadingTimerID == timer.id ? 0 : 1)
                                .animation(.easeInOut(duration: 0.4), value: fadingTimerID)
                                .contextMenu {
                                    Button("Complete") { completeTimer(timer) }
                                    Button("Delete", role: .destructive) { viewModel.deleteTimer(timer, store: store) }
                                }
                            }
                        }
                        .appScreenInsets(bottom: 80)
                    }
                }

                if !store.timers.isEmpty {
                    FloatingActionButton(icon: "plus") {
                        viewModel.editingTimer = nil
                        viewModel.showingAddSheet = true
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Cooking Alarms")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddTimerView(existingTimer: viewModel.editingTimer) { name, seconds in
                if let existing = viewModel.editingTimer {
                    var updated = existing
                    updated.name = name
                    updated.durationSeconds = seconds
                    updated.remainingSeconds = seconds
                    updated.isRunning = false
                    updated.isPaused = false
                    updated.endDate = nil
                    viewModel.updateTimer(updated, store: store)
                } else {
                    viewModel.addTimer(name: name, durationSeconds: seconds, store: store)
                }
                triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
            }
        }
        .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
    }

    private func completeTimer(_ timer: CookingTimer) {
        fadingTimerID = timer.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            viewModel.completeTimer(timer, store: store)
            triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
            fadingTimerID = nil
        }
    }
}
