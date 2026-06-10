import SwiftUI

struct PantryTrackerView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = PantryTrackerViewModel()
    @State private var showSuccessCheck = false

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                if store.pantryItems.isEmpty {
                    AppEmptyState(
                        icon: "cart.fill",
                        title: "Track your essentials!",
                        message: "No items yet — add your staples and start tracking!",
                        buttonTitle: "Add Item"
                    ) { viewModel.showingAddSheet = true }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if !store.expiringSoonItems().isEmpty {
                                expiringSection
                            }
                            ForEach(PantryCategory.allCases) { category in
                                categoryBlock(category.rawValue)
                            }
                        }
                        .appScreenInsets(bottom: 8)
                    }
                }
                summaryBar
            }
        }
        .navigationTitle("Pantry Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.lightTap()
                    viewModel.addCategory = PantryCategory.grains.rawValue
                    viewModel.editingItem = nil
                    viewModel.showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            PantryItemFormView(item: viewModel.editingItem, defaultCategory: viewModel.addCategory) { item, isNew in
                viewModel.saveItem(item, store: store, isNew: isNew)
                triggerSuccessFeedback(showCheckmark: $showSuccessCheck)
            }
        }
        .sheet(isPresented: $viewModel.showingStats) { PantryStatsView() }
        .overlay { SuccessCheckmarkOverlay(isShowing: $showSuccessCheck) }
    }

    private var expiringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Expiring This Week", icon: "calendar.badge.exclamationmark", trailing: "\(store.expiringSoonCount())")
            ForEach(store.expiringSoonItems()) { item in
                ExpiringItemCell(item: item)
            }
        }
    }

    @ViewBuilder
    private func categoryBlock(_ category: String) -> some View {
        let items = viewModel.items(for: category, in: store)
        let cat = PantryCategory.allCases.first { $0.rawValue == category }
        let expanded = viewModel.isExpanded(category, store: store)

        if !items.isEmpty || expanded {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    viewModel.toggleExpanded(category, store: store)
                } label: {
                    HStack {
                        if let cat {
                            AppIconBadge(symbol: cat.symbolName, size: 36, iconSize: .caption)
                        }
                        Text(category)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Spacer()
                        Text("\(items.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("AppBackground"))
                            .clipShape(Capsule())
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                if expanded {
                    ForEach(items) { item in
                        pantryItemRow(item, icon: cat?.symbolName ?? "basket.fill")
                    }
                    Button {
                        HapticFeedback.lightTap()
                        viewModel.addCategory = category
                        viewModel.editingItem = nil
                        viewModel.showingAddSheet = true
                    } label: {
                        Label("Add to \(category)", systemImage: "plus.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private func pantryItemRow(_ item: PantryItem, icon: String) -> some View {
        PantryItemCell(item: item, categoryIcon: icon)
            .onTapGesture {
                HapticFeedback.lightTap()
                viewModel.editingItem = item
                viewModel.showingAddSheet = true
            }
            .contextMenu {
                Button("Edit") {
                    viewModel.editingItem = item
                    viewModel.showingAddSheet = true
                }
                Button("Mark Out of Stock") { viewModel.markOutOfStock(item, store: store) }
                Button("Delete", role: .destructive) { viewModel.deleteItem(item, store: store) }
            }
    }

    private var summaryBar: some View {
        Button {
            HapticFeedback.lightTap()
            viewModel.showingStats = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.fill")
                Text("\(store.pantryItems.count) items tracked")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                AppVisualStyle.primaryButton
                    .overlay { AppVisualStyle.primaryButtonSheen }
            }
            .compositingGroup()
            .appSoftElevation(.medium)
        }
    }
}
