import SwiftUI
import UIKit

struct CookModeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe
    let servings: Int

    @State private var currentStep = 0
    @State private var stepTimerRemaining = 0
    @State private var stepTimerRunning = false
    @State private var stepTimer: Timer?
    @State private var showSuccessCheck = false

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                headerBar

                Spacer()

                stepProgressRing

                VStack(spacing: 20) {
                    Text("Step \(currentStep + 1) of \(recipe.steps.count)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))

                    Text(recipe.steps[currentStep])
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .fixedSize(horizontal: false, vertical: true)

                    if stepDuration > 0 { stepTimerSection }
                }

                Spacer()

                navigationBar
            }
            .appScreenInsets()
            .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
        }
        .interactiveDismissDisabled()
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            stepTimerRemaining = stepDuration * 60
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stepTimer?.invalidate()
        }
    }

    private var stepDuration: Int {
        guard currentStep < recipe.stepDurationsMinutes.count else { return 0 }
        return recipe.stepDurationsMinutes[currentStep]
    }

    private var headerBar: some View {
        HStack {
            Button {
                HapticFeedback.lightTap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 44, height: 44)
                    .background(Color("AppSurface"))
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(servings) servings")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private var stepProgressRing: some View {
        let progress = recipe.steps.count > 0 ? Double(currentStep + 1) / Double(recipe.steps.count) : 0
        return ZStack {
            Circle().stroke(Color("AppSurface"), lineWidth: 8).frame(width: 72, height: 72)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 72, height: 72)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.black))
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(.bottom, 20)
    }

    private var stepTimerSection: some View {
        VStack(spacing: 10) {
            Text(formatTime(stepTimerRemaining))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(stepTimerRunning ? Color("AppAccent") : Color("AppTextSecondary"))
                .monospacedDigit()
            AppSecondaryButton(stepTimerRunning ? "Pause Timer" : "Start Step Timer", icon: "timer") {
                if stepTimerRunning { pauseStepTimer() } else { startStepTimer() }
            }
            .padding(.horizontal, 40)
        }
    }

    private var navigationBar: some View {
        HStack(spacing: 14) {
            if currentStep > 0 {
                AppSecondaryButton("Previous", icon: "chevron.left") {
                    pauseStepTimer()
                    currentStep -= 1
                    stepTimerRemaining = stepDuration * 60
                }
            }
            AppPrimaryButton(
                currentStep < recipe.steps.count - 1 ? "Next Step" : "Finish",
                icon: currentStep < recipe.steps.count - 1 ? "chevron.right" : "checkmark"
            ) {
                HapticFeedback.mediumTap()
                if currentStep < recipe.steps.count - 1 {
                    pauseStepTimer()
                    currentStep += 1
                    stepTimerRemaining = stepDuration * 60
                } else {
                    store.markRecipeCooked(recipe.id)
                    triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                }
            }
        }
    }

    private func startStepTimer() {
        stepTimerRunning = true
        HapticFeedback.mediumTap()
        SystemSound.tick()
        stepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if stepTimerRemaining > 0 { stepTimerRemaining -= 1 }
                else {
                    pauseStepTimer()
                    HapticFeedback.success()
                    SystemSound.timerComplete()
                }
            }
        }
        if let stepTimer { RunLoop.main.add(stepTimer, forMode: .common) }
    }

    private func pauseStepTimer() {
        stepTimerRunning = false
        stepTimer?.invalidate()
        stepTimer = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
