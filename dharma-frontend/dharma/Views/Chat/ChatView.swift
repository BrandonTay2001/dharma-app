import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var animateDots = false

    private func dismissKeyboard() {
        isInputFocused = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                
                VStack(spacing: DharmaTheme.Spacing.xs) {
                    Text("Spiritual Guidance")
                        .font(DharmaTheme.Typography.uiTitle(24))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                    
                    Text("\(viewModel.remainingMessages)/\(viewModel.dailyLimit) questions left today")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
            .overlay(alignment: .trailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.startNewConversation()
                    }
                } label: {
                    Image(systemName: "plus.bubble")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(
                            viewModel.messages.isEmpty
                                ? DharmaTheme.Colors.secondaryText.opacity(0.4)
                                : DharmaTheme.Colors.saffron
                        )
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.messages.isEmpty)
                .padding(.trailing, DharmaTheme.Spacing.sm)
            }
            .padding(.top, DharmaTheme.Spacing.lg)
            .padding(.bottom, DharmaTheme.Spacing.md)
            
            Divider()
                .opacity(0.3)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: DharmaTheme.Spacing.lg) {
                        if viewModel.messages.isEmpty {
                            emptyState
                                .padding(.top, DharmaTheme.Spacing.xxxl)
                        }
                        
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isTyping {
                            typingIndicator
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.lg)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isTyping) {
                    if viewModel.isTyping {
                        withAnimation {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Error banner
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                    Spacer()
                    Button {
                        viewModel.errorMessage = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.sm)
                .background(Color.orange.opacity(0.1))
            }
            
            // Input bar
            inputBar
        }
        .background(Color.white)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: DharmaTheme.Spacing.lg) {
            Text("🙏")
                .font(.system(size: 48))
            
            Text("Ask for guidance")
                .font(DharmaTheme.Typography.uiHeadline(18))
                .foregroundColor(DharmaTheme.Colors.onSurface)
            
            Text("Explore wisdom from Hindu and Buddhist traditions.\nAsk about dharma, karma, meditation, or any spiritual topic.")
                .font(DharmaTheme.Typography.uiBody(14))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Suggestion chips
            VStack(spacing: DharmaTheme.Spacing.sm) {
                suggestionChip("How can I practice mindfulness daily?")
                suggestionChip("What does the Bhagavad Gita say about duty?")
                suggestionChip("Explain the Four Noble Truths")
            }
        }
        .padding(.horizontal, DharmaTheme.Spacing.xl)
    }
    
    private func suggestionChip(_ text: String) -> some View {
        Button {
            viewModel.inputText = text
            viewModel.sendMessage()
        } label: {
            Text(text)
                .font(DharmaTheme.Typography.uiBody(14))
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(DharmaTheme.Colors.surface)
                .cornerRadius(DharmaTheme.Radius.md)
        }
    }
    
    // MARK: - Typing Indicator
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(DharmaTheme.Colors.saffron.opacity(0.7))
                        .frame(width: 8, height: 8)
                        .opacity(animateDots ? 1.0 : 0.2)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.25),
                            value: animateDots
                        )
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .background(DharmaTheme.Colors.saffron.opacity(0.12))
            .cornerRadius(DharmaTheme.Radius.lg)
            .onAppear { animateDots = true }
            .onDisappear { animateDots = false }
            
            Spacer()
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: DharmaTheme.Spacing.md) {
            TextField("Ask for guidance...", text: $viewModel.inputText, axis: .vertical)
                .font(DharmaTheme.Typography.uiBody())
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .tint(DharmaTheme.Colors.saffron)
                .lineLimit(1...4)
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(DharmaTheme.Colors.surface)
                .cornerRadius(DharmaTheme.Radius.xl)
                .focused($isInputFocused)
            
            Button {
                viewModel.sendMessage()
                isInputFocused = false
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        viewModel.canSendMessage
                            ? DharmaTheme.Colors.saffron
                            : DharmaTheme.Colors.surfaceContainer
                    )
                    .cornerRadius(DharmaTheme.Radius.md)
            }
            .disabled(!viewModel.canSendMessage)
        }
        .padding(.horizontal, DharmaTheme.Spacing.lg)
        .padding(.vertical, DharmaTheme.Spacing.md)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
        )
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel())
}
