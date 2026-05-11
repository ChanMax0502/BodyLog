import SwiftUI
import UIKit

struct TodayMonthGrid: View {
    let tracker: Tracker
    let referenceDate: Date
    @StateObject private var entryStore: EntryStore

    init(tracker: Tracker, referenceDate: Date) {
        self.tracker = tracker
        self.referenceDate = referenceDate
        _entryStore = StateObject(
            wrappedValue: EntryStore(
                tracker: tracker,
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    private static let weekdayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs), count: 7)

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }

    var body: some View {
        let cal = calendar
        let monthStart = cal.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
        let range = cal.range(of: .day, in: .month, for: referenceDate) ?? 1..<29
        let weekdayOfFirst = cal.component(.weekday, from: monthStart)
        let leadingBlanks = (weekdayOfFirst - cal.firstWeekday + 7) % 7

        VStack(spacing: AppSpacing.s) {
            LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
                ForEach(Self.weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
                ForEach(range, id: \.self) { day in
                    let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
                    TodayDayCell(day: day, date: date, tracker: tracker, store: entryStore)
                }
            }
        }
        .padding(AppSpacing.m)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
    }
}

private struct TodayDayCell: View {
    let day: Int
    let date: Date
    let tracker: Tracker
    @ObservedObject var store: EntryStore
    @State private var thumbnail: UIImage?

    var body: some View {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isFuture = date > Date() && !isToday
        let entry = store.latestEntry(on: date)
        let hasEntry = entry != nil

        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.bgPrimary)

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else if !hasEntry {
                Text("\(day)")
                    .font(.bud.regular(size: 15))
                    .foregroundStyle(Color.textPrimary)
            }

            if isToday {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .strokeBorder(Color.accentClay, lineWidth: 2.5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        .opacity(isFuture ? 0.4 : 1.0)
        .task(id: entry?.id) {
            await loadThumbnail(entry: entry)
        }
    }

    private func loadThumbnail(entry: Entry?) async {
        guard let entry else {
            thumbnail = nil
            return
        }
        let url = ImageStorage.shared.absoluteURL(forRelativePath: entry.photoLocalPath)
        thumbnail = await ThumbnailCache.shared.thumbnail(
            trackerId: tracker.id,
            entryId: entry.id,
            source: url
        )
    }
}
