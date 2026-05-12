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
                .padding(BrandSpacing.md)
                .frame(maxWidth: .infinity)
                .background(BrandColor.canvas)

            Rectangle()
                .fill(BrandColor.hairline)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: BrandSpacing.xxs) {
                Text(tracker.name)
                    .font(BrandFont.titleSM)
                    .foregroundColor(BrandColor.ink)
                    .lineLimit(1)
                Text("本月已打卡 \(entryStore.punchedDaysSetCurrentMonth.count) 天")
                    .font(BrandFont.caption)
                    .foregroundColor(BrandColor.muted)
            }
            .padding(BrandSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(BrandColor.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: BrandRadius.lg))
        .aspectRatio(1, contentMode: .fit)
        .brandShadow(.subtle)
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
                    .fill(BrandColor.success)
                    .frame(width: 8, height: 8)
            } else {
                Text("\(day)")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(isToday ? BrandColor.ink : BrandColor.mutedSoft)
            }
            if isToday {
                Circle()
                    .strokeBorder(BrandColor.primary, lineWidth: 1)
                    .frame(width: 14, height: 14)
            }
        }
        .frame(height: 14)
    }
}
