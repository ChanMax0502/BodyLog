import SwiftUI

struct MonthSection: View {
    let month: Date
    let tracker: Tracker
    @ObservedObject var store: EntryStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.s), count: 7)

    var body: some View {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: month) ?? 1..<29
        let firstWeekdayOffset = firstWeekdayOffset(for: month, calendar: cal)

        LazyVGrid(columns: columns, spacing: AppSpacing.s) {
            ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                Color.clear.frame(height: 44)
            }
            ForEach(range, id: \.self) { day in
                let date = cal.date(bySetting: .day, value: day, of: month) ?? month
                DayCell(day: day, date: date, store: store)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    private func firstWeekdayOffset(for date: Date, calendar: Calendar) -> Int {
        let comp = calendar.dateComponents([.year, .month], from: date)
        guard let first = calendar.date(from: comp) else { return 0 }
        let weekday = calendar.component(.weekday, from: first)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}

private struct DayCell: View {
    let day: Int
    let date: Date
    @ObservedObject var store: EntryStore

    var body: some View {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isFuture = date > Date() && !isToday
        let entries = store.entries(on: date)
        let hasEntry = !entries.isEmpty

        ZStack {
            if isToday {
                Circle()
                    .strokeBorder(Color.accentBlue, lineWidth: 1.2)
            }
            if hasEntry {
                RoundedRectangle(cornerRadius: AppRadius.thumb)
                    .fill(Color.bgSecondary)
                Image(systemName: "photo")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                if entries.count > 1 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("+\(entries.count - 1)")
                                .font(.bud.semibold(size: 9))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.accentBlue.opacity(0.85))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(2)
                }
            } else {
                Text("\(day)")
                    .font(.bud.regular(size: 14))
                    .foregroundStyle(isFuture ? Color.textSecondary.opacity(0.4) : Color.textSecondary)
            }
        }
        .contentShape(Rectangle())
    }
}
