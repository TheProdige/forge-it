import Foundation
import Supabase

@MainActor
final class PostService {
    static let shared = PostService()
    private let client = SupabaseManager.shared.client

    private init() {}

    func createPost(_ request: CreatePostRequest) async throws -> Post {
        let post: Post = try await client
            .from("posts")
            .insert(request)
            .select("*, profiles(*), goals(*)")
            .single()
            .execute()
            .value
        return post
    }

    func uploadImage(data: Data, userId: UUID, mimeType: String = "image/jpeg") async throws -> String {
        let filename = "\(userId.uuidString)/\(UUID().uuidString).jpg"
        try await client.storage
            .from("post-images")
            .upload(filename, data: data, options: .init(contentType: mimeType, upsert: false))
        let url = try client.storage.from("post-images").getPublicURL(path: filename)
        return url.absoluteString
    }

    func uploadAvatar(data: Data, userId: UUID) async throws -> String {
        let filename = "\(userId.uuidString)/avatar.jpg"
        try await client.storage
            .from("avatars")
            .upload(filename, data: data, options: .init(contentType: "image/jpeg", upsert: true))
        let url = try client.storage.from("avatars").getPublicURL(path: filename)
        return url.absoluteString
    }

    func fetchUserGoals(userId: UUID) async throws -> [Goal] {
        let goals: [Goal] = try await client
            .from("goals")
            .select()
            .eq("user_id", value: userId)
            .neq("status", value: "completed")
            .order("created_at", ascending: false)
            .execute()
            .value
        return goals
    }
}
