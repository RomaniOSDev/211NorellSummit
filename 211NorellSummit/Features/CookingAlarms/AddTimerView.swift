import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTimer: CookingTimer?
    let onSave: (String, Int) -> Void

    @State private var name = ""
    @State private var durationDate = Date()
    @State private var shakeAmount: CGFloat = 0
    @State private var nameError = ""

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                Form {
                    Section {
                        TextField("Dish name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: shakeAmount))

                        if !nameError.isEmpty {
                            Text(nameError)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        DatePicker(
                            "Duration",
                            selection: $durationDate,
                            displayedComponents: .hourAndMinute
                        )
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTimer == nil ? "Add Timer" : "Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticFeedback.lightTap()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let existingTimer {
                    name = existingTimer.name
                    let totalMinutes = existingTimer.durationSeconds / 60
                    durationDate = Calendar.current.date(
                        bySettingHour: totalMinutes / 60,
                        minute: totalMinutes % 60,
                        second: 0,
                        of: Date()
                    ) ?? Date()
                } else {
                    durationDate = Calendar.current.date(bySettingHour: 0, minute: 15, second: 0, of: Date()) ?? Date()
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            nameError = "Please enter a dish name."
            HapticFeedback.warning()
            withAnimation { shakeAmount += 1 }
            return
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: durationDate)
        let totalSeconds = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60
        guard totalSeconds > 0 else {
            nameError = "Duration must be greater than zero."
            HapticFeedback.warning()
            withAnimation { shakeAmount += 1 }
            return
        }

        HapticFeedback.mediumTap()
        onSave(trimmed, totalSeconds)
        dismiss()
    }
}
