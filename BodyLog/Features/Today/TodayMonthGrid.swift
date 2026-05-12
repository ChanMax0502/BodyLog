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

    struct DayRef: Hashable {
        let tracker: Tracker
        let date: Date
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
                .fill(BrandColor.canvas)
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

        let cellContent = cellBody(latest: latest, hasEntry: hasEntry, isToday: isToday, isFuture: isFuture, entries: entries)

        if isFuture {
            cellContent
        } else {
            NavigationLink(value: TodayMonthGrid.DayRef(tracker: tracker, date: date)) {
                cellContent
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func cellBody(latest: Entry?, hasEntry: Bool, isToday: Bool, isFuture: Bool, entries: [Entry]) -> some View {
        RoundedRectangle(cornerRadius: AppRadius.card)
            .fill(isFuture ? BrandColor.hairlineSoft : BrandColor.surfaceCard)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else if !hasEntry {
                    Text("\(day)")
                        .font(.bud.regular(size: 15))
                        .foregroundColor(isFuture ? BrandColor.mutedSoft : BrandColor.ink)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .strokeBorder(BrandColor.hairline, lineWidth: 0.5)
            }
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .strokeBorder(BrandColor.primary, lineWidth: 2.5)
                }
            }
            .overlay(alignment: .topTrailing) {
                if entries.count > 1 {
                    Text("\(entries.count)")
                        .font(.bud.bold(size: 10))
                        .foregroundColor(BrandColor.onPrimary)
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, 4)
                        .background(BrandColor.primary)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }
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
