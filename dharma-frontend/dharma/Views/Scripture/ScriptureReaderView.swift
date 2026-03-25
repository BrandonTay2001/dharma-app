import SwiftUI

struct ScriptureReaderView: View {
    @Bindable var viewModel: ScriptureViewModel
    @State private var showChapterPicker = false
    @State private var audioPlaying = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Verse content
            ScrollView(showsIndicators: false) {
                if let chapter = viewModel.selectedChapter {
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xxxl) {
                        ForEach(chapter.verses) { verse in
                            verseRow(verse)
                        }
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.top, DharmaTheme.Spacing.xxl)
                    .padding(.bottom, 100) // Space for audio bar
                }
            }
            
            // Bottom audio bar (glassmorphism)
            audioBar
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Button {
                    showChapterPicker.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 14))
                        if let scripture = viewModel.selectedScripture,
                           let chapter = viewModel.selectedChapter {
                            Text("\(shortName(scripture)) \(chapter.number)")
                                .font(DharmaTheme.Typography.uiHeadline(16))
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DharmaTheme.Colors.surfaceContainerLow)
                    .cornerRadius(DharmaTheme.Radius.xl)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Settings placeholder
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
            }
        }
        .sheet(isPresented: $showChapterPicker) {
            chapterPickerSheet
        }
    }
    
    // MARK: - Verse Row
    private func verseRow(_ verse: Verse) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: DharmaTheme.Spacing.sm) {
                // Saffron verse number
                Text("\(verse.number).")
                    .font(DharmaTheme.Typography.scriptureBody(20))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                    .frame(width: 30, alignment: .leading)
                
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    // Speaker attribution
                    if let speaker = verse.speaker {
                        Text("\(speaker) said:")
                            .font(DharmaTheme.Typography.scriptureBody(20))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                            .fontWeight(.semibold)
                    }
                    
                    // Verse text
                    Text(verse.text)
                        .font(DharmaTheme.Typography.scriptureBody(20))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .lineSpacing(6)
                }
            }
        }
    }
    
    // MARK: - Audio Bar
    private var audioBar: some View {
        HStack(spacing: DharmaTheme.Spacing.lg) {
            Button {
                audioPlaying.toggle()
            } label: {
                Image(systemName: audioPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(DharmaTheme.Colors.saffron)
            }
            
            // Progress slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DharmaTheme.Colors.surfaceContainerLow)
                        .frame(height: 3)
                    
                    Capsule()
                        .fill(DharmaTheme.Colors.saffron)
                        .frame(width: geometry.size.width * 0.15, height: 3)
                    
                    Circle()
                        .fill(DharmaTheme.Colors.saffron)
                        .frame(width: 10, height: 10)
                        .offset(x: geometry.size.width * 0.15 - 5)
                }
            }
            .frame(height: 10)
            
            Button {
                // Volume toggle
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
        }
        .padding(.horizontal, DharmaTheme.Spacing.xl)
        .padding(.vertical, DharmaTheme.Spacing.lg)
        .background(
            Color.white.opacity(0.9)
                .background(.ultraThinMaterial)
        )
        .cornerRadius(DharmaTheme.Radius.xl)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
        .padding(.horizontal, DharmaTheme.Spacing.md)
        .padding(.bottom, DharmaTheme.Spacing.sm)
    }
    
    // MARK: - Chapter Picker
    private var chapterPickerSheet: some View {
        NavigationStack {
            List {
                if let scripture = viewModel.selectedScripture {
                    ForEach(Array(scripture.chapters.enumerated()), id: \.element.id) { index, chapter in
                        Button {
                            viewModel.selectChapter(index)
                            showChapterPicker = false
                        } label: {
                            HStack {
                                Text("Chapter \(chapter.number)")
                                    .font(DharmaTheme.Typography.scriptureCaption())
                                    .foregroundColor(DharmaTheme.Colors.saffron)
                                
                                Text(chapter.title)
                                    .font(DharmaTheme.Typography.uiBody())
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                
                                Spacer()
                                
                                if index == viewModel.selectedChapterIndex {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DharmaTheme.Colors.saffron)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showChapterPicker = false
                    }
                    .foregroundColor(DharmaTheme.Colors.saffron)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func shortName(_ scripture: Scripture) -> String {
        if scripture.title.contains("Gita") { return "Gita" }
        if scripture.title.contains("Dhamma") { return "Dhammapada" }
        return scripture.title
    }
}

#Preview {
    NavigationStack {
        ScriptureReaderView(viewModel: {
            let vm = ScriptureViewModel()
            vm.selectScripture(Scripture.bhagavadGita)
            vm.selectChapter(1) // Chapter 2
            return vm
        }())
    }
}
