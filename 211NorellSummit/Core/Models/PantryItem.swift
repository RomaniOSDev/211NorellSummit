import Foundation

enum PantryItemStatus: String, Codable, CaseIterable {
    case inStock = "In Stock"
    case outOfStock = "Out of Stock"
}

struct PantryItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var quantity: String
    var category: String
    var status: PantryItemStatus
    var expiryDate: Date?
}

enum PantryCategory: String, CaseIterable, Identifiable {
    case grains = "Grains"
    case spices = "Spices"
    case vegetables = "Vegetables"
    case dairy = "Dairy"
    case proteins = "Proteins"
    case other = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .grains: return "leaf.fill"
        case .spices: return "sparkles"
        case .vegetables: return "carrot.fill"
        case .dairy: return "drop.fill"
        case .proteins: return "fish.fill"
        case .other: return "basket.fill"
        }
    }
}
