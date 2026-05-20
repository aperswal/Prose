# Tapping the Grade chip switches the editor between writing mode and review mode.

## Context

Right now the Grade chip in the editor toolbar opens a small popover with the readability numbers. We talked about replacing that behavior with a mode switch so the editor can stay calm by default and become annotated only when the writer asks for it. In writing mode the editor shows no marks and no analysis chrome, which keeps the surface clean while the writer is working. In review mode the editor gains inline underlines for every deterministic flag and a side panel becomes available with the full list of findings. A second tap on the chip returns the editor to writing mode and removes the marks.

This is the entry point for every other feature in this folder, since none of the per-check features have anywhere to show themselves until this toggle exists. The existing readability popover goes away as part of this change, because its content moves into the inspector's Overview card in feature 04.

## Dependencies

None. Every other feature in this folder depends on this one.

## Execution list

1. Write a failing test against NoteEditorView that boots the view, types enough body text to make the Grade chip appear, and asserts that no inline underlines or inspector chrome are visible. This test should fail because the code currently shows the readability popover on chip tap.
2. Add an `@State private var isInReviewMode = false` property to NoteEditorView and wire the Grade chip button to flip it instead of presenting the popover.
3. Remove the popover modifier and the `showReadabilityDetail` state from the chip button, since the popover is being replaced by the inspector in feature 04.
4. Write a failing UI test that creates a note with sixteen words, taps the Grade chip, and asserts the chip is visually marked as active. The chip should look different when review mode is on so the writer can see the state at a glance.
5. Apply a small visual change to the chip when `isInReviewMode` is true, such as switching from `.foregroundStyle(.secondary)` to `.foregroundStyle(.tint)` and bolding the number.
6. Write a failing test that taps the chip a second time and asserts the active styling is gone.
7. Confirm the test passes without further code, because the toggle already handles both directions.
8. Refactor by extracting the chip view into a small private subview so the toolbar declaration stays readable.

## Acceptance criteria

- The editor renders no inline underlines and no inspector while review mode is off.
- A tap on the visible Grade chip flips review mode on, and a second tap flips it off.
- The chip has a clearly different visual state when review mode is on, and that change is visible without VoiceOver.
- The existing readability popover no longer opens from the chip tap, because the inspector replaces it in feature 04.
- Review mode is only reachable while the Grade chip is visible, which today means the body has at least fifteen words.
