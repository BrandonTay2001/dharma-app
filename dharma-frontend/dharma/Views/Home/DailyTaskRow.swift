import SwiftUI

struct DailyTaskRow: View {
    let task: DailyTask
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DharmaTheme.Spacing.lg) {
                // Icon
                Text(task.icon)
                    .font(.system(size: 32))
                    .frame(width: 50)
                
                // Title & Duration
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title.replacingOccurrences(of: "\n", with: " "))
                        .font(DharmaTheme.Typography.uiHeadline(15))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .lineLimit(1)
                    
                    Text(task.duration)
                        .font(DharmaTheme.Typography.uiCaption(12))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Status badge
                if task.isCompleted {
                    Text("DONE")
                        .font(DharmaTheme.Typography.uiLabel(11))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                        .padding(.horizontal, DharmaTheme.Spacing.md)
                        .padding(.vertical, DharmaTheme.Spacing.xs)
                        .background(DharmaTheme.Colors.saffron.opacity(0.12))
                        .cornerRadius(DharmaTheme.Radius.xl)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .background(task.color)
            .cornerRadius(DharmaTheme.Radius.lg)
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
