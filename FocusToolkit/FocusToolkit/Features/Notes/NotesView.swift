//
//  NotesView.swift
//  FocusToolkit
//
//  Quick notes with tag filter + search. Tap to edit, swipe to delete.
//

import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = NotesViewModel()

    @FetchRequest(fetchRequest: NoteItem.allRequest()) private var notes: FetchedResults<NoteItem>

    @State private var searchText = ""
    @State private var selectedTag: NoteTag? = nil
    @State private var editingNote: NoteItem?
    @State private var showingAdd = false

    private var filtered: [NoteItem] {
        notes.filter { note in
            let matchesTag = selectedTag == nil || note.tag == selectedTag
            let matchesSearch = searchText.isEmpty ||
                note.content.localizedCaseInsensitiveContains(searchText)
            return matchesTag && matchesSearch
        }
    }

    var body: some View {
        CompatNav {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 12) {
                    tagFilter

                    if filtered.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "note.text",
                            title: notes.isEmpty ? "No notes yet" : "No matches",
                            message: notes.isEmpty
                                ? "Capture quick thoughts, ideas, and reminders."
                                : "Try a different tag or search."
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { note in
                                    noteCard(note)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                        Haptics.tap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NoteEditorSheet(note: nil) { content, tag in
                    vm.add(content: content, tag: tag)
                }
                .compatDetentsMedium()
            }
            .sheet(item: $editingNote) { note in
                NoteEditorSheet(note: note) { content, tag in
                    vm.update(note, content: content, tag: tag)
                }
                .compatDetentsMedium()
            }
            .onAppear { vm.configure(context: viewContext) }
        }
    }

    private var tagFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    selectedTag = nil
                    Haptics.tap()
                } label: {
                    TagChip(text: "All", systemImage: "tray.full", color: Theme.textSecondary, filled: selectedTag == nil)
                }
                .buttonStyle(.plain)

                ForEach(NoteTag.allCases) { tag in
                    Button {
                        selectedTag = (selectedTag == tag) ? nil : tag
                        Haptics.tap()
                    } label: {
                        TagChip(
                            text: tag.label,
                            systemImage: tag.icon,
                            color: Color(hex: tag.colorHex),
                            filled: selectedTag == tag
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func noteCard(_ note: NoteItem) -> some View {
        Button {
            editingNote = note
            Haptics.tap()
        } label: {
            Card {
                VStack(alignment: .leading, spacing: 10) {
                    Text(note.content)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        TagChip(text: note.tag.label, systemImage: note.tag.icon, color: Color(hex: note.tag.colorHex))
                        Spacer()
                        Text(DateUtils.relativeLabel(note.createdAt))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                vm.delete(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Note Editor Sheet

private struct NoteEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content: String
    @State private var tag: NoteTag
    @FocusState private var focused: Bool

    let note: NoteItem?
    let onSave: (String, NoteTag) -> Void

    init(note: NoteItem?, onSave: @escaping (String, NoteTag) -> Void) {
        self.note = note
        self.onSave = onSave
        _content = State(initialValue: note?.content ?? "")
        _tag = State(initialValue: note?.tag ?? .work)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(note == nil ? "New note" : "Edit note")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button("Save") { commit() }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }

            // Plain text editor (no rich text).
            TextEditor(text: $content)
                .font(.system(size: 16))
                .foregroundStyle(Theme.textPrimary)
                .compatHideScrollBackground()
                .padding(10)
                .frame(maxHeight: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.card))
                .focused($focused)

            HStack(spacing: 10) {
                ForEach(NoteTag.allCases) { t in
                    Button {
                        tag = t
                        Haptics.tap()
                    } label: {
                        TagChip(
                            text: t.label,
                            systemImage: t.icon,
                            color: Color(hex: t.colorHex),
                            filled: tag == t
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.backgroundElevated.ignoresSafeArea())
        .onAppear { if note == nil { focused = true } }
    }

    private func commit() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { dismiss(); return }
        onSave(trimmed, tag)
        dismiss()
    }
}
