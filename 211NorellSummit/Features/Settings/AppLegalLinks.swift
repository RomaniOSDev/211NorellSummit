import Foundation

enum AppLegalLinks {
    case privacyPolicy
    case termsOfService

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://norell211summit.site/privacy/249"
        case .termsOfService:
            return "https://norell211summit.site/terms/249"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfService:
            return "Terms of Service"
        }
    }

    var iconName: String {
        switch self {
        case .privacyPolicy:
            return "hand.raised.fill"
        case .termsOfService:
            return "doc.text.fill"
        }
    }
}
