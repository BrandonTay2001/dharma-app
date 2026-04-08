import SwiftUI

struct SacredObservanceCalendarView: View {
    let observances: [SacredObservance]
    let onDone: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
                        header
                        upcomingList
                    }
                    .padding(DharmaTheme.Spacing.lg)
                    .padding(.bottom, 100)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button("Acknowledge") {
                        onDone()
                        dismiss()
                    }
                    .buttonStyle(.saffron)
                    Spacer()
                }
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                    }
                }
            }
            .navigationDestination(for: SacredObservance.self) { observance in
                SacredObservanceDetailView(observance: observance, onAcknowledge: onDone)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                Text("Sacred Dates Ahead")
                    .font(DharmaTheme.Typography.uiTitle(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text("Next 7 days of Hindu and Buddhist observances, with one small ritual for each day.")
                    .font(DharmaTheme.Typography.uiCaption(13))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 38, height: 38)

                Text("🪔")
                    .font(.system(size: 18))
            }
        }
    }

    private var upcomingList: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
            Text("Seven-Day Rhythm")
                .font(DharmaTheme.Typography.uiHeadline(18))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            VStack(spacing: DharmaTheme.Spacing.sm) {
                ForEach(observances) { observance in
                    NavigationLink(value: observance) {
                        HStack(spacing: DharmaTheme.Spacing.md) {
                            VStack(spacing: 2) {
                                Text(observance.shortWeekdayLabel)
                                    .font(DharmaTheme.Typography.uiLabel(10))
                                    .foregroundColor(DharmaTheme.Colors.onSurface)

                                Text(observance.dayNumber)
                                    .font(DharmaTheme.Typography.uiHeadline(18))
                                    .foregroundColor(DharmaTheme.Colors.saffron)
                            }
                            .frame(width: 42)

                            Text(observance.tradition.icon)
                                .font(.system(size: 14))

                            Text(observance.title)
                                .font(DharmaTheme.Typography.uiHeadline(15))
                                .foregroundColor(DharmaTheme.Colors.onSurface)
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                        }
                        .padding(.horizontal, DharmaTheme.Spacing.md)
                        .padding(.vertical, DharmaTheme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DharmaTheme.Colors.surfaceContainerLowest)
                        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

}

struct SacredObservanceDetailView: View {
    let observance: SacredObservance
    let onAcknowledge: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                        HStack {
                            Text(observance.tradition.label)
                                .font(DharmaTheme.Typography.uiLabel(11))
                                .foregroundColor(DharmaTheme.Colors.saffronDark)
                                .padding(.horizontal, DharmaTheme.Spacing.md)
                                .padding(.vertical, 6)
                                .background(DharmaTheme.Colors.cardHindu)
                                .clipShape(Capsule())

                            Spacer()

                            Text(observance.monthDayLabel.uppercased())
                                .font(DharmaTheme.Typography.uiLabel(11))
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                        }

                        Text(observance.title)
                            .font(DharmaTheme.Typography.scriptureHeadline(28))
                            .foregroundColor(DharmaTheme.Colors.onSurface)

                        Text(observance.summary)
                            .font(DharmaTheme.Typography.uiBody(16))
                            .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    sectionCard(
                        title: "What To Do",
                        content: observance.suggestedPractice,
                        backgroundColor: observance.isMajorObservance ? DharmaTheme.Colors.cardHindu : DharmaTheme.Colors.surfaceContainerLowest
                    )

                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                        Text("Simple Ritual")
                            .font(DharmaTheme.Typography.uiHeadline(18))
                            .foregroundColor(DharmaTheme.Colors.onSurface)

                        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                            ForEach(Array(observance.ritualSteps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
                                    Text("\(index + 1)")
                                        .font(DharmaTheme.Typography.uiLabel(12))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 22)
                                        .background(DharmaTheme.Colors.saffron)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(DharmaTheme.Typography.uiBody(15))
                                        .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(DharmaTheme.Spacing.lg)
                        .background(DharmaTheme.Colors.surfaceContainerLowest)
                        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
                    }

                    sectionCard(
                        title: "Why It Matters",
                        content: observance.whyItMatters,
                        backgroundColor: DharmaTheme.Colors.cardBuddhist.opacity(0.55)
                    )
                }
                .padding(DharmaTheme.Spacing.lg)
            }
        }
    }

    private func sectionCard(title: String, content: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
            Text(title)
                .font(DharmaTheme.Typography.uiHeadline(18))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text(content)
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DharmaTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
    }
}

#Preview {
    SacredObservanceCalendarView(observances: SacredObservancePlanner.nextSevenDays(), onDone: {})
        .padding()
}
