import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    private let authService = AuthService.shared
    private let postService = PostService.shared

    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var selectedCategory: EntrepreneurCategory? = nil
    @State private var country: String = ""
    @State private var selectedAvatarItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var error: String? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Avatar picker
                    VStack(spacing: AppSpacing.sm) {
                        PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if let img = avatarImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 88, height: 88)
                                        .clipShape(Circle())
                                } else {
                                    UserAvatar(profile: authService.currentProfile, size: 88, showBorder: true)
                                }
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accent)
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(AppColors.textInverse)
                                }
                                .offset(x: 2, y: 2)
                            }
                        }
                        .onChange(of: selectedAvatarItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    avatarImage = img
                                }
                            }
                        }

                        Text("Change photo")
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(AppColors.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.md)

                    // Fields
                    VStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("DISPLAY NAME")
                                .font(AppTypography.labelSmall)
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.5)
                            TextField("Your full name", text: $fullName)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(AppSpacing.md)
                                .background(AppColors.bgInput)
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                        .strokeBorder(AppColors.border, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("BIO")
                                .font(AppTypography.labelSmall)
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.5)
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                    .fill(AppColors.bgInput)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                            .strokeBorder(AppColors.border, lineWidth: 1)
                                    )
                                    .frame(minHeight: 80)
                                TextEditor(text: $bio)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .padding(AppSpacing.sm)
                                    .frame(minHeight: 80)
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("COUNTRY")
                                .font(AppTypography.labelSmall)
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.5)
                            TextField("US, FR, UK…", text: $country)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(AppSpacing.md)
                                .background(AppColors.bgInput)
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                        .strokeBorder(AppColors.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // Category picker
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("CATEGORY")
                            .font(AppTypography.labelSmall)
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.5)
                            .padding(.horizontal, AppSpacing.screenPadding)

                        LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
                            ForEach(EntrepreneurCategory.allCases) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    VStack(spacing: 3) {
                                        Text(cat.emoji).font(.system(size: 22))
                                        Text(cat.displayName)
                                            .font(AppTypography.captionBold)
                                            .foregroundStyle(selectedCategory == cat ? AppColors.textInverse : AppColors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(selectedCategory == cat ? AppColors.accent : AppColors.bgCard)
                                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                            .strokeBorder(selectedCategory == cat ? Color.clear : AppColors.border, lineWidth: 0.5)
                                    )
                                }
                                .animation(.spring(response: 0.2), value: selectedCategory)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }

                    if let error {
                        Text(error)
                            .font(AppTypography.bodySmall)
                            .foregroundStyle(AppColors.error)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(AppColors.textInverse)
                            } else {
                                Text("Save changes")
                            }
                        }
                        .primaryButton()
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, AppSpacing.screenPadding)

                    Color.clear.frame(height: AppSpacing.xxl)
                }
            }
            .screenBackground()
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.bgSecondary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        let profile = authService.currentProfile
        fullName = profile?.fullName ?? ""
        bio = profile?.bio ?? ""
        country = profile?.country ?? ""
        selectedCategory = profile?.entrepreneurCategory
    }

    private func save() async {
        isLoading = true
        error = nil

        var avatarUrl: String? = nil
        if let img = avatarImage,
           let data = img.jpegData(compressionQuality: 0.8),
           let userId = authService.currentUser?.id {
            avatarUrl = try? await postService.uploadAvatar(data: data, userId: userId)
        }

        let updates = ProfileUpdateRequest(
            username: nil,
            fullName: fullName.isEmpty ? nil : fullName,
            bio: bio.isEmpty ? nil : bio,
            category: selectedCategory?.rawValue,
            country: country.isEmpty ? nil : country,
            timezone: TimeZone.current.identifier,
            avatarUrl: avatarUrl
        )

        do {
            try await authService.updateProfile(updates)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
