import SwiftUI

enum KitchenSection: String, CaseIterable, Identifiable {
    case pantry = "Pantry"
    case shop = "Shop"
    case alarms = "Timers"
    case batch = "Batch"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .pantry: return "basket.fill"
        case .shop: return "cart.fill"
        case .alarms: return "timer"
        case .batch: return "flame.fill"
        }
    }
}

struct KitchenHubView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedSection: KitchenSection

    init(selectedSection: Binding<KitchenSection> = .constant(.pantry)) {
        _selectedSection = selectedSection
    }

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                if store.expiringSoonCount() > 0 {
                    AppAlertBanner(
                        icon: "exclamationmark.triangle.fill",
                        message: "\(store.expiringSoonCount()) items expiring this week",
                        accent: true
                    )
                }

                AppSegmentTabs(
                    selection: $selectedSection,
                    items: KitchenSection.allCases,
                    icon: { $0.symbolName }
                )

                switch selectedSection {
                case .pantry: PantryTrackerView()
                case .shop: ShoppingListView()
                case .alarms: CookingAlarmsView()
                case .batch: BatchCookingView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSection)
        }
    }
}
