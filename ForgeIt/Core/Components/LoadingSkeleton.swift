import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0), location: 0),
                            .init(color: Color.white.opacity(0.06), location: 0.3),
                            .init(color: Color.white.opacity(0.12), location: 0.5),
                            .init(color: Color.white.opacity(0.06), location: 0.7),
                            .init(color: Color.white.opacity(0), location: 1),
                        ]),
                        startPoint: .init(x: phase, y: 0),
                        endPoint: .init(x: phase + 1, y: 0)
                    )
                    .frame(width: geo.size.width * 3)
                    .offset(x: -geo.size.width + geo.size.width * phase * 2)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct SkeletonRect: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var radius: CGFloat = AppSpacing.radiusSM

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(AppColors.bgElevated)
            .frame(width: width, height: height)
            .shimmer()
    }
}

struct PostCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.bgElevated)
                    .frame(width: 40, height: 40)
                    .shimmer()
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonRect(width: 120, height: 14)
                    SkeletonRect(width: 80, height: 11)
                }
                Spacer()
            }

            // Image
            SkeletonRect(height: 220, radius: AppSpacing.radiusMD)

            // Caption
            VStack(alignment: .leading, spacing: 6) {
                SkeletonRect(height: 13)
                SkeletonRect(width: 220, height: 13)
            }

            // Reactions
            HStack(spacing: AppSpacing.md) {
                SkeletonRect(width: 70, height: 32, radius: AppSpacing.radiusFull)
                SkeletonRect(width: 70, height: 32, radius: AppSpacing.radiusFull)
                Spacer()
            }
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }
}
