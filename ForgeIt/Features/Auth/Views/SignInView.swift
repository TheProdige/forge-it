import SwiftUI

struct SignInView: View {
    @Environment(AuthViewModel.self) var authVM
    let onSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Welcome back.")
                        .font(AppTypography.heading)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Keep the streak alive.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xxxl)
                .padding(.bottom, AppSpacing.xxl)

                // Form
                VStack(spacing: AppSpacing.md) {
                    AppTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )

                    AppSecureField(
                        label: "Password",
                        placeholder: "••••••••",
                        text: $password
                    )
                }

                // Error
                if let error = authVM.error {
                    Text(error)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppColors.error)
                        .padding(.top, AppSpacing.sm)
                }

                // Sign In Button
                Button {
                    Task {
                        authVM.email = email
                        authVM.password = password
                        await authVM.signIn()
                    }
                } label: {
                    Group {
                        if authVM.isLoading {
                            ProgressView().tint(AppColors.textInverse)
                        } else {
                            Text("Sign in")
                        }
                    }
                    .primaryButton()
                }
                .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                .padding(.top, AppSpacing.lg)

                // Sign Up link
                HStack {
                    Text("New here?")
                        .foregroundStyle(AppColors.textSecondary)
                    Button("Create an account", action: onSignUp)
                        .foregroundStyle(AppColors.accent)
                }
                .font(AppTypography.body)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.lg)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .screenBackground()
    }
}
