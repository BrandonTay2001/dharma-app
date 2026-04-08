import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var animateDots = false

    private let starterPrompts = [
        "How can I practice mindfulness daily?",
        "What does the Bhagavad Gita say about duty?",
        "Explain the Four Noble Truths"
    ]

    private func dismissKeyboard() {
        isInputFocused = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.top, DharmaTheme.Spacing.lg)
                .padding(.bottom, DharmaTheme.Spacing.xl)
            
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: DharmaTheme.Spacing.lg) {
                            if viewModel.messages.isEmpty {
                                emptyState
                                    .padding(.top, DharmaTheme.Spacing.sm)
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
                        .padding(.bottom, DharmaTheme.Spacing.xl)
                    }

                    if viewModel.messages.isEmpty {
                        starterPromptStrip
                            .padding(.bottom, DharmaTheme.Spacing.md)
                    }

                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                            .padding(.horizontal, DharmaTheme.Spacing.lg)
                            .padding(.bottom, DharmaTheme.Spacing.md)
                    }

                    inputBar
                }
                .scrollDismissesKeyboard(.interactively)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isTyping) {
                    if viewModel.isTyping {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
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

            Spacer()

            Text("Chat")
                .font(DharmaTheme.Typography.uiTitle(22))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Spacer()

            HStack(spacing: DharmaTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DharmaTheme.Colors.saffron.opacity(0.18))
                        .frame(width: 44, height: 44)

                    Text("🪷")
                        .font(.system(size: 20))
                }

                Text("\(viewModel.messagesUsedToday)/\(viewModel.dailyLimit)")
                    .font(DharmaTheme.Typography.uiHeadline(16))
                    .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                    .monospacedDigit()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DharmaTheme.Colors.saffron.opacity(0.18))
                    .frame(width: 44, height: 44)

                Text("🪷")
                    .font(.system(size: 22))
            }

            Text("Feel free to ask me anything about spirituality!")
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var starterPromptStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DharmaTheme.Spacing.md) {
                ForEach(starterPrompts, id: \.self) { prompt in
                    suggestionChip(prompt)
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
        }
    }

    private func suggestionChip(_ text: String) -> some View {
        Button {
            dismissKeyboard()
            viewModel.sendPrefilledMessage(text)
        } label: {
            HStack(spacing: DharmaTheme.Spacing.md) {
                Text(text)
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DharmaTheme.Colors.secondaryText.opacity(0.6))
            }
            .frame(width: 260)
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .frame(height: 64)
            .background(Color(hex: "FFF8F2"))
            .overlay(
                RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg)
                    .stroke(Color(hex: "E8DDD4"), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg))
        }
    }

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
            .background(DharmaTheme.Colors.saffron.opacity(0.14))
            .cornerRadius(DharmaTheme.Radius.lg)
            .onAppear { animateDots = true }
            .onDisappear { animateDots = false }
            
            Spacer()
        }
    }

    private func errorBanner(_ error: String) -> some View {
        HStack(spacing: DharmaTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DharmaTheme.Colors.saffronDark)

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
        .padding(.vertical, DharmaTheme.Spacing.md)
        .background(DharmaTheme.Colors.saffron.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg))
    }

    private var inputBar: some View {
        HStack(spacing: DharmaTheme.Spacing.md) {
            TextField("Start type to ask ...", text: $viewModel.inputText, axis: .vertical)
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
                dismissKeyboard()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        viewModel.canSendMessage
                            ? DharmaTheme.Colors.saffron
                            : DharmaTheme.Colors.surfaceContainer
                    )
                    .clipShape(Circle())
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
