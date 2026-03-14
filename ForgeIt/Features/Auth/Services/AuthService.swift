import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    private let client = SupabaseManager.shared.client

    @Published var currentUser: User? = nil
    @Published var currentProfile: Profile? = nil
    @Published var isLoading: Bool = false
    @Published var authError: String? = nil

    private init() {
        Task { await refreshSession() }
    }

    var isAuthenticated: Bool { currentUser != nil }
    var needsOnboarding: Bool {
        guard let profile = currentProfile else { return false }
        return profile.username.hasPrefix("user_") || profile.category == nil
    }

    // MARK: - Session
    func refreshSession() async {
        do {
            let session = try await client.auth.session
            currentUser = session.user
            if let userId = currentUser?.id {
                await loadProfile(userId: userId)
            }
        } catch {
            currentUser = nil
            currentProfile = nil
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        let session = try await client.auth.signUp(email: email, password: password)
        currentUser = session.user
        if let userId = currentUser?.id {
            await loadProfile(userId: userId)
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        let session = try await client.auth.signIn(email: email, password: password)
        currentUser = session.user
        if let userId = currentUser?.id {
            await loadProfile(userId: userId)
        }
    }

    // MARK: - Sign Out
    func signOut() async {
        do {
            try await client.auth.signOut()
            currentUser = nil
            currentProfile = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    // MARK: - Profile
    func loadProfile(userId: UUID) async {
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            currentProfile = profile
        } catch {
            // Profile may not exist yet right after signup, that's OK
        }
    }

    func updateProfile(_ updates: ProfileUpdateRequest) async throws {
        guard let userId = currentUser?.id else { throw AuthError.notAuthenticated }
        isLoading = true
        defer { isLoading = false }

        let updated: Profile = try await client
            .from("profiles")
            .update(updates)
            .eq("id", value: userId)
            .select()
            .single()
            .execute()
            .value
        currentProfile = updated
    }

    // MARK: - Check username availability
    func isUsernameAvailable(_ username: String) async -> Bool {
        guard !username.isEmpty else { return false }
        do {
            let count = try await client
                .from("profiles")
                .select("id", head: true, count: .exact)
                .eq("username", value: username.lowercased())
                .execute()
                .count
            return (count ?? 0) == 0
        } catch {
            return false
        }
    }
}

// MARK: - Supporting types
struct ProfileUpdateRequest: Encodable {
    var username: String?
    var fullName: String?
    var bio: String?
    var category: String?
    var country: String?
    var timezone: String?
    var avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case bio
        case category
        case country
        case timezone
        case avatarUrl = "avatar_url"
    }
}

enum AuthError: LocalizedError {
    case notAuthenticated
    case usernameUnavailable
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be logged in."
        case .usernameUnavailable: return "This username is already taken."
        case .invalidCredentials: return "Invalid email or password."
        }
    }
}
