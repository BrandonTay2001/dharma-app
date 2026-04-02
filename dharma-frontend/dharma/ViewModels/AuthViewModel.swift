import Foundation
import CryptoKit
import AuthenticationServices
import Observation
import Supabase

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var isDeletingAccount = false
    var errorMessage: String?
    var isAuthenticated = false
    var currentUserEmail: String?
    var currentUserDisplayName: String?
    private var appleSignInNonce: String?
    
    // Sign-up specific
    var confirmPassword = ""
    var displayName = ""

    var primaryIdentityLabel: String {
        let trimmedDisplayName = currentUserDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let trimmedDisplayName, !trimmedDisplayName.isEmpty {
            return trimmedDisplayName
        }

        return currentUserEmail ?? "Dharma"
    }

    var secondaryIdentityLabel: String? {
        guard let currentUserEmail, currentUserDisplayName != nil else {
            return nil
        }

        return currentUserEmail
    }

    var avatarInitial: String {
        let source = primaryIdentityLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(source.prefix(1)).uppercased()
    }
    
    init() {
        // Check for existing session on launch
        Task { await checkSession() }
    }
    
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            SuperwallViewModel.identifyCurrentUser(session.user)
            await MainActor.run {
                self.isAuthenticated = true
            }
            await updateCurrentUser(from: session.user)
        } catch {
            SuperwallViewModel.resetIdentity()
            await MainActor.run {
                self.isAuthenticated = false
                self.clearCurrentUser()
            }
        }
    }
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            SuperwallViewModel.identifyCurrentUser(session.user)
            await updateCurrentUser(from: session.user)
            await MainActor.run {
                self.isAuthenticated = true
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }

    @MainActor
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        errorMessage = nil

        let nonce = Self.randomNonce()
        appleSignInNonce = nonce
        request.requestedScopes = [.email]
        request.nonce = Self.sha256(nonce)
    }

    func signInWithApple(result: Result<ASAuthorization, Error>) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        defer {
            Task { @MainActor in
                self.appleSignInNonce = nil
                self.isLoading = false
            }
        }

        do {
            let authorization = try result.get()

            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                await MainActor.run {
                    self.errorMessage = "Could not read the Apple ID credential."
                }
                return
            }

            guard let nonce = await MainActor.run(body: { self.appleSignInNonce }) else {
                await MainActor.run {
                    self.errorMessage = "Missing Apple sign-in nonce. Please try again."
                }
                return
            }

            guard
                let identityToken = credential.identityToken,
                let idToken = String(data: identityToken, encoding: .utf8)
            else {
                await MainActor.run {
                    self.errorMessage = "Could not read the Apple identity token."
                }
                return
            }

            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            SuperwallViewModel.identifyCurrentUser(session.user)
            await updateCurrentUser(from: session.user)

            await MainActor.run {
                self.isAuthenticated = true
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: signupMetadata
            )
            
            // If Supabase returns a session, the user is auto-confirmed
            if let session = response.session {
                SuperwallViewModel.identifyCurrentUser(session.user)
                await updateCurrentUser(from: session.user)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.clearForm()
                }
            } else {
                SuperwallViewModel.identifyCurrentUser(response.user)
                await updateCurrentUser(from: response.user)
                await MainActor.run {
                    self.errorMessage = "Check your email to confirm your account."
                    self.clearForm()
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            SuperwallViewModel.resetIdentity()
            await MainActor.run {
                self.isAuthenticated = false
                self.clearCurrentUser()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func deleteAccount() async -> Bool {
        await MainActor.run {
            self.isDeletingAccount = true
            self.errorMessage = nil
        }

        do {
            let session = try await supabase.auth.session

            guard let url = URL(string: "\(APIConfig.baseURL)/api/account") else {
                await MainActor.run {
                    self.errorMessage = "Invalid API URL"
                    self.isDeletingAccount = false
                }
                return false
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    self.errorMessage = "Invalid server response"
                    self.isDeletingAccount = false
                }
                return false
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverError = errorBody["error"] as? String {
                    await MainActor.run {
                        self.errorMessage = serverError
                        self.isDeletingAccount = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Server error (status \(httpResponse.statusCode))"
                        self.isDeletingAccount = false
                    }
                }
                return false
            }

            try? await supabase.auth.signOut()
            SuperwallViewModel.resetIdentity()

            await MainActor.run {
                self.isAuthenticated = false
                self.clearCurrentUser()
                self.clearForm()
                self.isDeletingAccount = false
            }

            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Could not delete your account. Please try again."
                self.isDeletingAccount = false
            }
            return false
        }
    }

    private var signupMetadata: [String: AnyJSON]? {
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDisplayName.isEmpty else {
            return nil
        }

        return ["display_name": .string(trimmedDisplayName)]
    }

    @MainActor
    private func updateCurrentUser(from user: User) {
        currentUserEmail = user.email
        currentUserDisplayName = metadataDisplayName(from: user)
    }

    @MainActor
    private func clearCurrentUser() {
        currentUserEmail = nil
        currentUserDisplayName = nil
    }

    private func metadataDisplayName(from user: User) -> String? {
        if case let .string(value)? = user.userMetadata["display_name"], !value.isEmpty {
            return value
        }

        if case let .string(value)? = user.userMetadata["full_name"], !value.isEmpty {
            return value
        }

        return nil
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
    }

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms = (0 ..< 16).map { _ in UInt8.random(in: 0 ... 255) }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
