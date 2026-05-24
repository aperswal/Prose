import SwiftUI
import SwiftData
import UIKit

@main
struct WritingSimplyApp: App {
    private let container: ModelContainer

    init() {
        UITextView.appearance().textContainerInset = .zero

        let arguments = ProcessInfo.processInfo.arguments
        let seeding = arguments.contains("-SEED_SCREENSHOTS")
        let inMemory = seeding || arguments.contains("-UI_TEST_RESET")

        do {
            container = try ModelContainer(
                for: Note.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        if seeding {
            ScreenshotSeed.populate(container.mainContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
        .modelContainer(container)
    }
}

/// Demo notes loaded only when the app launches with `-SEED_SCREENSHOTS`, so the
/// App Store screenshots can be captured against a known set of content without
/// touching the real on-device store.
enum ScreenshotSeed {
    private struct Item {
        let title: String
        let body: String
        let minutesAgo: Int
    }

    private static let items: [Item] = [
        Item(
            title: "Note to Dana \u{2014} pricing page",
            body: """
            Hi Dana, I just wanted to quickly flag a few things about the pricing page before the team starts the real build, because there are some open questions from the call that we never actually closed out and I do not want to guess.

            The new copy was reviewed by legal last week. Prior to launch we still need to utilize the brand colors and rewrite the header so the tone matches the warmer voice we agreed on.

            The timeline is tight. I will send the full plan immediately after the design review.
            """,
            minutesAgo: 2
        ),
        Item(
            title: "Toast for Ben",
            body: """
            Ten years ago Ben asked me to read his first short story. It was about a man who built a boat in his backyard and never sailed it.

            I told him then that he was a writer. He did not believe me.

            Tonight he is publishing his first book. So I am telling him again, in front of all of you.

            Ben, you are a writer. To Ben.
            """,
            minutesAgo: 5
        ),
        Item(
            title: "Message to Sam",
            body: """
            Hey. I have been thinking about you all morning. I am sorry I did not text yesterday. I did not know what to say and waiting made it worse.

            If you want to talk this weekend, I can be free Saturday or Sunday. If you do not want to talk, that is fine too. I just wanted you to know I am here.
            """,
            minutesAgo: 8
        ),
        Item(
            title: "Your thoughts stay yours.",
            body: """
            Prose keeps every note on this phone. Nothing leaves the device. No account. No cloud. No sync server. No analytics that learn what you write about. The drafts you write here are the drafts only you have seen.
            """,
            minutesAgo: 11
        ),
        Item(
            title: "Nothing competes for your attention.",
            body: """
            No formatting toolbar. No checkboxes, no tables, no colors, no fonts. Just a title and a body. Everything that could pull your eye away from the words has been left out on purpose. The page looks the way your draft will read.
            """,
            minutesAgo: 14
        ),
        Item(
            title: "Never lose a word.",
            body: """
            Every keystroke saves. You will not find a save button anywhere in Prose. Close the app mid-thought. Come back an hour later, a day later. Your draft is where you left it. The last character you typed is the first one you see.
            """,
            minutesAgo: 17
        ),
        Item(
            title: "Down to the syllable.",
            body: """
            Tap the Grade chip. Prose opens a small breakdown. Grade level, words, sentences, syllables. When the number moves, you can see what moved it. A long sentence. A hard word. The detail is there when you want it. Out of the way when you do not.
            """,
            minutesAgo: 20
        ),
        Item(
            title: "Write for your reader.",
            body: """
            The Grade chip in the corner shows how easy your writing is to read. It updates every time you change a word. If a sentence pushes the number up, you see it before you send. You write for the reader as you go, not after the email is already gone.
            """,
            minutesAgo: 25
        ),
        Item(
            title: "Email after the kickoff",
            body: """
            Hi Mara,

            Thanks for the time today. Here is what I heard us agree to.

            You want the new pages live by April 1. You want the voice to feel warmer than the current site without losing the trust we have already built. The first draft of the homepage will reach you by next Friday.

            If I have any of this wrong, please tell me before I start writing.
            """,
            minutesAgo: 40
        ),
    ]

    static func populate(_ context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Note>())) ?? []
        guard existing.isEmpty else { return }

        let now = Date()
        for item in items {
            context.insert(Note(
                title: item.title,
                body: item.body,
                updatedAt: now.addingTimeInterval(TimeInterval(-item.minutesAgo * 60))
            ))
        }
        try? context.save()
    }
}
