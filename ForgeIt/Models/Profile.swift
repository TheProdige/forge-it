import Foundation

struct Profile: Codable, Identifiable, Hashable, Equatable {
    let id: UUID
    var username: String
    var fullName: String?
    var avatarUrl: String?
    var bio: String?
    var category: String?
    var country: String?
    var timezone: String?
    let createdAt: Date
    var updatedAt: Date

    var entrepreneurCategory: EntrepreneurCategory? {
        guard let category else { return nil }
        return EntrepreneurCategory(rawValue: category)
    }

    var displayName: String {
        fullName?.isEmpty == false ? (fullName ?? username) : username
    }

    var initials: String {
        let name = displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case bio
        case category
        case country
        case timezone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
