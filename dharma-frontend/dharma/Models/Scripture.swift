import Foundation

struct Verse: Identifiable {
    let id = UUID()
    let number: Int
    let speaker: String?
    let text: String
}

struct Chapter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let verses: [Verse]
}

struct Scripture: Identifiable {
    let id = UUID()
    let title: String
    let tradition: String // "Hindu" or "Buddhist"
    let chapters: [Chapter]
    let icon: String // SF Symbol name
    
    var chapterCount: Int { chapters.count }
}

// MARK: - Sample Data

extension Scripture {
    static let bhagavadGita = Scripture(
        title: "Bhagavad Gita",
        tradition: "Hindu",
        chapters: [
            Chapter(number: 1, title: "Arjuna's Dilemma", verses: [
                Verse(number: 1, speaker: "Dhritarashtra", text: "O Sanjay, after gathering on the holy field of Kurukshetra, and desiring to fight, what did my sons and the sons of Pandu do?"),
                Verse(number: 2, speaker: "Sanjay", text: "On seeing the army of the Pandavas drawn up in battle array, King Duryodhana approached his teacher Dronacharya and spoke these words."),
                Verse(number: 3, speaker: "Duryodhana", text: "Behold, O Teacher, this mighty army of the sons of Pandu, arranged in battle formation by your talented disciple, the son of Drupada."),
                Verse(number: 4, speaker: nil, text: "Here are heroes, mighty archers, equal in battle to Bhima and Arjuna—Yuyudhana, Virata, and the great warrior Drupada."),
                Verse(number: 5, speaker: nil, text: "There are also great heroic, powerful warriors like Dhrishtaketu, Chekitana, the valiant king of Kashi, Purujit, Kuntibhoja, and Shaibya—the best of men."),
            ]),
            Chapter(number: 2, title: "Transcendent Knowledge", verses: [
                Verse(number: 1, speaker: "Sanjay", text: "To him thus by compassion possessed, with eyes full of tears and agitated, Madhusudana (Krishna) spoke these words."),
                Verse(number: 2, speaker: "The Blessed Lord", text: "Whence has this stain of dejection come to thee, O Arjuna, at this critical moment? It is unknown to noble minds, leads not to heaven, and brings disgrace."),
                Verse(number: 3, speaker: "The Blessed Lord", text: "Yield not to impotence, O Partha. It does not become thee. Cast off this mean faint-heartedness and arise, O scorcher of foes."),
                Verse(number: 4, speaker: "Arjuna", text: "O Madhusudana, how shall I fight in battle with arrows against Bhishma and Drona, who are worthy of reverence, O destroyer of enemies?"),
                Verse(number: 5, speaker: "Arjuna", text: "Better it is, indeed, in this world to beg for food than to slay these great-souled teachers. But if I kill them, even in this world, all my enjoyments of wealth and desires will be stained with blood."),
                Verse(number: 6, speaker: nil, text: "I can hardly tell which will be better, that we should conquer them or that they should conquer us. The sons of Dhritarashtra are standing before us, after slaying whom we should not wish to live."),
                Verse(number: 7, speaker: "Arjuna", text: "My heart is overpowered by the taint of pity. My mind is confused as to duty. I ask Thee: tell me decisively what is good for me. I am Thy disciple. Instruct me, who has taken refuge in Thee."),
                Verse(number: 8, speaker: nil, text: "I do not see that it would remove this sorrow that burns up my senses, even if I should attain prosperous and unrivalled dominion on earth or lordship over the gods."),
            ]),
            Chapter(number: 3, title: "The Yoga of Action", verses: [
                Verse(number: 1, speaker: "Arjuna", text: "O Janardana, if it be thought by Thee that knowledge is superior to action, why then dost Thou ask me to engage in this terrible action, O Keshava?"),
                Verse(number: 2, speaker: "Arjuna", text: "With these seemingly conflicting words, Thou confusest my understanding. Tell me that one way by which I may, for certain, attain the Highest."),
                Verse(number: 3, speaker: "The Blessed Lord", text: "In this world there is a twofold path, as I said before, O sinless one—the path of knowledge for the contemplative, and the path of action for the active."),
            ]),
        ],
        icon: "book.closed.fill"
    )
    
    static let dhammapada = Scripture(
        title: "Dhammapada",
        tradition: "Buddhist",
        chapters: [
            Chapter(number: 1, title: "Twin Verses", verses: [
                Verse(number: 1, speaker: nil, text: "All that we are is the result of what we have thought: it is founded on our thoughts, it is made up of our thoughts. If a man speaks or acts with an evil thought, pain follows him, as the wheel follows the foot of the ox that draws the carriage."),
                Verse(number: 2, speaker: nil, text: "All that we are is the result of what we have thought: it is founded on our thoughts, it is made up of our thoughts. If a man speaks or acts with a pure thought, happiness follows him, like a shadow that never leaves him."),
                Verse(number: 3, speaker: nil, text: "'He abused me, he beat me, he defeated me, he robbed me'—in those who harbour such thoughts hatred will never cease."),
                Verse(number: 4, speaker: nil, text: "'He abused me, he beat me, he defeated me, he robbed me'—in those who do not harbour such thoughts hatred will cease."),
                Verse(number: 5, speaker: nil, text: "For hatred does not cease by hatred at any time: hatred ceases by love. This is an old rule."),
                Verse(number: 6, speaker: nil, text: "The world does not know that we must all come to an end here; but those who know, their quarrels cease at once."),
            ]),
            Chapter(number: 2, title: "On Earnestness", verses: [
                Verse(number: 1, speaker: nil, text: "Earnestness is the path of immortality, thoughtlessness the path of death. Those who are in earnest do not die, those who are thoughtless are as if dead already."),
                Verse(number: 2, speaker: nil, text: "Those who are advanced in earnestness, having understood this clearly, delight in earnestness, and rejoice in the knowledge of the elect."),
                Verse(number: 3, speaker: nil, text: "These wise people, meditative, steady, always possessed of strong powers, attain to Nirvana, the highest happiness."),
                Verse(number: 4, speaker: nil, text: "If an earnest person has roused himself, if he is not forgetful, if his deeds are pure, if he acts with consideration, if he restrains himself, and lives according to law—then his glory will increase."),
            ]),
            Chapter(number: 3, title: "Thought", verses: [
                Verse(number: 1, speaker: nil, text: "As a fletcher makes straight his arrow, a wise man makes straight his trembling and unsteady thought, which is difficult to guard, difficult to hold back."),
                Verse(number: 2, speaker: nil, text: "As a fish taken from his watery home and thrown on the dry ground, our thought trembles all over in order to escape the dominion of Mara, the tempter."),
                Verse(number: 3, speaker: nil, text: "It is good to tame the mind, which is difficult to hold in and flighty, rushing wherever it listeth; a tamed mind brings happiness."),
            ]),
        ],
        icon: "leaf.fill"
    )
    
    static let allScriptures: [Scripture] = [bhagavadGita, dhammapada]
}
