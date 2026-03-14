import SwiftUI
import PhotosUI

struct ImageUploader: View {
    let selectedImage: UIImage?
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLG))
                        .overlay(
                            // Edit hint overlay
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Change")
                                    .font(AppTypography.captionBold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(AppSpacing.sm),
                            alignment: .bottomTrailing
                        )
                } else {
                    uploadPlaceholder
                }
            }
        }
    }

    private var uploadPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppSpacing.radiusLG)
                .fill(AppColors.bgCard)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusLG)
                        .strokeBorder(
                            AppColors.border,
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                )

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.accent)
                Text("Add a photo")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Show what you're working on")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(AppColors.textMuted)
            }
        }
    }
}
