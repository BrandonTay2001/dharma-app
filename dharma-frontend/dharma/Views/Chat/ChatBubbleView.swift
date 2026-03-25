import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .lineSpacing(4)
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(
                    message.isUser
                        ? DharmaTheme.Colors.userBubble
                        : DharmaTheme.Colors.saffron.opacity(0.12)
                )
                .cornerRadius(DharmaTheme.Radius.lg)
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubbleView(message: ChatMessage(text: "How can I practice mindfulness daily?", isUser: true))
        ChatBubbleView(message: ChatMessage(text: "Namaste. Mindfulness can be practiced through simple breath awareness during daily tasks. The Gita teaches that duty (dharma) should be performed without attachment to the results.", isUser: false))
    }
    .padding()
}
