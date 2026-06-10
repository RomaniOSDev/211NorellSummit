import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                }
        }
    }
}

struct PulseHighlightModifier: ViewModifier {
    @Binding var isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppAccent").opacity(isPulsing ? 0.35 : 0))
                    .animation(.easeInOut(duration: 0.4), value: isPulsing)
            )
            .onChange(of: isPulsing) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPulsing = false
                    }
                }
            }
    }
}

extension View {
    func pulseHighlight(isPulsing: Binding<Bool>) -> some View {
        modifier(PulseHighlightModifier(isPulsing: isPulsing))
    }
}

func triggerSuccessFeedback(showCheckmark: Binding<Bool>? = nil, pulse: Binding<Bool>? = nil) {
    HapticFeedback.success()
    SystemSound.success()
    if let showCheckmark {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCheckmark.wrappedValue = true
        }
    }
    if let pulse {
        pulse.wrappedValue = true
    }
}
