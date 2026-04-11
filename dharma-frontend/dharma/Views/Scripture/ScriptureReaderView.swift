import SwiftUI

struct ScriptureReaderView: View {
    @Bindable var viewModel: ScriptureViewModel
    @State private var showChapterPicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.isLoadingVerses && (viewModel.selectedChapter?.verses.isEmpty ?? true) {
                VStack(spacing: DharmaTheme.Spacing.md) {
                    ProgressView()
                        .tint(DharmaTheme.Colors.saffron)
                    Text("Loading verses...")
                        .font(DharmaTheme.Typography.uiBody(14))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DharmaTheme.Spacing.xxxl)
            } else if let chapter = viewModel.selectedChapter {
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xxxl) {
                    ForEach(chapter.verses) { verse in
                        verseRow(verse)
                    }
                }
                .padding(.horizontal, DharmaTheme.Spacing.xl)
                .padding(.top, DharmaTheme.Spacing.xxl)
                .padding(.bottom, DharmaTheme.Spacing.xxxl)
            }
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
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(minWidth: 44, alignment: .leading)
                
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    // Speaker attribution
                    if let speaker = verse.speaker {
                        Text("\(speaker) said:")
                            .font(DharmaTheme.Typography.scriptureBody(20))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                            .fontWeight(.semibold)
                    }

                            if let traditionalText = verse.traditionalText,
                               !traditionalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(traditionalText)
                                .font(DharmaTheme.Typography.scriptureBody(22))
                                .foregroundColor(DharmaTheme.Colors.saffronDark)
                                .lineSpacing(8)
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
