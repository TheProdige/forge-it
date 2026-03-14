import Foundation
import SwiftUI

@MainActor
@Observable
final class ExploreViewModel {
    private let service = FeedService.shared
    private let authService = AuthService.shared

    // MARK: - State
    var posts: [FeedPost] = []
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isLoadingMore: Bool = false
    var searchQuery: String = ""
    var selectedCategory: String = "all"
    var error: String? = nil
    var hasMore: Bool = true
    private var page: Int = 0

    var categories: [(id: String, label: String, emoji: String)] = [
        ("all", "All", "🌐"),
        ("saas", "SaaS", "💻"),
        ("ecommerce", "E-commerce", "🛒"),
        ("agency", "Agency", "🏢"),
        ("construction", "Construction", "🔨"),
        ("fitness", "Fitness", "💪"),
        ("creator", "Creator", "🎨"),
        ("local_business", "Local Biz", "🏪"),
    ]

    var isEmpty: Bool { posts.isEmpty && !isLoading }

    // MARK: - Load
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        page = 0
        await fetchPosts()
        isLoading = false
    }

    func refresh() async {
        isRefreshing = true
        page = 0
        await fetchPosts()
        isRefreshing = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        page += 1
        guard let userId = authService.currentUser?.id else { return }
        do {
            let newPosts = try await service.fetchExploreFeed(
                userId: userId,
                category: selectedCategory == "all" ? nil : selectedCategory,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                page: page
            )
            posts.append(contentsOf: newPosts)
            hasMore = newPosts.count == 20
        } catch {}
        isLoadingMore = false
    }

    func selectCategory(_ cat: String) {
        guard cat != selectedCategory else { return }
        selectedCategory = cat
        Task { await load() }
    }

    func search() {
        Task { await load() }
    }

    // MARK: - Private
    private func fetchPosts() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            let fetched = try await service.fetchExploreFeed(
                userId: userId,
                category: selectedCategory == "all" ? nil : selectedCategory,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                page: page
            )
            posts = fetched
            hasMore = fetched.count == 20
        } catch {
            self.error = "Couldn't load explore feed."
        }
    }

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

    func toggleReaction(postId: UUID, type: ReactionType) async {
        guard let userId = authService.currentUser?.id else { return }
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        do {
            let counts = try await service.toggleReaction(postId: postId, userId: userId, type: type)
            posts[index].reactions = counts
        } catch {}
    }
}
