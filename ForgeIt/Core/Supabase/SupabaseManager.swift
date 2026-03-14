import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        guard
            let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String
        else {
            // Fallback for development — replace with your Supabase credentials
            client = SupabaseClient(
                supabaseURL: URL(string: "https://dybbhxmndqnxasucrqxi.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR5YmJoeG1uZHFueGFzdWNycXhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MjY0NzYsImV4cCI6MjA4OTEwMjQ3Nn0.QVwjPtKXD5_CFBZuU_-UVuWgvYr9n0_mEGV0u-dt2kg"
            )
            return
        }
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }

    var auth: AuthClient { client.auth }

    var currentUserId: UUID? {
        client.auth.currentUser?.id
    }

    var isAuthenticated: Bool {
        client.auth.currentSession != nil
    }
}

// MARK: - Convenience
extension SupabaseClient {
    static var shared: SupabaseClient { SupabaseManager.shared.client }
}
