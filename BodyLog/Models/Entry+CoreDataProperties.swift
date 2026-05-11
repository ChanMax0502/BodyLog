import CoreData
import Foundation

extension Entry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var id: UUID
    @NSManaged public var trackerId: UUID
    @NSManaged public var date: Date
    @NSManaged public var photoLocalPath: String
    @NSManaged public var note: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var tracker: Tracker?
}

extension Entry: Identifiable {}
