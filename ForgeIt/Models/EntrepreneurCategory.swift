import Foundation

enum EntrepreneurCategory: String, Codable, CaseIterable, Identifiable {
    case saas = "saas"
    case ecommerce = "ecommerce"
    case agency = "agency"
    case construction = "construction"
    case fitness = "fitness"
    case creator = "creator"
    case freelancer = "freelancer"
    case localBusiness = "local_business"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .saas: return "SaaS"
        case .ecommerce: return "E-commerce"
        case .agency: return "Agency"
        case .construction: return "Construction"
        case .fitness: return "Fitness"
        case .creator: return "Creator"
        case .freelancer: return "Freelancer"
        case .localBusiness: return "Local Business"
        case .other: return "Other"
        }
    }

    var emoji: String {
        switch self {
        case .saas: return "💻"
        case .ecommerce: return "🛒"
        case .agency: return "🏢"
        case .construction: return "🔨"
        case .fitness: return "💪"
        case .creator: return "🎨"
        case .freelancer: return "⚡"
        case .localBusiness: return "🏪"
        case .other: return "🚀"
        }
    }

    var tagline: String {
        switch self {
        case .saas: return "Building software"
        case .ecommerce: return "Selling online"
        case .agency: return "Serving clients"
        case .construction: return "Building IRL"
        case .fitness: return "Training & coaching"
        case .creator: return "Creating content"
        case .freelancer: return "Independent work"
        case .localBusiness: return "Local hustle"
        case .other: return "Building something"
        }
    }
}
