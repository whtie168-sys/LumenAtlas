//
//  NoteItem.swift
//  FocusToolkit
//
//  CoreData plain-text quick note with a single tag. No rich text (per spec).
//

import Foundation
import CoreData

enum NoteTag: String, CaseIterable, Identifiable {
    case work, idea, personal
    var id: String { rawValue }

    var label: String {
        switch self {
        case .work: return "Work"
        case .idea: return "Idea"
        case .personal: return "Personal"
        }
    }

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .idea: return "lightbulb.fill"
        case .personal: return "person.fill"
        }
    }

    /// Hex used for the tag chip color.
    var colorHex: String {
        switch self {
        case .work: return "#3B82F6"     // blue
        case .idea: return "#F59E0B"     // amber
        case .personal: return "#22C55E" // green
        }
    }
}

@objc(NoteItem)
final class NoteItem: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var tagRaw: String
    @NSManaged var createdAt: Date

    @discardableResult
    static func create(in context: NSManagedObjectContext, content: String, tag: NoteTag) -> NoteItem {
        let n = NoteItem(context: context)
        n.id = UUID()
        n.content = content
        n.tagRaw = tag.rawValue
        n.createdAt = Date()
        return n
    }

    /// All notes, newest first.
    static func allRequest() -> NSFetchRequest<NoteItem> {
        let request = NSFetchRequest<NoteItem>(entityName: "NoteItem")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    var tag: NoteTag {
        get { NoteTag(rawValue: tagRaw) ?? .work }
        set { tagRaw = newValue.rawValue }
    }

    /// First line, used as a title in lists.
    var titleLine: String {
        content.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
    }
}
