import Foundation
import SwiftUI
import PhotosUI

enum CaptureState {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
@Observable
final class CaptureViewModel {
    private let postService = PostService.shared
    private let authService = AuthService.shared

    // MARK: - Form state
    var selectedImage: UIImage? = nil
    var selectedPhotoItem: PhotosPickerItem? = nil
    var caption: String = ""
    var selectedGoalId: UUID? = nil
    var markGoalComplete: Bool = false
    var goals: [Goal] = []

    // MARK: - UI state
    var state: CaptureState = .idle
    var isSubmitting: Bool = false
    var showSuccessToast: Bool = false

    var isValid: Bool {
        selectedImage != nil || !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var captionCharCount: Int { caption.count }
    var captionTooLong: Bool { caption.count > 500 }

    // MARK: - Load goals for linking
    func loadGoals() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            goals = try await postService.fetchUserGoals(userId: userId)
        } catch {}
    }

    // MARK: - Photo selection
    func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
        }
    }

    // MARK: - Submit
    func submit() async {
        guard isValid, !isSubmitting else { return }
        guard let userId = authService.currentUser?.id else { return }

        isSubmitting = true
        state = .loading

        do {
            var imageUrl: String? = nil

            if let image = selectedImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                imageUrl = try await postService.uploadImage(data: data, userId: userId)
            }

            let request = CreatePostRequest(
                userId: userId,
                imageUrl: imageUrl,
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : caption,
                linkedGoalId: selectedGoalId,
                goalMarkedComplete: markGoalComplete && selectedGoalId != nil,
                postedForDate: Date.todayDate
            )

            _ = try await postService.createPost(request)

            state = .success
            showSuccessToast = true
            reset()

        } catch {
            state = .error(error.localizedDescription)
        }

        isSubmitting = false
    }

    // MARK: - Reset
    func reset() {
        selectedImage = nil
        selectedPhotoItem = nil
        caption = ""
        selectedGoalId = nil
        markGoalComplete = false
        state = .idle
    }
}
