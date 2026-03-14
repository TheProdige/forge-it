import Foundation
import Supabase

@MainActor
final class ProfileService {
    static let shared = ProfileService()
    private let client = SupabaseManager.shared.client

    private init() {}

    func fetchProfile(userId: UUID) async throws -> Profile {
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return profile
    }

    func fetchUserStats(userId: UUID) async throws -> UserStats {
        let stats: UserStats = try await client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return stats
    }

    func fetchUserPosts(userId: UUID, page: Int = 0, limit: Int = 20) async throws -> [Post] {
        let offset = page * limit
        let posts: [Post] = try await client
            .from("posts")
            .select("*, goals(*)")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return posts
    }

    func fetchFollowCounts(userId: UUID) async throws -> (following: Int, followers: Int) {
        async let followingCount = client
            .from("follows")
            .select("id", head: true, count: .exact)
            .eq("follower_id", value: userId)
            .execute()

        async let followerCount = client
            .from("follows")
            .select("id", head: true, count: .exact)
            .eq("following_id", value: userId)
            .execute()

        let (fing, fer) = try await (followingCount, followerCount)
        return (fing.count ?? 0, fer.count ?? 0)
    }

    func isFollowing(followerId: UUID, followingId: UUID) async throws -> Bool {
        let count = try await client
            .from("follows")
            .select("id", head: true, count: .exact)
            .eq("follower_id", value: followerId)
            .eq("following_id", value: followingId)
            .execute()
            .count
        return (count ?? 0) > 0
    }
}
