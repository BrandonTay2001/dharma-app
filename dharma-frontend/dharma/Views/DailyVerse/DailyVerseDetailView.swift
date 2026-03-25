import SwiftUI

struct DailyVerseDetailView: View {
    let verseType: DailyTask.TaskType
    let onDone: () -> Void
    @State private var showReflection = false
    @State private var reflectionText = ""
    @Environment(\.dismiss) private var dismiss
    
    private var verseTitle: String {
        switch verseType {
        case .hinduVerse:
            return "VERSE OF THE DAY • GITA"
        case .buddhistVerse:
            return "VERSE OF THE DAY • DHAMMAPADA"
        default:
            return "VERSE OF THE DAY"
        }
    }
    
    private var verseText: String {
        switch verseType {
        case .hinduVerse:
            return "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of the results of your activities, nor be attached to inaction.\n\n— Bhagavad Gita 2.47"
        case .buddhistVerse:
            return "All that we are is the result of what we have thought: it is founded on our thoughts, it is made up of our thoughts. If a man speaks or acts with a pure thought, happiness follows him, like a shadow that never leaves him.\n\n— Dhammapada 1.2"
        default:
            return "O Seeker of Truth, open your heart to the path of enlightenment. Embrace the wisdom that guides you towards inner peace and understanding."
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DharmaTheme.Spacing.xxl) {
                        // Verse Card
                        VStack(spacing: DharmaTheme.Spacing.xl) {
                            // Lotus icon
                            Text("🪷")
                                .font(.system(size: 48))
                                .padding(.top, DharmaTheme.Spacing.xxl)
                            
                            // Label
                            Text(verseTitle)
                                .font(DharmaTheme.Typography.uiLabel(13))
                                .foregroundColor(DharmaTheme.Colors.saffron)
                                .tracking(1.5)
                            
                            // Verse text
                            Text(verseText)
                                .font(DharmaTheme.Typography.scriptureBody(20))
                                .foregroundColor(DharmaTheme.Colors.onSurface)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, DharmaTheme.Spacing.lg)
                                .padding(.bottom, DharmaTheme.Spacing.xxl)
                        }
                        .frame(maxWidth: .infinity)
                        .background(DharmaTheme.Colors.surface)
                        .cornerRadius(DharmaTheme.Radius.lg)
                        .padding(.horizontal, DharmaTheme.Spacing.sm)
                        
                        // Reflection area
                        if showReflection {
                            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                                Text("Your Reflection")
                                    .font(DharmaTheme.Typography.uiHeadline(16))
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                
                                TextEditor(text: $reflectionText)
                                    .font(DharmaTheme.Typography.uiBody())
                                    .frame(minHeight: 100)
                                    .padding(DharmaTheme.Spacing.sm)
                                    .background(DharmaTheme.Colors.surface)
                                    .cornerRadius(DharmaTheme.Radius.md)
                                    .scrollContentBackground(.hidden)
                            }
                            .padding(.horizontal, DharmaTheme.Spacing.sm)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, DharmaTheme.Spacing.lg)
                }
                
                // Bottom action bar
                HStack(spacing: DharmaTheme.Spacing.sm) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showReflection.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 16))
                            Text("Reflection")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    
                    Button {
                        // Chat to learn more action (placeholder)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 14))
                            Text("Chat to learn more")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    
                    Spacer()
                    
                    Button("Done") {
                        onDone()
                    }
                    .buttonStyle(.saffron)
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
                )
            }
            .background(Color.white)
            .navigationTitle("Your Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                    }
                }
            }
        }
    }
}

#Preview {
    DailyVerseDetailView(verseType: .hinduVerse) {}
}
