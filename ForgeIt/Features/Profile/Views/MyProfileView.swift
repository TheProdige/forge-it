import SwiftUI

/// Convenience wrapper for the current user's own profile
struct MyProfileView: View {
    private let authService = AuthService.shared

    var body: some View {
        if let userId = authService.currentUser?.id {
            ProfileView(userId: userId)
        } else {
            EmptyState(
                icon: "👤",
                title: "Not logged in",
                message: "Sign in to view your profile.",
                ctaTitle: nil,
                ctaAction: nil
            )
        }
    }
}
