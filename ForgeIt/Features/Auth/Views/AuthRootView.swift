import SwiftUI

struct AuthRootView: View {
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            AppColors.bgPrimary.ignoresSafeArea()

            if showSignUp {
                SignUpView(onSignIn: { showSignUp = false })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                SignInView(onSignUp: { showSignUp = true })
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSignUp)
    }
}
