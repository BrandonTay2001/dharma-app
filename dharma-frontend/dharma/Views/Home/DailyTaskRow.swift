import SwiftUI

struct DailyTaskRow: View {
    let task: DailyTask
    let onTap: () -> Void

    private var statusTitle: String {
        task.isCompleted ? "DONE" : "START"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DharmaTheme.Spacing.md) {
                // Icon
                Text(task.icon)
                    .font(.system(size: 28))
                    .frame(width: 36, alignment: .leading)
                
                // Title & Duration
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title.replacingOccurrences(of: "\n", with: " "))
                        .font(DharmaTheme.Typography.uiHeadline(16))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .lineLimit(1)
                    
                    Text(task.duration)
                        .font(DharmaTheme.Typography.uiCaption(13))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                Text(statusTitle)
                    .font(DharmaTheme.Typography.uiLabel(12))
                    .foregroundColor(task.isCompleted ? DharmaTheme.Colors.saffron : .white)
                    .padding(.horizontal, DharmaTheme.Spacing.lg)
                    .padding(.vertical, DharmaTheme.Spacing.sm)
                    .background(task.isCompleted ? Color.white : DharmaTheme.Colors.saffron.opacity(0.85))
                    .cornerRadius(DharmaTheme.Radius.xl)
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .background(task.color)
            .cornerRadius(DharmaTheme.Radius.lg)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        DailyTaskRow(task: DailyTask.sampleTasks[0], onTap: {})
        DailyTaskRow(task: DailyTask.sampleTasks[2], onTap: {})
    }
    .padding()
}
