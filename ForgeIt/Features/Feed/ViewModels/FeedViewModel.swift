import Foundation
import SwiftUI

@MainActor
@Observable
final class FeedViewModel {
    private let service = FeedService.shared
    private let authService = AuthService.shared

    // MARK: - State
    var posts: [FeedPost] = []
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isLoadingMore: Bool = false
    var error: String? = nil
    var hasMore: Bool = true
    private var page: Int = 0

    var isEmpty: Bool { posts.isEmpty && !isLoading }

    // MARK: - Load
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        page = 0
        do {
            guard let userId = authService.currentUser?.id else { return }
            posts = try await service.fetchFriendsFeed(userId: userId, page: 0)
            hasMore = posts.count == 20
        } catch {
            self.error = "Couldn't load feed. Pull to refresh."
        }
        isLoading = false
    }

    func refresh() async {
        isRefreshing = true
        page = 0
        do {
            guard let userId = authService.currentUser?.id else { return }
            posts = try await service.fetchFriendsFeed(userId: userId, page: 0)
            hasMore = posts.count == 20
        } catch {}
        isRefreshing = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        page += 1
        do {
            guard let userId = authService.currentUser?.id else { return }
            let newPosts = try await service.fetchFriendsFeed(userId: userId, page: page)
            posts.append(contentsOf: newPosts)
            hasMore = newPosts.count == 20
        } catch {}
        isLoadingMore = false
    }

    // MARK: - Reactions
    func toggleReaction(postId: UUID, type: ReactionType) async {
        guard let userId = authService.currentUser?.id else { return }
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }

        // Optimistic update
        var updated = posts[index]
        if updated.reactions.myReactions.contains(type) {
            updated.reactions.myReactions.remove(type)
            switch type {
            case .grind: updated.reactions.grind = max(0, updated.reactions.grind - 1)
            case .respect: updated.reactions.respect = max(0, updated.reactions.respect - 1)
            }
        } else {
            updated.reactions.myReactions.insert(type)
            switch type {
            case .grind: updated.reactions.grind += 1
            case .respect: updated.reactions.respect += 1
            }
        }
        posts[index] = updated

        do {
            let real = try await service.toggleReaction(postId: postId, userId: userId, type: type)
            posts[index].reactions = real
        } catch {
            // Rollback on error
            posts[index] = posts[index]
        }
    }

    // MARK: - Follow
    func toggleFollow(userId targetId: UUID) async {
        guard let currentId = authService.currentUser?.id else { return }
        guard let index = posts.firstIndex(where: { $0.userId == targetId }) else { return }

        let wasFollowing = posts[index].isFollowing
        posts[index].isFollowing = !wasFollowing

        do {
            if wasFollowing {
                try await service.unfollow(followerId: currentId, followingId: targetId)
            } else {
                try await service.follow(followerId: currentId, followingId: targetId)
            }
        } catch {
            posts[index].isFollowing = wasFollowing
        }
    }
}
