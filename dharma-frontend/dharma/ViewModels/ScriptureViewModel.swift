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
    var errorMessage: String?

    private var hasLoaded = false
    
    var selectedChapter: Chapter? {
        guard let scripture = selectedScripture else { return nil }
        guard selectedChapterIndex < scripture.chapters.count else { return nil }
        return scripture.chapters[selectedChapterIndex]
    }

    func loadScriptures(forceReload: Bool = false) async {
        guard !isLoading else { return }
        guard forceReload || !hasLoaded else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let scriptureRows: [ScriptureRecord] = supabase
                .from("scriptures")
                .select("title, tradition, chapter_number, verse_number, text, traditional_text")
                .order("title", ascending: true)
                .order("chapter_number", ascending: true)
                .order("verse_number", ascending: true)
                .execute()
                .value

            async let chapterTitleRows: [ChapterTitleRecord] = supabase
                .from("chapter_titles")
                .select("scripture_title, chapter_number, chapter_title")
                .order("scripture_title", ascending: true)
                .order("chapter_number", ascending: true)
                .execute()
                .value

            let loadedScriptures = try await buildScriptures(
                from: scriptureRows,
                chapterTitles: chapterTitleRows
            )

            scriptures = loadedScriptures
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

    private func buildScriptures(
        from records: [ScriptureRecord],
        chapterTitles: [ChapterTitleRecord]
    ) -> [Scripture] {
        let chapterTitleLookup = Dictionary(
            uniqueKeysWithValues: chapterTitles.map {
                (ChapterTitleKey(scriptureTitle: $0.scriptureTitle, chapterNumber: $0.chapterNumber), $0.chapterTitle)
            }
        )

        let groupedByTitle = Dictionary(grouping: records, by: \.title)

        return groupedByTitle.keys.sorted().compactMap { title in
            guard let scriptureRecords = groupedByTitle[title],
                  let tradition = scriptureRecords.first?.tradition else {
                return nil
            }

            let groupedByChapter = Dictionary(grouping: scriptureRecords, by: \.chapterNumber)
            let chapters = groupedByChapter.keys.sorted().map { chapterNumber in
                let verses = groupedByChapter[chapterNumber, default: []]
                    .sorted { $0.verseNumber < $1.verseNumber }
                    .map {
                        Verse(
                            number: $0.verseNumber,
                            speaker: nil,
                            text: $0.text,
                            traditionalText: $0.traditionalText
                        )
                    }

                return Chapter(
                    number: chapterNumber,
                    title: chapterTitleLookup[
                        ChapterTitleKey(scriptureTitle: title, chapterNumber: chapterNumber)
                    ] ?? "Chapter \(chapterNumber)",
                    verses: verses
                )
            }

            return Scripture(title: title, tradition: tradition, chapters: chapters)
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

private struct ScriptureRecord: Decodable {
    let title: String
    let tradition: String
    let chapterNumber: Int
    let verseNumber: Int
    let text: String
    let traditionalText: String?

    enum CodingKeys: String, CodingKey {
        case title
        case tradition
        case chapterNumber = "chapter_number"
        case verseNumber = "verse_number"
        case text
        case traditionalText = "traditional_text"
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

private struct ChapterTitleKey: Hashable {
    let scriptureTitle: String
    let chapterNumber: Int
}
