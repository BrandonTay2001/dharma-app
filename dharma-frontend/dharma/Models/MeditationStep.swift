import Foundation

struct MeditationStep: Identifiable {
    let id = UUID()
    let instruction: String
    let duration: TimeInterval // seconds for this phase
    let phase: Phase
    
    enum Phase: String {
        case inhale = "Inhale peace..."
        case hold = "Hold gently..."
        case exhale = "Exhale stress"
        case rest = "Rest in stillness..."
    }
}

extension MeditationStep {
    static let guidedSession: [MeditationStep] = [
        MeditationStep(instruction: "Inhale peace...", duration: 4, phase: .inhale),
        MeditationStep(instruction: "Hold gently...", duration: 4, phase: .hold),
        MeditationStep(instruction: "Exhale stress", duration: 6, phase: .exhale),
        MeditationStep(instruction: "Rest in stillness...", duration: 2, phase: .rest),
    ]
    
    static let totalDuration: TimeInterval = 180 // 3 minutes
}
