import CoreData
import Foundation
import UIKit

@MainActor
final class EntryStore: ObservableObject {
    @Published private(set) var entries: [Entry] = []

    let tracker: Tracker
    private let context: NSManagedObjectContext
    private var saveObserver: NSObjectProtocol?

    init(tracker: Tracker, context: NSManagedObjectContext) {
        self.tracker = tracker
        self.context = context
        reload()
        saveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.reload()
        }
    }

    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
        }
    }

    func reload() {
        let req = Entry.fetchRequest()
        req.predicate = NSPredicate(format: "trackerId == %@", tracker.id as CVarArg)
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Entry.date, ascending: false),
            NSSortDescriptor(keyPath: \Entry.createdAt, ascending: true),
        ]
        entries = (try? context.fetch(req)) ?? []
    }

    /// 当天所有 Entry，按 createdAt 正序（早 → 晚）
    func entries(on day: Date) -> [Entry] {
        let cal = Calendar.current
        return entries
            .filter { cal.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// 当天最新一条（日历缩略图用）
    func latestEntry(on day: Date) -> Entry? {
        entries(on: day).last
    }

    /// 本月已打卡天数（去重 by day）
    func punchedDaysInMonth(_ reference: Date = Date()) -> Int {
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .month, for: reference) else { return 0 }
        let daysSet = Set(
            entries
                .filter { interval.contains($0.date) }
                .map { cal.startOfDay(for: $0.date) }
        )
        return daysSet.count
    }

    @discardableResult
    func add(image: UIImage, on day: Date = Date(), note: String?) throws -> Entry {
        let id = UUID()
        let relPath = try ImageStorage.shared.save(image, trackerId: tracker.id, entryId: id)

        let entry = Entry(context: context)
        entry.id = id
        entry.trackerId = tracker.id
        entry.tracker = tracker
        entry.date = Calendar.current.startOfDay(for: day)
        entry.photoLocalPath = relPath
        entry.note = (note?.isEmpty == false) ? note : nil
        entry.createdAt = Date()

        try context.save()
        reload()
        return entry
    }

    func addBatch(images: [UIImage], on day: Date = Date()) throws {
        guard !images.isEmpty else { return }
        let normalizedDay = Calendar.current.startOfDay(for: day)
        for image in images {
            let id = UUID()
            let relPath = try ImageStorage.shared.save(image, trackerId: tracker.id, entryId: id)
            let entry = Entry(context: context)
            entry.id = id
            entry.trackerId = tracker.id
            entry.tracker = tracker
            entry.date = normalizedDay
            entry.photoLocalPath = relPath
            entry.note = nil
            entry.createdAt = Date()
        }
        try context.save()
        reload()
    }

    func delete(_ entry: Entry) {
        try? ImageStorage.shared.delete(relativePath: entry.photoLocalPath)
        Task { await ThumbnailCache.shared.invalidate(trackerId: entry.trackerId, entryId: entry.id) }
        context.delete(entry)
        try? context.save()
        reload()
    }

    func updateNote(_ entry: Entry, note: String?) {
        entry.note = (note?.isEmpty == false) ? note : nil
        try? context.save()
        reload()
    }
}
