import SwiftUI
import SwiftData
import UIKit

@main
struct WritingSimplyApp: App {
    init() {
        UITextView.appearance().textContainerInset = .zero
    }

    private var inMemoryStore: Bool {
        ProcessInfo.processInfo.arguments.contains("-UI_TEST_RESET")
    }

    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
        .modelContainer(for: Note.self, inMemory: inMemoryStore)
    }
}
