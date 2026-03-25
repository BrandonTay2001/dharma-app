import SwiftUI

@Observable
class ScriptureViewModel {
    var scriptures: [Scripture] = Scripture.allScriptures
    var selectedScripture: Scripture?
    var selectedChapterIndex: Int = 0
    
    var selectedChapter: Chapter? {
        guard let scripture = selectedScripture else { return nil }
        guard selectedChapterIndex < scripture.chapters.count else { return nil }
        return scripture.chapters[selectedChapterIndex]
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
}
