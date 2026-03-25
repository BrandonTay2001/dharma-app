import SwiftUI

struct WeekCalendarView: View {
    let dates: [(dayLabel: String, dateNumber: Int, isToday: Bool)]
    
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
                        if item.isToday {
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
                                item.isToday
                                    ? DharmaTheme.Colors.onSurface
                                    : DharmaTheme.Colors.secondaryText
                            )
                            .fontWeight(item.isToday ? .semibold : .regular)
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
        ("M", 24, true),
        ("T", 25, false),
        ("W", 26, false),
        ("T", 27, false),
        ("F", 28, false),
        ("S", 29, false),
        ("S", 30, false)
    ])
    .padding()
}
