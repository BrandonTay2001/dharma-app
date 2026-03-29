import Foundation

@Observable
@MainActor
class LearnViewModel {
    var articles: [LearnArticle] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private var hasLoaded: Bool = false

    func loadArticles(forceReload: Bool = false) async {
        guard !isLoading else { return }
        guard forceReload || !hasLoaded else { return }
        guard let url = URL(string: "\(APIConfig.baseURL)/api/articles") else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                isLoading = false
                return
            }

            guard httpResponse.statusCode == 200 else {
                if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverError = errorBody["error"] as? String {
                    errorMessage = serverError
                } else {
                    errorMessage = "Server error (status \(httpResponse.statusCode))"
                }
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode(LearnArticlesResponse.self, from: data)
            articles = decoded.articles
            hasLoaded = true
        } catch is CancellationError {
        } catch {
            errorMessage = "Could not load articles. Please try again."
        }

        isLoading = false
    }
}