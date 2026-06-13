//
//  PersistenceController.swift
//  FocusToolkit
//
//  CoreData stack with a fully programmatic model (no .xcdatamodeld needed).
//  Chosen over SwiftData so the app supports iOS 15+.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        let model = PersistenceController.makeModel()
        container = NSPersistentContainer(name: "FocusToolkit", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                // A failed local store is unrecoverable; surface loudly in debug.
                assertionFailure("Unresolved CoreData error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Programmatic model

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // FocusSession
        let session = NSEntityDescription()
        session.name = "FocusSession"
        session.managedObjectClassName = NSStringFromClass(FocusSession.self)
        session.properties = [
            attribute("id", .UUIDAttributeType, optional: false),
            attribute("duration", .integer64AttributeType, optional: false, defaultValue: 0),
            attribute("startDate", .dateAttributeType, optional: false),
            attribute("endDate", .dateAttributeType, optional: true),
            attribute("isCompleted", .booleanAttributeType, optional: false, defaultValue: false)
        ]

        // TaskItem
        let task = NSEntityDescription()
        task.name = "TaskItem"
        task.managedObjectClassName = NSStringFromClass(TaskItem.self)
        task.properties = [
            attribute("id", .UUIDAttributeType, optional: false),
            attribute("title", .stringAttributeType, optional: false, defaultValue: ""),
            attribute("isCompleted", .booleanAttributeType, optional: false, defaultValue: false),
            attribute("createdAt", .dateAttributeType, optional: false),
            attribute("repeatRaw", .stringAttributeType, optional: false, defaultValue: "none"),
            attribute("lastResetDate", .dateAttributeType, optional: false)
        ]

        // NoteItem
        let note = NSEntityDescription()
        note.name = "NoteItem"
        note.managedObjectClassName = NSStringFromClass(NoteItem.self)
        note.properties = [
            attribute("id", .UUIDAttributeType, optional: false),
            attribute("content", .stringAttributeType, optional: false, defaultValue: ""),
            attribute("tagRaw", .stringAttributeType, optional: false, defaultValue: "work"),
            attribute("createdAt", .dateAttributeType, optional: false)
        ]

        model.entities = [session, task, note]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = optional
        if let defaultValue { attr.defaultValue = defaultValue }
        return attr
    }
}
