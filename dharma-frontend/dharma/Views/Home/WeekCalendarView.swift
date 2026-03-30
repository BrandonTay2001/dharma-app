import SwiftUI

struct WeekCalendarView: View {
    let dates: [(dayLabel: String, dateNumber: Int, isToday: Bool, isCompleted: Bool)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(dates.enumerated()), id: \.offset) { _, item in
                VStack(spacing: DharmaTheme.Spacing.sm) {
                    Text(item.dayLabel)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(
                            item.isToday
                                ? DharmaTheme.Colors.onSurface
                                : DharmaTheme.Colors.secondaryText
                        )
                        .fontWeight(item.isToday ? .bold : .medium)
                    
                    ZStack {
                        if item.isCompleted {
                            Circle()
                                .fill(DharmaTheme.Colors.saffron)
                                .frame(width: 38, height: 38)
                        } else if item.isToday {
                            Circle()
                                .stroke(DharmaTheme.Colors.saffron, lineWidth: 2.5)
                                .frame(width: 38, height: 38)
                        } else {
                            Circle()
                                .stroke(DharmaTheme.Colors.surfaceContainer, lineWidth: 1.5)
                                .frame(width: 38, height: 38)
                        }
                        
                        Text("\(item.dateNumber)")
                            .font(DharmaTheme.Typography.uiBody(15))
                            .foregroundColor(
                                item.isCompleted
                                    ? .white
                                    : item.isToday
                                        ? DharmaTheme.Colors.onSurface
                                        : DharmaTheme.Colors.secondaryText
                            )
                            .fontWeight(item.isToday || item.isCompleted ? .semibold : .regular)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, DharmaTheme.Spacing.sm)
    }
}

#Preview {
    WeekCalendarView(dates: [
        ("M", 24, false, true),
        ("T", 25, false, true),
        ("W", 26, true, false),
        ("T", 27, false, false),
        ("F", 28, false, false),
        ("S", 29, false, false),
        ("S", 30, false, false)
    ])
    .padding()
}
