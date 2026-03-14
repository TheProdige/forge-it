import Foundation
import Supabase

@MainActor
final class FeedService {
    static let shared = FeedService()
    private let client = SupabaseManager.shared.client

    private init() {}

    // MARK: - Friends feed (posts from followed users)
    func fetchFriendsFeed(userId: UUID, page: Int = 0, limit: Int = 20) async throws -> [FeedPost] {
        let offset = page * limit

        // Get following IDs
        let follows: [FollowRow] = try await client
            .from("follows")
            .select("following_id")
            .eq("follower_id", value: userId)
            .execute()
            .value

        let followingIds = follows.map { $0.followingId }

        guard !followingIds.isEmpty else { return [] }

        // Fetch posts with profiles and goals
        let posts: [Post] = try await client
            .from("posts")
            .select("*, profiles(*), goals(*)")
            .in("user_id", values: followingIds)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value

        return try await enrichPosts(posts, currentUserId: userId, followingIds: Set(followingIds))
    }

    // MARK: - Explore feed
    func fetchExploreFeed(
        userId: UUID,
        category: String? = nil,
        searchQuery: String? = nil,
        page: Int = 0,
        limit: Int = 20
    ) async throws -> [FeedPost] {
        let offset = page * limit

        var query = client
            .from("posts")
            .select("*, profiles(*), goals(*)")
            .neq("user_id", value: userId) // Exclude own posts from explore

        if let cat = category, cat != "all" {
            query = query.eq("profiles.category", value: cat)
        }

        let posts: [Post] = try await query
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value

        // Get current following
        let follows: [FollowRow] = try await client
            .from("follows")
            .select("following_id")
            .eq("follower_id", value: userId)
            .execute()
            .value
        let followingIds = Set(follows.map { $0.followingId })

        var feedPosts = try await enrichPosts(posts, currentUserId: userId, followingIds: followingIds)

        // Filter by search query if present
        if let query = searchQuery, !query.isEmpty {
            let lower = query.lowercased()
            feedPosts = feedPosts.filter { post in
                post.profile?.username.lowercased().contains(lower) == true ||
                post.profile?.fullName?.lowercased().contains(lower) == true ||
                post.caption?.lowercased().contains(lower) == true
            }
        }

        return feedPosts
    }

    // MARK: - Reactions
    func toggleReaction(postId: UUID, userId: UUID, type: ReactionType) async throws -> ReactionCounts {
        // Check if reaction exists
        let existing: [PostReaction] = try await client
            .from("post_reactions")
            .select()
            .eq("post_id", value: postId)
            .eq("user_id", value: userId)
            .eq("reaction_type", value: type.rawValue)
            .execute()
            .value

        if existing.isEmpty {
            // Add reaction
            try await client
                .from("post_reactions")
                .insert(["post_id": postId.uuidString, "user_id": userId.uuidString, "reaction_type": type.rawValue])
                .execute()
        } else {
            // Remove reaction
            try await client
                .from("post_reactions")
                .delete()
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .eq("reaction_type", value: type.rawValue)
                .execute()
        }

        return try await fetchReactionCounts(postId: postId, userId: userId)
    }

    func fetchReactionCounts(postId: UUID, userId: UUID) async throws -> ReactionCounts {
        let reactions: [PostReaction] = try await client
            .from("post_reactions")
            .select()
            .eq("post_id", value: postId)
            .execute()
            .value

        let grind = reactions.filter { $0.reactionType == .grind }.count
        let respect = reactions.filter { $0.reactionType == .respect }.count
        let mine = Set(reactions.filter { $0.userId == userId }.map { $0.reactionType })

        return ReactionCounts(grind: grind, respect: respect, myReactions: mine)
    }

    // MARK: - Follow / Unfollow
    func follow(followerId: UUID, followingId: UUID) async throws {
        try await client
            .from("follows")
            .insert(["follower_id": followerId.uuidString, "following_id": followingId.uuidString])
            .execute()
    }

    func unfollow(followerId: UUID, followingId: UUID) async throws {
        try await client
            .from("follows")
            .delete()
            .eq("follower_id", value: followerId)
            .eq("following_id", value: followingId)
            .execute()
    }

    // MARK: - Private helpers
    private func enrichPosts(_ posts: [Post], currentUserId: UUID, followingIds: Set<UUID>) async throws -> [FeedPost] {
        var feedPosts: [FeedPost] = []

        for post in posts {
            let counts = try await fetchReactionCounts(postId: post.id, userId: currentUserId)
            let isFollowing = followingIds.contains(post.userId)
            feedPosts.append(FeedPost(post: post, reactions: counts, isFollowing: isFollowing))
        }

        return feedPosts
    }
}

// MARK: - Internal helpers
private struct FollowRow: Decodable {
    let followingId: UUID
    enum CodingKeys: String, CodingKey {
        case followingId = "following_id"
    }
}
