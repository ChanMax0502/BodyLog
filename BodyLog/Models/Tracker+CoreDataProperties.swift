import CoreData
import Foundation

extension Tracker {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tracker> {
        NSFetchRequest<Tracker>(entityName: "Tracker")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var goalDescription: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var entries: NSSet?
}

extension Tracker {
    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Entry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Entry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)
}

extension Tracker: Identifiable {}
