import SwiftUI
import SwiftData
import UIKit

struct NotesListView: View {
    private static let textKitWarmedUp: Bool = {
        let warm = UITextView()
        warm.text = " "
        _ = warm.attributedText
        return true
    }()

    private static func prewarmTextKit() {
        _ = textKitWarmedUp
    }


    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @State private var path: [Note] = []

    var body: some View {
        NavigationStack(path: $path) {
            sidebar
                .navigationDestination(for: Note.self) { note in
                    NoteEditorView(note: note)
                }
        }
        .tint(Color(red: 0.36, green: 0.45, blue: 0.85))
    }

    private var sidebar: some View {
        Group {
            if notes.isEmpty {
                emptyState
            } else {
                notesList
            }
        }
        .navigationTitle("Prose")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: createNote) {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                }
                .accessibilityLabel("New Piece")
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !notes.isEmpty {
                Text(countLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.bar)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                Self.prewarmTextKit()
            }
        }
    }

    private var notesList: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(value: note) {
                    NoteRow(note: note)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "note.text")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
            Text("No Pieces")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var countLabel: String {
        switch notes.count {
        case 1: return "1 Piece"
        default: return "\(notes.count) Pieces"
        }
    }

    private func createNote() {
        path = [Note()]
    }

    private func delete(_ note: Note) {
        modelContext.delete(note)
    }
}

private struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.displayTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            HStack(spacing: 6) {
                Text(dateLabel)
                    .font(.callout)
                    .foregroundStyle(.primary)
                Text(note.snippet)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }

    private var dateLabel: String {
        let calendar = Calendar.current
        let now = Date()
        let date = note.updatedAt
        let formatter = DateFormatter()
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        if let week = calendar.dateInterval(of: .weekOfYear, for: now),
           week.contains(date) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: date)
    }
}

#Preview {
    NotesListView()
        .modelContainer(for: Note.self, inMemory: true)
}
