import Foundation

enum APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://api.yourproductiondomain.com" // TBD – update for production
    #endif
}
