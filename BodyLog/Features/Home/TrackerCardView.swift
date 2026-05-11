import SwiftUI

struct TrackerCardView: View {
    let tracker: Tracker
    @EnvironmentObject private var trackerStore: TrackerStore

    @StateObject private var entryStore: EntryStoreLoader

    init(tracker: Tracker) {
        self.tracker = tracker
        _entryStore = StateObject(wrappedValue: EntryStoreLoader(tracker: tracker))
    }

    var body: some View {
        VStack(spacing: 0) {
            MiniMonthGrid(punchedDays: entryStore.punchedDaysSetCurrentMonth)
                .padding(AppSpacing.m)
                .frame(maxWidth: .infinity)
                .background(Color.bgSecondary)

            Divider().background(Color.appSeparator)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(tracker.name)
                    .font(AppFont.cardTitle)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text("本月已打卡 \(entryStore.punchedDaysSetCurrentMonth.count) 天")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(AppSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .strokeBorder(Color.appSeparator, lineWidth: 0.5)
        )
        .aspectRatio(0.85, contentMode: .fit)
    }
}

/// 卡片专用：把 EntryStore 加载推迟到首次 body，并缓存当月已打卡天数集合。
@MainActor
final class EntryStoreLoader: ObservableObject {
    @Published private(set) var punchedDaysSetCurrentMonth: Set<Int> = []

    init(tracker: Tracker) {
        let ctx = PersistenceController.shared.container.viewContext
        let store = EntryStore(tracker: tracker, context: ctx)
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .month, for: Date()) else { return }
        let days = store.entries
            .filter { interval.contains($0.date) }
            .map { cal.component(.day, from: $0.date) }
        self.punchedDaysSetCurrentMonth = Set(days)
    }
}

private struct MiniMonthGrid: View {
    let punchedDays: Set<Int>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        let cal = Calendar.current
        let today = Date()
        let dayOfToday = cal.component(.day, from: today)
        let range = cal.range(of: .day, in: .month, for: today) ?? 1..<29
        let firstWeekday = firstWeekdayOffset(for: today, calendar: cal)
        let totalCells = firstWeekday + range.count
        let trailing = (7 - totalCells % 7) % 7

        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<firstWeekday, id: \.self) { _ in
                Color.clear.frame(height: 14)
            }
            ForEach(range, id: \.self) { day in
                MiniDayDot(
                    day: day,
                    isToday: day == dayOfToday,
                    isPunched: punchedDays.contains(day)
                )
            }
            ForEach(0..<trailing, id: \.self) { _ in
                Color.clear.frame(height: 14)
            }
        }
    }

    private func firstWeekdayOffset(for date: Date, calendar: Calendar) -> Int {
        var cal = calendar
        cal.firstWeekday = calendar.firstWeekday
        let comp = cal.dateComponents([.year, .month], from: date)
        guard let first = cal.date(from: comp) else { return 0 }
        let weekday = cal.component(.weekday, from: first)
        return (weekday - cal.firstWeekday + 7) % 7
    }
}

private struct MiniDayDot: View {
    let day: Int
    let isToday: Bool
    let isPunched: Bool

    var body: some View {
        ZStack {
            if isPunched {
                Circle()
                    .fill(Color.accentGreen)
                    .frame(width: 8, height: 8)
            } else {
                Text("\(day)")
                    .font(.bud.regular(size: 9))
                    .foregroundStyle(isToday ? Color.textPrimary : Color.textSecondary)
            }
            if isToday {
                Circle()
                    .strokeBorder(Color.accentBlue, lineWidth: 1)
                    .frame(width: 14, height: 14)
            }
        }
        .frame(height: 14)
    }
}
