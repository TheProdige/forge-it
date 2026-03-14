import Foundation
import SwiftUI

enum AuthFlow {
    case signIn
    case signUp
    case onboarding
    case app
}

@MainActor
@Observable
final class AuthViewModel {
    private let service = AuthService.shared

    // MARK: - State
    var flow: AuthFlow = .signIn
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var error: String? = nil

    var isAuthenticated: Bool { service.isAuthenticated }
    var currentProfile: Profile? { service.currentProfile }

    // MARK: - Auth actions
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please enter your email and password."
            return
        }
        isLoading = true
        error = nil
        do {
            try await service.signIn(email: email, password: password)
            if service.needsOnboarding {
                flow = .onboarding
            } else {
                flow = .app
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signUp() async {
        guard !email.isEmpty, password.count >= 8 else {
            error = password.count < 8 ? "Password must be at least 8 characters." : "Please fill all fields."
            return
        }
        isLoading = true
        error = nil
        do {
            try await service.signUp(email: email, password: password)
            flow = .onboarding
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        await service.signOut()
        flow = .signIn
        email = ""
        password = ""
    }
}
