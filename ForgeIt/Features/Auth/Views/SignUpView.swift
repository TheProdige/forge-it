import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) var authVM
    let onSignIn: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordMismatch = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button(action: onSignIn) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Sign in")
                    }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.lg)

                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Start building.")
                        .font(AppTypography.heading)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Join thousands of entrepreneurs sharing their grind.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xl)
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
                        placeholder: "Min. 8 characters",
                        text: $password
                    )

                    AppSecureField(
                        label: "Confirm password",
                        placeholder: "Repeat your password",
                        text: $confirmPassword
                    )
                }

                // Errors
                Group {
                    if passwordMismatch {
                        Text("Passwords don't match.")
                            .font(AppTypography.bodySmall)
                            .foregroundStyle(AppColors.error)
                    }
                    if let error = authVM.error {
                        Text(error)
                            .font(AppTypography.bodySmall)
                            .foregroundStyle(AppColors.error)
                    }
                }
                .padding(.top, AppSpacing.sm)

                // Create account button
                Button {
                    guard password == confirmPassword else {
                        passwordMismatch = true
                        return
                    }
                    passwordMismatch = false
                    Task {
                        authVM.email = email
                        authVM.password = password
                        await authVM.signUp()
                    }
                } label: {
                    Group {
                        if authVM.isLoading {
                            ProgressView().tint(AppColors.textInverse)
                        } else {
                            Text("Create account")
                        }
                    }
                    .primaryButton()
                }
                .disabled(authVM.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                .opacity((email.isEmpty || password.isEmpty || confirmPassword.isEmpty) ? 0.5 : 1)
                .padding(.top, AppSpacing.lg)

                // Terms
                Text("By creating an account, you agree to our Terms of Service.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.md)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .screenBackground()
    }
}
