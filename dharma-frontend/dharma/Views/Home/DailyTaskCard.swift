import SwiftUI

struct DailyTaskCard: View {
    let task: DailyTask
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DharmaTheme.Spacing.md) {
                Spacer()
                
                // Icon
                Text(task.icon)
                    .font(.system(size: 36))
                
                // Title & Duration
                VStack(spacing: 4) {
                    Text(task.title)
                        .font(DharmaTheme.Typography.uiLabel(12))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("• \(task.duration)")
                        .font(DharmaTheme.Typography.uiCaption(11))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                
                // Done Button/Badge
                if task.isCompleted {
                    Text("DONE")
                        .font(DharmaTheme.Typography.uiLabel(12))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .padding(.horizontal, DharmaTheme.Spacing.xl)
                        .padding(.vertical, DharmaTheme.Spacing.sm)
                        .background(Color.white)
                        .cornerRadius(DharmaTheme.Radius.xl)
                } else {
                    Text("START")
                        .font(DharmaTheme.Typography.uiLabel(12))
                        .foregroundColor(.white)
                        .padding(.horizontal, DharmaTheme.Spacing.xl)
                        .padding(.vertical, DharmaTheme.Spacing.sm)
                        .background(DharmaTheme.Colors.saffron.opacity(0.8))
                        .cornerRadius(DharmaTheme.Radius.xl)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(task.color)
            .cornerRadius(DharmaTheme.Radius.lg)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        DailyTaskCard(
            task: DailyTask.sampleTasks[0],
            onTap: {}
        )
        DailyTaskCard(
            task: DailyTask.sampleTasks[2],
            onTap: {}
        )
    }
    .padding()
}
