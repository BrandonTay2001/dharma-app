import SwiftUI

struct SignInView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Header
            VStack(spacing: DharmaTheme.Spacing.sm) {
                Text("Dharma")
                    .font(DharmaTheme.Typography.scriptureDisplay(40))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                
                Text("Your spiritual journey awaits")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxxl)
            
            // Form
            VStack(spacing: DharmaTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    Text("Email")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                    
                    TextField("your@email.com", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .font(DharmaTheme.Typography.uiBody())
                        .padding(DharmaTheme.Spacing.md)
                        .background(DharmaTheme.Colors.surfaceContainerLow)
                        .cornerRadius(DharmaTheme.Radius.md)
                }
                
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    Text("Password")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .font(DharmaTheme.Typography.uiBody())
                        .padding(DharmaTheme.Spacing.md)
                        .background(DharmaTheme.Colors.surfaceContainerLow)
                        .cornerRadius(DharmaTheme.Radius.md)
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Sign In button
                Button {
                    Task { await viewModel.signIn() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.saffron)
                .disabled(viewModel.isLoading)

                HStack(spacing: DharmaTheme.Spacing.sm) {
                    Rectangle()
                        .fill(DharmaTheme.Colors.secondaryText.opacity(0.2))
                        .frame(height: 1)

                    Text("or")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)

                    Rectangle()
                        .fill(DharmaTheme.Colors.secondaryText.opacity(0.2))
                        .frame(height: 1)
                }

                AppleIDSignInButton(
                    onRequest: viewModel.prepareAppleSignInRequest,
                    onCompletion: { result in
                        Task {
                            await viewModel.signInWithApple(result: result)
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            
            Spacer()
            
            // Sign Up link
            HStack(spacing: DharmaTheme.Spacing.xs) {
                Text("Don't have an account?")
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                
                Button("Sign Up") {
                    viewModel.errorMessage = nil
                    showSignUp = true
                }
                .font(DharmaTheme.Typography.uiHeadline(14))
                .foregroundColor(DharmaTheme.Colors.saffron)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxl)
        }
        .background(Color.white)
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(viewModel: viewModel, isPresented: $showSignUp)
        }
    }
}

#Preview {
    SignInView(viewModel: AuthViewModel())
}
