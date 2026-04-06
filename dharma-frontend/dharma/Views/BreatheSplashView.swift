import SwiftUI

struct BreatheSplashView: View {
    var onFinished: () -> Void

    @State private var phase: Phase = .breatheIn
    @State private var textOpacity: Double = 0

    private enum Phase {
        case breatheIn
        case breatheOut
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: DharmaTheme.Spacing.xxl) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                Text(phase == .breatheOut ? "Breathe out..." : "Breathe in...")
                    .font(DharmaTheme.Typography.scriptureHeadline(26))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .opacity(textOpacity)
            }
        }
        .task {
            // Fade in "Breathe in..."
            withAnimation(.easeIn(duration: 0.6)) {
                textOpacity = 1
            }

            // Hold for 2 seconds, then switch to "Breathe out..."
            try? await Task.sleep(for: .seconds(2))

            withAnimation(.easeInOut(duration: 0.4)) {
                textOpacity = 0
            }
            try? await Task.sleep(for: .seconds(0.4))

            phase = .breatheOut
            withAnimation(.easeIn(duration: 0.6)) {
                textOpacity = 1
            }

            // Hold for 2 seconds, then finish
            try? await Task.sleep(for: .seconds(2))

            withAnimation(.easeOut(duration: 0.4)) {
                textOpacity = 0
            }
            try? await Task.sleep(for: .seconds(0.4))

            onFinished()
        }
    }
}
