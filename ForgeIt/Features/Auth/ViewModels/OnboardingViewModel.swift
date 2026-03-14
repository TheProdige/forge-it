import Foundation
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case username = 0
    case category = 1
    case bio = 2
    case done = 3
}

@MainActor
@Observable
final class OnboardingViewModel {
    private let service = AuthService.shared

    // MARK: - State
    var step: OnboardingStep = .username
    var username: String = ""
    var selectedCategory: EntrepreneurCategory? = nil
    var bio: String = ""
    var country: String = ""

    var isLoading: Bool = false
    var error: String? = nil
    var usernameError: String? = nil
    var isCheckingUsername: Bool = false
    var usernameAvailable: Bool? = nil

    var isComplete: Bool { step == .done }
    var progress: Double { Double(step.rawValue) / Double(OnboardingStep.allCases.count - 1) }

    var canProceedFromUsername: Bool {
        usernameAvailable == true && !username.isEmpty && !isCheckingUsername
    }

    // MARK: - Username validation
    func validateUsername() async {
        let raw = username.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" }
        username = raw

        guard raw.count >= 3 else {
            usernameError = raw.isEmpty ? nil : "Username must be at least 3 characters."
            usernameAvailable = nil
            return
        }

        isCheckingUsername = true
        usernameError = nil
        usernameAvailable = await service.isUsernameAvailable(raw)
        isCheckingUsername = false

        if usernameAvailable == false {
            usernameError = "This username is already taken."
        }
    }

    // MARK: - Navigation
    func next() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .username: step = .category
            case .category: step = .bio
            case .bio: Task { await complete() }
            case .done: break
            }
        }
    }

    func back() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .username: break
            case .category: step = .username
            case .bio: step = .category
            case .done: break
            }
        }
    }

    // MARK: - Completion
    func complete() async {
        isLoading = true
        error = nil
        let updates = ProfileUpdateRequest(
            username: username.isEmpty ? nil : username,
            fullName: nil,
            bio: bio.isEmpty ? nil : bio,
            category: selectedCategory?.rawValue,
            country: country.isEmpty ? nil : country,
            timezone: TimeZone.current.identifier,
            avatarUrl: nil
        )
        do {
            try await service.updateProfile(updates)
            step = .done
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
