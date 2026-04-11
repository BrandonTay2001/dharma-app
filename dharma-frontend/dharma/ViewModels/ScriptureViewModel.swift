import Foundation
import Observation
import PostgREST
import Supabase

@Observable
@MainActor
final class ScriptureViewModel {
    var scriptures: [Scripture] = []
    var selectedScripture: Scripture?
    var selectedChapterIndex: Int = 0
    var isLoading = false
    var isLoadingVerses = false
    var errorMessage: String?

    private var hasLoaded = false
    private var loadedScriptureTitles: Set<String> = []
    
    var selectedChapter: Chapter? {
        guard let scripture = selectedScripture else { return nil }
        guard selectedChapterIndex < scripture.chapters.count else { return nil }
        return scripture.chapters[selectedChapterIndex]
    }

    /// Load scripture metadata only (titles, traditions, chapter names — no verses)
    func loadScriptures(forceReload: Bool = false) async {
        guard !isLoading else { return }
        guard forceReload || !hasLoaded else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let chapterTitleRows: [ChapterTitleRecord] = supabase
                .from("chapter_titles")
                .select("scripture_title, chapter_number, chapter_title")
                .order("scripture_title", ascending: true)
                .order("chapter_number", ascending: true)
                .execute()
                .value

            async let metaRows: [ScriptureMetaRecord] = supabase
                .from("scriptures")
                .select("title, tradition")
                .order("title", ascending: true)
                .execute()
                .value

            let loaded = try await buildScriptureList(
                chapterTitles: chapterTitleRows,
                meta: metaRows
            )

            scriptures = loaded
            if forceReload { loadedScriptureTitles.removeAll() }
            syncSelection()
            hasLoaded = true
        } catch {
            print("Scripture load error: \(error)")
            if scriptures.isEmpty {
                selectedScripture = nil
            }
            errorMessage = "Could not load sacred texts right now. Please try again."
        }

        isLoading = false
    }
    
    func selectScripture(_ scripture: Scripture) {
        selectedScripture = scripture
        selectedChapterIndex = 0
    }

    /// Load all verses for a specific scripture on demand
    func loadVerses(for scriptureTitle: String) async {
        guard !isLoadingVerses else { return }
        guard !loadedScriptureTitles.contains(scriptureTitle) else { return }

        isLoadingVerses = true

        do {
            let verseRows: [ScriptureVerseRecord] = try await supabase
                .from("scriptures")
                .select("title, tradition, chapter_number, verse_number, text, traditional_text")
                .eq("title", value: scriptureTitle)
                .order("chapter_number", ascending: true)
                .order("verse_number", ascending: true)
                .limit(10000)
                .execute()
                .value

            populateVerses(for: scriptureTitle, from: verseRows)
            loadedScriptureTitles.insert(scriptureTitle)
        } catch {
            print("Verse load error for \(scriptureTitle): \(error)")
            errorMessage = "Could not load verses. Please try again."
        }

        isLoadingVerses = false
    }
    
    func nextChapter() {
        guard let scripture = selectedScripture else { return }
        if selectedChapterIndex < scripture.chapters.count - 1 {
            selectedChapterIndex += 1
        }
    }
    
    func previousChapter() {
        if selectedChapterIndex > 0 {
            selectedChapterIndex -= 1
        }
    }
    
    func selectChapter(_ index: Int) {
        selectedChapterIndex = index
    }

    private func buildScriptureList(
        chapterTitles: [ChapterTitleRecord],
        meta: [ScriptureMetaRecord]
    ) -> [Scripture] {
        let traditionLookup = Dictionary(
            meta.map { ($0.title, $0.tradition) },
            uniquingKeysWith: { first, _ in first }
        )

        let groupedChapters = Dictionary(grouping: chapterTitles, by: \.scriptureTitle)

        return groupedChapters.keys.sorted().compactMap { scriptureTitle in
            guard let tradition = traditionLookup[scriptureTitle] else { return nil }

            let chapters = (groupedChapters[scriptureTitle] ?? [])
                .sorted { $0.chapterNumber < $1.chapterNumber }
                .map { Chapter(number: $0.chapterNumber, title: $0.chapterTitle, verses: []) }

            return Scripture(title: scriptureTitle, tradition: tradition, chapters: chapters)
        }
    }

    private func populateVerses(for scriptureTitle: String, from records: [ScriptureVerseRecord]) {
        guard let idx = scriptures.firstIndex(where: { $0.title == scriptureTitle }) else { return }

        let groupedByChapter = Dictionary(grouping: records, by: \.chapterNumber)
        let existing = scriptures[idx]

        let updatedChapters = existing.chapters.map { chapter in
            let verses = (groupedByChapter[chapter.number] ?? [])
                .sorted { $0.verseNumber < $1.verseNumber }
                .map {
                    Verse(
                        number: $0.verseNumber,
                        speaker: nil,
                        text: $0.text,
                        traditionalText: $0.traditionalText
                    )
                }
            return Chapter(number: chapter.number, title: chapter.title, verses: verses)
        }

        let updated = Scripture(title: existing.title, tradition: existing.tradition, chapters: updatedChapters)
        scriptures[idx] = updated

        if selectedScripture?.title == scriptureTitle {
            selectedScripture = updated
        }
    }

    private func syncSelection() {
        guard !scriptures.isEmpty else {
            selectedScripture = nil
            selectedChapterIndex = 0
            return
        }

        guard let currentTitle = selectedScripture?.title,
              let refreshedScripture = scriptures.first(where: { $0.title == currentTitle }) else {
            if selectedScripture == nil {
                return
            }

            selectedScripture = scriptures.first
            selectedChapterIndex = 0
            return
        }

        selectedScripture = refreshedScripture
        selectedChapterIndex = min(selectedChapterIndex, max(refreshedScripture.chapters.count - 1, 0))
    }
}

private struct ChapterTitleRecord: Decodable {
    let scriptureTitle: String
    let chapterNumber: Int
    let chapterTitle: String

    enum CodingKeys: String, CodingKey {
        case scriptureTitle = "scripture_title"
        case chapterNumber = "chapter_number"
        case chapterTitle = "chapter_title"
    }
}

private struct ScriptureMetaRecord: Decodable {
    let title: String
    let tradition: String
}

private struct ScriptureVerseRecord: Decodable {
    let title: String
    let tradition: String
    let chapterNumber: Int
    let verseNumber: Int
    let text: String
    let traditionalText: String?

    enum CodingKeys: String, CodingKey {
        case title, tradition, text
        case chapterNumber = "chapter_number"
        case verseNumber = "verse_number"
        case traditionalText = "traditional_text"
    }
}
