import CoreData
import Foundation
import SwiftUI

@MainActor
final class TrackerStore: ObservableObject {
    @Published private(set) var trackers: [Tracker] = []
    @Published private(set) var primaryTrackerID: UUID? = {
        guard let str = UserDefaults.standard.string(forKey: TrackerStore.primaryIDKey),
              let id = UUID(uuidString: str) else { return nil }
        return id
    }()

    private static let primaryIDKey = "BodyLog.PrimaryTrackerID"
    private let context: NSManagedObjectContext

    var primaryTracker: Tracker? {
        if let id = primaryTrackerID, let t = trackers.first(where: { $0.id == id }) {
            return t
        }
        return trackers.last
    }

    func setPrimary(_ tracker: Tracker) {
        primaryTrackerID = tracker.id
        UserDefaults.standard.set(tracker.id.uuidString, forKey: Self.primaryIDKey)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        reload()
        bootstrapDefaultTrackerIfNeeded()
    }

    private func bootstrapDefaultTrackerIfNeeded() {
        let key = "BodyLog.DidBootstrapDefaultTracker"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        defer { UserDefaults.standard.set(true, forKey: key) }
        guard trackers.isEmpty else { return }

        let tracker = Tracker(context: context)
        tracker.id = UUID()
        tracker.name = "默认追踪"
        tracker.goalDescription = nil
        tracker.createdAt = Date()
        save()
        reload()
        setPrimary(tracker)
    }

    func reload() {
        let req = Tracker.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.createdAt, ascending: false)]
        trackers = (try? context.fetch(req)) ?? []
    }

    @discardableResult
    func create(name rawName: String?, goal: String?) -> Tracker {
        let trimmed = rawName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName: String = {
            if let trimmed, !trimmed.isEmpty { return trimmed }
            return nextDefaultName()
        }()

        let tracker = Tracker(context: context)
        tracker.id = UUID()
        tracker.name = finalName
        tracker.goalDescription = (goal?.isEmpty == false) ? goal : nil
        tracker.createdAt = Date()

        save()
        reload()
        return tracker
    }

    func rename(_ tracker: Tracker, to rawName: String) {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != tracker.name else { return }
        tracker.name = trimmed
        save()
        reload()
    }

    func delete(_ tracker: Tracker) {
        let id = tracker.id
        try? ImageStorage.shared.deleteAll(trackerId: id)
        ReminderScheduler.shared.cancel(trackerId: id)
        context.delete(tracker)
        save()
        reload()
    }

    private func save() {
        guard context.hasChanges else { return }
        do { try context.save() } catch {
            assertionFailure("TrackerStore.save 失败: \(error)")
        }
    }

    private func nextDefaultName() -> String {
        let req = Tracker.fetchRequest()
        let existing = (try? context.fetch(req)) ?? []
        let prefix = "未命名追踪 "
        let usedNumbers: Set<Int> = Set(existing.compactMap { tracker in
            guard tracker.name.hasPrefix(prefix) else { return nil }
            return Int(tracker.name.dropFirst(prefix.count))
        })
        var n = 1
        while usedNumbers.contains(n) { n += 1 }
        return "\(prefix)\(n)"
    }
}
