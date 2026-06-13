//
//  NotesViewModel.swift
//  FocusToolkit
//
//  Quick-note CRUD. Plain text only (no rich text per spec).
//

import Foundation
import CoreData
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    private var context: NSManagedObjectContext?

    func configure(context: NSManagedObjectContext) {
        self.context = context
    }

    func add(content: String, tag: NoteTag) {
        guard let context else { return }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        NoteItem.create(in: context, content: trimmed, tag: tag)
        save()
        Haptics.success()
    }

    func update(_ note: NoteItem, content: String, tag: NoteTag) {
        note.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        note.tag = tag
        save()
        Haptics.tap()
    }

    func delete(_ note: NoteItem) {
        context?.delete(note)
        save()
        Haptics.warning()
    }

    private func save() {
        guard let context, context.hasChanges else { return }
        try? context.save()
    }
}
