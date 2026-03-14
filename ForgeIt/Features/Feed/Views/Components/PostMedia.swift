import SwiftUI

struct PostMedia: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
            case .failure:
                brokenImageView
            case .empty:
                shimmerPlaceholder
            @unknown default:
                shimmerPlaceholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
        .padding(.horizontal, AppSpacing.cardPaddingH)
    }

    private var shimmerPlaceholder: some View {
        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
            .fill(AppColors.bgElevated)
            .frame(height: 240)
            .shimmer()
            .padding(.horizontal, AppSpacing.cardPaddingH)
    }

    private var brokenImageView: some View {
        ZStack {
            AppColors.bgElevated
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.textMuted)
                Text("Image unavailable")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(AppColors.textMuted)
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
        .padding(.horizontal, AppSpacing.cardPaddingH)
    }
}
