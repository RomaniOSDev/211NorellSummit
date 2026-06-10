import SwiftUI

struct BatchCookingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedRecipeIDs: Set<String> = []
    @State private var sessionName = ""
    @State private var showNameAlert = false
    @State private var showSuccessCheck = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AppAlertBanner(
                        icon: "flame.fill",
                        message: "Select 2 or more recipes to create a batch cooking timeline."
                    )

                    LazyVStack(spacing: 10) {
                        ForEach(store.allRecipes()) { recipe in
                            BatchSelectCell(
                                recipe: recipe,
                                isSelected: selectedRecipeIDs.contains(recipe.id)
                            )
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                HapticFeedback.lightTap()
                                if selectedRecipeIDs.contains(recipe.id) { selectedRecipeIDs.remove(recipe.id) }
                                else { selectedRecipeIDs.insert(recipe.id) }
                            }
                        }
                    }

                    if !store.batchCookSessions.filter({ !$0.isCompleted }).isEmpty {
                        activeSessionsSection
                    }
                }
                .appScreenInsets(bottom: 8)
            }

            if selectedRecipeIDs.count >= 2 {
                AppPrimaryButton("Create Session · \(selectedRecipeIDs.count) recipes", icon: "flame.fill") {
                    sessionName = "Batch \(Date().formatted(date: .abbreviated, time: .omitted))"
                    showNameAlert = true
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Batch Cooking")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Session Name", isPresented: $showNameAlert) {
            TextField("Name", text: $sessionName)
            Button("Cancel", role: .cancel) {}
            Button("Start") { createSession() }
        }
        .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
    }

    private var activeSessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Active Sessions", icon: "clock.arrow.circlepath")
                .padding(.horizontal, 16)
            ForEach(store.batchCookSessions.filter { !$0.isCompleted }) { session in
                NavigationLink { BatchSessionDetailView(session: session) } label: {
                    BatchSessionCell(session: session)
                        .padding(.horizontal, 16)
                }
            }
        }
    }

    private func createSession() {
        let recipes = selectedRecipeIDs.compactMap { store.recipe(id: $0) }
        guard recipes.count >= 2 else { return }
        let name = sessionName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.addBatchSession(BatchTimelineBuilder.buildSession(
            name: name.isEmpty ? "Batch Session" : name,
            recipes: recipes
        ))
        selectedRecipeIDs = []
        triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
    }
}

struct BatchSessionDetailView: View {
    @EnvironmentObject private var store: AppStore
    let session: BatchCookSession
    @State private var pulseID: String?
    @State private var showSuccessCheck = false

    private var currentSession: BatchCookSession? {
        store.batchCookSessions.first { $0.id == session.id }
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                if let current = currentSession {
                    let sorted = current.timelineSteps.sorted { $0.orderIndex < $1.orderIndex }
                    VStack(spacing: 4) {
                        progressCard(for: current)
                        ForEach(Array(sorted.enumerated()), id: \.element.id) { index, step in
                            BatchTimelineCell(
                                step: step,
                                isLast: index == sorted.count - 1,
                                onComplete: { markStepComplete(step, in: current) }
                            )
                            .pulseHighlight(isPulsing: Binding(
                                get: { pulseID == step.id },
                                set: { if !$0 { pulseID = nil } }
                            ))
                        }
                        actionButtons(for: current)
                    }
                    .appScreenInsets()
                }
            }
            .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
        }
        .navigationTitle(currentSession?.name ?? session.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func progressCard(for session: BatchCookSession) -> some View {
        let done = session.timelineSteps.filter(\.isCompleted).count
        let total = session.timelineSteps.count
        return HStack(spacing: 14) {
            ZStack {
                Circle().stroke(Color("AppBackground"), lineWidth: 5).frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: total > 0 ? Double(done) / Double(total) : 0)
                    .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                Text("\(done)/\(total)")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color("AppAccent"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Session Progress")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(session.recipeIDs.count) recipes cooking together")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
        .padding(16)
        .appCard()
        .padding(.bottom, 12)
    }

    private func actionButtons(for session: BatchCookSession) -> some View {
        VStack(spacing: 12) {
            AppSecondaryButton("Start All Timers", icon: "timer") {
                HapticFeedback.mediumTap()
                store.startBatchTimers(for: session)
                triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
            }
            if session.timelineSteps.allSatisfy(\.isCompleted) {
                AppPrimaryButton("Complete Session", icon: "checkmark.circle.fill") {
                    store.completeBatchSession(session.id)
                    triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
                }
            }
        }
        .padding(.top, 12)
    }

    private func markStepComplete(_ step: BatchTimelineStep, in session: BatchCookSession) {
        var updated = session
        if let index = updated.timelineSteps.firstIndex(where: { $0.id == step.id }) {
            updated.timelineSteps[index].isCompleted = true
            store.updateBatchSession(updated)
            pulseID = step.id
            HapticFeedback.success()
            SystemSound.success()
        }
    }
}
