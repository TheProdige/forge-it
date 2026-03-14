import Foundation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    private let profileService = ProfileService.shared
    private let feedService = FeedService.shared
    private let authService = AuthService.shared

    // MARK: - State
    var profile: Profile? = nil
    var stats: UserStats? = nil
    var posts: [Post] = []
    var followingCount: Int = 0
    var followerCount: Int = 0
    var isFollowing: Bool = false
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isFollowLoading: Bool = false
    var error: String? = nil

    var isOwnProfile: Bool {
        guard let profileId = profile?.id,
              let currentId = authService.currentUser?.id else { return false }
        return profileId == currentId
    }

    // MARK: - Load
    func load(userId: UUID) async {
        isLoading = true
        error = nil
        await fetchAll(userId: userId)
        isLoading = false
    }

    func refresh(userId: UUID) async {
        isRefreshing = true
        await fetchAll(userId: userId)
        isRefreshing = false
    }

    private func fetchAll(userId: UUID) async {
        async let profileTask = profileService.fetchProfile(userId: userId)
        async let statsTask = profileService.fetchUserStats(userId: userId)
        async let postsTask = profileService.fetchUserPosts(userId: userId)
        async let countsTask = profileService.fetchFollowCounts(userId: userId)

        do {
            let (p, s, po, c) = try await (profileTask, statsTask, postsTask, countsTask)
            profile = p
            stats = s
            posts = po
            followingCount = c.following
            followerCount = c.followers
        } catch {
            self.error = "Couldn't load profile."
        }

        // Check follow status
        if let currentId = authService.currentUser?.id,
           let profileId = profile?.id,
           currentId != profileId {
            isFollowing = (try? await profileService.isFollowing(followerId: currentId, followingId: profileId)) ?? false
        }
    }

    // MARK: - Follow toggle
    func toggleFollow() async {
        guard let currentId = authService.currentUser?.id,
              let targetId = profile?.id else { return }

        isFollowLoading = true
        let wasFollowing = isFollowing
        isFollowing.toggle()
        followerCount += wasFollowing ? -1 : 1

        do {
            if wasFollowing {
                try await feedService.unfollow(followerId: currentId, followingId: targetId)
            } else {
                try await feedService.follow(followerId: currentId, followingId: targetId)
            }
        } catch {
            isFollowing = wasFollowing
            followerCount += wasFollowing ? 1 : -1
        }
        isFollowLoading = false
    }
}
