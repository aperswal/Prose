# The body editor binds to an AttributedString so styled runs can render in place of the current plain TextEditor.

## Context

The current editor uses SwiftUI's TextEditor bound to a plain String. To draw underlines for flagged words and phrases we need the editor to store an AttributedString instead, because that is the only way in SwiftUI to decorate ranges of text without leaving the native text view. iOS 18 introduced a TextEditor initializer that binds directly to AttributedString, and iOS 26 expands what styling is possible through an AttributedTextFormattingDefinition. We are targeting the iOS 18 surface for now and can grow into the iOS 26 hooks later.

This change is mostly mechanical, but it has knock-on effects. The Note model stores the body as a plain String today and we keep that on disk because the styling is derived from the text by the checkers, not authored by the writer. The editor reads and writes an AttributedString in memory while we serialize only the characters back to the model.

## Dependencies

`00-review-mode-toggle.md`, because the styling work only matters once we have a mode to gate it.

## Execution list

1. Write a failing unit test against a small helper that converts a plain String to an AttributedString with no attributes, and back to a String, asserting the round trip is lossless.
2. Implement the helper as two free functions or an extension on AttributedString.
3. Write a failing test that asserts a NoteEditorViewModel exposes an attributed binding whose characters equal the underlying Note's body.
4. Add the view model layer with an `@Observable` wrapper, exposing both a binding for the editor and a read of the plain text for persistence.
5. Write a failing UI test that types into the new attributed editor and asserts the Note's body string updates as before, so existing list-view snippets continue to work.
6. Swap the existing TextEditor for the AttributedString-bound TextEditor and wire the two-way conversion through the view model.
7. Write a failing test that applies a styled run to a range of the AttributedString and asserts the characters in that range are unchanged after the styling is applied.
8. Add a small "applyUnderline" helper that takes a range and a color and writes the appropriate underline style attribute. Verify the test passes.
9. Refactor by moving the helpers into their own file so NoteEditorView does not grow.

## Acceptance criteria

- Typing in the body editor behaves exactly as it did before the change, including the placeholder behavior when the body is empty.
- The Note model continues to persist the body as a plain String, with no AttributedString-specific serialization on disk.
- A helper exists that can apply an underline style to a given range of the editor's AttributedString without changing any characters.
- A helper exists that can clear all style attributes from the AttributedString in a single call.
- All existing readability behavior continues to work because the underlying characters are unchanged.
