import SwiftUI

struct DailyTaskCard: View {
    let task: DailyTask
    let actionTitle: String?
    let onTap: () -> Void

    init(task: DailyTask, actionTitle: String? = nil, onTap: @escaping () -> Void) {
        self.task = task
        self.actionTitle = actionTitle
        self.onTap = onTap
    }

    private var statusTitle: String {
        if let actionTitle {
            return actionTitle
        }

        return task.isCompleted ? "DONE" : "START"
    }

    private var statusForegroundColor: Color {
        if actionTitle != nil {
            return .white
        }

        return task.isCompleted ? DharmaTheme.Colors.onSurface : .white
    }

    private var statusBackgroundColor: Color {
        if actionTitle != nil {
            return DharmaTheme.Colors.saffron.opacity(0.8)
        }

        return task.isCompleted ? .white : DharmaTheme.Colors.saffron.opacity(0.8)
    }
    
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
                Text(statusTitle)
                    .font(DharmaTheme.Typography.uiLabel(12))
                    .foregroundColor(statusForegroundColor)
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.sm)
                    .background(statusBackgroundColor)
                    .cornerRadius(DharmaTheme.Radius.xl)
                
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
