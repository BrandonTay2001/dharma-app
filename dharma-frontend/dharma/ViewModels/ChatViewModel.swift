import SwiftUI

@Observable
@MainActor
class ChatViewModel {
    var messages: [ChatMessage] = []
    let dailyLimit: Int = 5
    var messagesUsedToday: Int = 0
    var inputText: String = ""
    var isTyping: Bool = false
    var errorMessage: String?
    
    var remainingMessages: Int {
        max(0, dailyLimit - messagesUsedToday)
    }
    
    var canSendMessage: Bool {
        remainingMessages > 0 && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }
    
    // Conversation history sent to the backend for context
    private var conversationHistory: [[String: String]] = []
    
    func startNewConversation() {
        messages.removeAll()
        conversationHistory.removeAll()
        inputText = ""
        errorMessage = nil
        isTyping = false
    }
    
    func sendMessage() {
        guard canSendMessage else { return }
        
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        messages.append(userMessage)
        messagesUsedToday += 1
        inputText = ""
        errorMessage = nil
        
        // Add to conversation history
        conversationHistory.append(["role": "user", "content": trimmedText])
        
        isTyping = true
        
        Task {
            await fetchAIResponse()
        }
    }
    
    private func fetchAIResponse() async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/chat") else {
            errorMessage = "Invalid API URL"
            isTyping = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body: [String: Any] = ["messages": conversationHistory]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            errorMessage = "Failed to encode request"
            isTyping = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                isTyping = false
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to parse error message from response
                if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverError = errorBody["error"] as? String {
                    errorMessage = serverError
                } else {
                    errorMessage = "Server error (status \(httpResponse.statusCode))"
                }
                isTyping = false
                return
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let reply = json["reply"] as? String else {
                errorMessage = "Unexpected response format"
                isTyping = false
                return
            }
            
            // Success – append assistant message
            let aiMessage = ChatMessage(text: reply, isUser: false)
            messages.append(aiMessage)
            conversationHistory.append(["role": "assistant", "content": reply])
            
        } catch is CancellationError {
            // Task was cancelled, no need to show error
        } catch {
            errorMessage = "Could not reach the server. Please check your connection."
        }
        
        isTyping = false
    }
}
