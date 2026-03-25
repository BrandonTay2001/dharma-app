import SwiftUI

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    let dailyLimit: Int = 5
    var messagesUsedToday: Int = 0
    var inputText: String = ""
    var isTyping: Bool = false
    
    var remainingMessages: Int {
        max(0, dailyLimit - messagesUsedToday)
    }
    
    var canSendMessage: Bool {
        remainingMessages > 0 && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }
    
    // Pre-seeded AI responses for the prototype
    private let aiResponses: [String] = [
        "Namaste. Mindfulness can be practiced through simple breath awareness during daily tasks. The Gita teaches that duty (dharma) should be performed without attachment to the results. It is a path to liberation. Om Shanti.",
        "The Buddha taught the Four Noble Truths: life involves suffering (dukkha), suffering arises from craving (tanha), suffering can cease (nirodha), and the path to cessation is the Noble Eightfold Path. This is the foundation of all Buddhist practice.",
        "In the Bhagavad Gita, Lord Krishna tells Arjuna: 'You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.' This teaching of Nishkama Karma is central to Hindu philosophy.",
        "The Dhammapada reminds us: 'All that we are is the result of what we have thought.' Your mind shapes your reality. Through meditation and mindful living, you can transform your thoughts and find inner peace.",
        "Compassion (karuna) is at the heart of both Hindu and Buddhist traditions. The Dalai Lama teaches: 'If you want others to be happy, practice compassion. If you want to be happy, practice compassion.' Om Mani Padme Hum.",
    ]
    
    private var responseIndex = 0
    
    func sendMessage() {
        guard canSendMessage else { return }
        
        let userMessage = ChatMessage(text: inputText.trimmingCharacters(in: .whitespacesAndNewlines), isUser: true)
        messages.append(userMessage)
        messagesUsedToday += 1
        inputText = ""
        
        // Simulate AI response
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            let response = self.aiResponses[self.responseIndex % self.aiResponses.count]
            let aiMessage = ChatMessage(text: response, isUser: false)
            self.messages.append(aiMessage)
            self.responseIndex += 1
            self.isTyping = false
        }
    }
}
