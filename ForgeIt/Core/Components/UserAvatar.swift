import SwiftUI

struct UserAvatar: View {
    let profile: Profile?
    let size: CGFloat
    var showBorder: Bool = false

    init(profile: Profile?, size: CGFloat = 40, showBorder: Bool = false) {
        self.profile = profile
        self.size = size
        self.showBorder = showBorder
    }

    var body: some View {
        ZStack {
            if let avatarUrl = profile?.avatarUrl, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        initialsView
                    case .empty:
                        shimmerView
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(showBorder ? AppColors.border : Color.clear, lineWidth: 1.5)
        )
    }

    private var initialsView: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.bgElevated, AppColors.bgCard],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(profile?.initials ?? "?")
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var shimmerView: some View {
        AppColors.bgElevated
    }
}
