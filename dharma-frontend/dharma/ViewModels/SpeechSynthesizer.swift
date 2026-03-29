import AVFoundation

@Observable
final class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    enum State { case idle, speaking, paused }

    private(set) var state: State = .idle
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        state = .speaking
    }

    func togglePlayPause() {
        switch state {
        case .speaking:
            synthesizer.pauseSpeaking(at: .word)
            state = .paused
        case .paused:
            synthesizer.continueSpeaking()
            state = .speaking
        case .idle:
            break
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        state = .idle
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        state = .idle
    }
}
