import SwiftUI

struct ReactionBar: View {
    let reactions: ReactionCounts
    let onReaction: (ReactionType) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ReactionButton(
                type: .grind,
                count: reactions.grind,
                isActive: reactions.hasGrind,
                action: { onReaction(.grind) }
            )

            ReactionButton(
                type: .respect,
                count: reactions.respect,
                isActive: reactions.hasRespect,
                action: { onReaction(.respect) }
            )

            Spacer()
        }
    }
}

struct ReactionButton: View {
    let type: ReactionType
    let count: Int
    let isActive: Bool
    let action: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
            action()
        } label: {
            HStack(spacing: 5) {
                Text(type.emoji)
                    .font(.system(size: 14))
                    .scaleEffect(isAnimating ? 1.35 : 1.0)

                Text(count > 0 ? "\(count)" : type.label)
                    .font(AppTypography.captionBold)
                    .foregroundStyle(isActive ? activeColor : AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm + 2)
            .padding(.vertical, 7)
            .background(isActive ? activeBackground : AppColors.bgElevated)
            .clipShape(Capsule())
        }
    }

    private var activeColor: Color {
        switch type {
        case .grind: return AppColors.grindOrange
        case .respect: return AppColors.respectBlue
        }
    }

    private var activeBackground: Color {
        switch type {
        case .grind: return AppColors.grindOrange.opacity(0.12)
        case .respect: return AppColors.respectBlue.opacity(0.12)
        }
    }
}
