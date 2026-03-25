import SwiftUI
import Combine

@Observable
class MeditationViewModel {
    var isActive: Bool = false
    var currentStepIndex: Int = 0
    var elapsedTime: TimeInterval = 0
    var phaseElapsed: TimeInterval = 0
    var isSessionComplete: Bool = false
    
    private var timer: Timer?
    
    let steps = MeditationStep.guidedSession
    let totalDuration = MeditationStep.totalDuration
    
    var currentStep: MeditationStep {
        steps[currentStepIndex % steps.count]
    }
    
    var currentInstruction: String {
        currentStep.instruction
    }
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(elapsedTime / totalDuration, 1.0)
    }
    
    var timeRemainingText: String {
        let remaining = max(0, totalDuration - elapsedTime)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Breathing animation scale: expand on inhale, contract on exhale
    var breathingScale: CGFloat {
        switch currentStep.phase {
        case .inhale:
            return 1.0 + CGFloat(phaseElapsed / currentStep.duration) * 0.3
        case .hold:
            return 1.3
        case .exhale:
            return 1.3 - CGFloat(phaseElapsed / currentStep.duration) * 0.3
        case .rest:
            return 1.0
        }
    }
    
    func startSession() {
        isActive = true
        isSessionComplete = false
        elapsedTime = 0
        phaseElapsed = 0
        currentStepIndex = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.05
            self.phaseElapsed += 0.05
            
            // Check if current phase is done
            if self.phaseElapsed >= self.currentStep.duration {
                self.phaseElapsed = 0
                self.currentStepIndex += 1
                // Steps cycle through until time is up
            }
            
            // Check if session is done
            if self.elapsedTime >= self.totalDuration {
                self.completeSession()
            }
        }
    }
    
    func stopSession() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    func completeSession() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isSessionComplete = true
    }
    
    deinit {
        timer?.invalidate()
    }
}
