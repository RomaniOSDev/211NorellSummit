import SwiftUI

struct PantryStatsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessCheck = false
    @State private var pulseRow = false

    private var inStockCount: Int { store.pantryItems.filter { $0.status == .inStock }.count }
    private var outOfStockCount: Int { store.outOfStockCount() }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 16) {
                        StatsSummaryCard(items: [
                            (value: "\(store.pantryItems.count)", label: "Total", icon: "basket.fill"),
                            (value: "\(inStockCount)", label: "In Stock", icon: "checkmark.circle.fill"),
                            (value: "\(outOfStockCount)", label: "Out", icon: "xmark.circle.fill")
                        ])

                        statRow(title: "Lists Completed", value: "\(store.listsCompleted)", icon: "list.bullet.clipboard.fill")

                        if outOfStockCount > 0 {
                            AppPrimaryButton("Complete Shopping List", icon: "cart.badge.plus") {
                                completeShopping()
                            }
                            .pulseHighlight(isPulsing: $pulseRow)
                        }

                        categoryBreakdown
                    }
                    .appScreenInsets()
                }
                .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
            }
            .navigationTitle("Pantry Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticFeedback.lightTap()
                        dismiss()
                    }
                }
            }
        }
    }

    private func statRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: icon, size: 44, iconSize: .body)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(16)
        .appCard()
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "By Category", icon: "square.grid.2x2.fill")
            ForEach(PantryCategory.allCases) { category in
                let count = store.pantryItems.filter { $0.category == category.rawValue }.count
                HStack {
                    AppIconBadge(symbol: category.symbolName, size: 32, iconSize: .caption)
                    Text(category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color("AppBackground"))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .appCard()
    }

    private func completeShopping() {
        HapticFeedback.mediumTap()
        store.completeShoppingList()
        triggerSuccessFeedback(showCheckmark: $showSuccessCheck, pulse: $pulseRow)
    }
}
