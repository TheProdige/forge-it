import Foundation

/// Enriched post model used in feed views (combines Post + reactions + follow state)
struct FeedPost: Identifiable, Equatable {
    let post: Post
    var reactions: ReactionCounts
    var isFollowing: Bool

    var id: UUID { post.id }
    var profile: Profile? { post.profile }
    var imageUrl: String? { post.imageUrl }
    var caption: String? { post.caption }
    var linkedGoal: Goal? { post.linkedGoal }
    var goalMarkedComplete: Bool { post.goalMarkedComplete }
    var createdAt: Date { post.createdAt }
    var userId: UUID { post.userId }

    static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        lhs.id == rhs.id &&
        lhs.reactions == rhs.reactions &&
        lhs.isFollowing == rhs.isFollowing
    }
}
