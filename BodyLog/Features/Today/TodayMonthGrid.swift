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
    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs + 3), count: 7)
    private let cellAspectRatio: CGFloat = 109.0 / 133.0

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }

    private struct GridSlot: Hashable {
        let index: Int
        let day: Int?
    }

    var body: some View {
        let cal = calendar
        let monthStart = cal.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
        let range = cal.range(of: .day, in: .month, for: referenceDate) ?? 1..<29
        let weekdayOfFirst = cal.component(.weekday, from: monthStart)
        let leadingBlanks = (weekdayOfFirst - cal.firstWeekday + 7) % 7
        let totalSlots = leadingBlanks + range.count
        let slots: [GridSlot] = (0..<totalSlots).map { i in
            let day = i < leadingBlanks ? nil : (i - leadingBlanks + range.lowerBound)
            return GridSlot(index: i, day: day)
        }

        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Self.weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 13)

            LazyVGrid(columns: columns, spacing: AppSpacing.xs + 5) {
                ForEach(slots, id: \.index) { slot in
                    if let day = slot.day {
                        let date = cal.date(byAdding: .day, value: day - range.lowerBound, to: monthStart) ?? monthStart
                        TodayDayCell(day: day, date: date, tracker: tracker, store: entryStore, aspectRatio: cellAspectRatio)
                    } else {
                        Color.clear.aspectRatio(cellAspectRatio, contentMode: .fit)
                    }
                }
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
        }
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(Color.white.opacity(0.55))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

private struct TodayDayCell: View {
    let day: Int
    let date: Date
    let tracker: Tracker
    @ObservedObject var store: EntryStore
    let aspectRatio: CGFloat
    @State private var thumbnail: UIImage?

    var body: some View {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isFuture = date > Date() && !isToday
        let entries = store.entries(on: date)
        let latest = entries.last
        let hasEntry = !entries.isEmpty

        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.card - 2)
                .fill(Color.bgSecondary)

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
                RoundedRectangle(cornerRadius: AppRadius.card - 2)
                    .strokeBorder(Color.accentClay, lineWidth: 2.5)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card - 2))
        .overlay(alignment: .topTrailing) {
            if entries.count > 1 {
                Text("\(entries.count)")
                    .font(.bud.semibold(size: 10))
                    .foregroundStyle(.white)
                    .frame(minWidth: 18, minHeight: 18)
                    .padding(.horizontal, 4)
                    .background(Color.accentClay)
                    .clipShape(Capsule())
                    .offset(x: 4, y: -4)
            }
        }
        .opacity(isFuture ? 0.4 : 1.0)
        .task(id: latest?.id) {
            await loadThumbnail(entry: latest)
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
