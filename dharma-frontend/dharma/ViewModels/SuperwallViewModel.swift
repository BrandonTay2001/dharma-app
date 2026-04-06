import Foundation
import Observation
import Supabase
import SuperwallKit

@Observable
@MainActor
final class SuperwallViewModel: SuperwallDelegate {
    static let shared = SuperwallViewModel()

    private static var hasConfiguredSDK = false

    let preLoginPlacement = "pre_login_access"

    var isConfigured = false
    var isSubscribed = false
    var hasUnlockedAuthFlow = false
    var errorMessage: String?

    private init() {
        configureIfNeeded()
    }

    func presentPreLoginPaywall() {
        guard isConfigured else {
            hasUnlockedAuthFlow = true
            return
        }

        presentPaywall(for: preLoginPlacement, unlockAuthOnSuccess: true)
    }

    @discardableResult
    func unlockAuthFlowForExistingSubscriber() -> Bool {
        syncSubscriptionState()

        guard isSubscribed || hasUnlockedAuthFlow else {
            return false
        }

        hasUnlockedAuthFlow = true
        return true
    }

    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        isSubscribed = newValue.isActive

        if isSubscribed {
            hasUnlockedAuthFlow = true
        }
    }

    func userAttributesDidChange(newAttributes: [String : Any]) {}

    static func identifyCurrentUser(_ user: User) {
        Task { @MainActor in
            shared.identify(user)
        }
    }

    static func resetIdentity() {
        Task { @MainActor in
            shared.resetUserIdentity()
        }
    }

    private func configureIfNeeded() {
        let apiKey = APIConfig.superwallPublicAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let isMissingAPIKey = apiKey.isEmpty || apiKey.contains("your_superwall_public_api_key")

        guard !isMissingAPIKey else {
            isConfigured = false
            hasUnlockedAuthFlow = true
            return
        }

        if !Self.hasConfiguredSDK {
            Superwall.configure(apiKey: apiKey)
            Self.hasConfiguredSDK = true
        }

        Superwall.shared.delegate = self
        isConfigured = true
        syncSubscriptionState()
    }

    private func identify(_ user: User) {
        guard isConfigured else {
            hasUnlockedAuthFlow = true
            return
        }

        let userId = user.id.uuidString
        Superwall.shared.identify(userId: userId)
        Superwall.shared.setUserAttributes(userAttributes(for: user, userId: userId))
        hasUnlockedAuthFlow = true
        syncSubscriptionState()
    }

    private func resetUserIdentity() {
        guard isConfigured else {
            hasUnlockedAuthFlow = true
            return
        }

        Superwall.shared.reset()
        Superwall.shared.setUserAttributes([
            "auth_state": "anonymous",
            "display_name": nil,
            "email": nil,
            "supabase_user_id": nil
        ])

        syncSubscriptionState()

        if !isSubscribed {
            hasUnlockedAuthFlow = false
        }
    }

    private func userAttributes(for user: User, userId: String) -> [String: Any?] {
        [
            "auth_state": "authenticated",
            "display_name": displayName(from: user),
            "email": user.email,
            "supabase_user_id": userId
        ]
    }

    private func displayName(from user: User) -> String? {
        if case let .string(value)? = user.userMetadata["display_name"], !value.isEmpty {
            return value
        }

        if case let .string(value)? = user.userMetadata["full_name"], !value.isEmpty {
            return value
        }

        return nil
    }

    private func presentPaywall(for placement: String, unlockAuthOnSuccess: Bool) {
        guard isConfigured else {
            if unlockAuthOnSuccess {
                hasUnlockedAuthFlow = true
            }
            return
        }

        errorMessage = nil

        Superwall.shared.register(placement: placement) { [weak self] in
            guard let self else { return }

            self.syncSubscriptionState()

            if unlockAuthOnSuccess && self.isSubscribed {
                self.hasUnlockedAuthFlow = true
            }
        }
    }

    private func syncSubscriptionState() {
        isSubscribed = Superwall.shared.subscriptionStatus.isActive

        if isSubscribed {
            hasUnlockedAuthFlow = true
        }
    }
}