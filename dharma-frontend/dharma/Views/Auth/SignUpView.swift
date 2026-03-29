import SwiftUI

struct SignUpView: View {
    @Bindable var viewModel: AuthViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    viewModel.errorMessage = nil
                    isPresented = false
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                }
                
                Spacer()
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.top, DharmaTheme.Spacing.lg)
            
            Spacer()
            
            // Header
            VStack(spacing: DharmaTheme.Spacing.sm) {
                Text("Create Account")
                    .font(DharmaTheme.Typography.scriptureHeadline(28))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                
                Text("Begin your path to inner peace")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxxl)
            
            // Form
            VStack(spacing: DharmaTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    Text("Display Name")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                    
                    TextField("Optional", text: $viewModel.displayName)
                        .textContentType(.name)
                        .font(DharmaTheme.Typography.uiBody())
                        .padding(DharmaTheme.Spacing.md)
                        .background(DharmaTheme.Colors.surfaceContainerLow)
                        .cornerRadius(DharmaTheme.Radius.md)
                }

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
                    
                    SecureField("At least 6 characters", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .font(DharmaTheme.Typography.uiBody())
                        .padding(DharmaTheme.Spacing.md)
                        .background(DharmaTheme.Colors.surfaceContainerLow)
                        .cornerRadius(DharmaTheme.Radius.md)
                }
                
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    Text("Confirm Password")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                    
                    SecureField("Confirm password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
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
                
                // Sign Up button
                Button {
                    Task { await viewModel.signUp() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.saffron)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            
            Spacer()
            
            // Sign In link
            HStack(spacing: DharmaTheme.Spacing.xs) {
                Text("Already have an account?")
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                
                Button("Sign In") {
                    viewModel.errorMessage = nil
                    isPresented = false
                }
                .font(DharmaTheme.Typography.uiHeadline(14))
                .foregroundColor(DharmaTheme.Colors.saffron)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxl)
        }
        .background(Color.white)
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel(), isPresented: .constant(true))
}
