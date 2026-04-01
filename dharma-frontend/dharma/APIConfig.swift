import Foundation

enum APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://dharma-app-production.up.railway.app" // TBD – update for production
    #endif

    static let superwallPublicAPIKey = "pk_akJCgEmcKQ84wy2lO5C68"
}
