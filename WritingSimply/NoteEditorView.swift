import SwiftUI
import SwiftData
import UIKit

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var modelContext

    enum Field: Hashable {
        case title
    }

    @FocusState private var focus: Field?
    @State private var readability: Readability = ReadabilityScorer.score("")
    @State private var showReadabilityDetail = false

    @State private var highlightsOn = false
    @State private var enabledCategories: Set<HighlightCategory> = HighlightEngine.defaultEnabledCategories
    @State private var highlights: [HighlightRange] = []
    @State private var showHighlightSettings = false
    @State private var isBodyEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $note.title)
                    .font(.title.bold())
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($focus, equals: .title)
                    .onSubmit {
                        focus = nil
                        isBodyEditing = true
                    }

                bodyArea
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showHighlightSettings) {
            HighlightsSettingsSheet(
                enabledCategories: $enabledCategories,
                counts: HighlightEngine.counts(for: highlights)
            )
            .presentationDetents([.medium, .large])
        }
        .onChange(of: note.title) { _, _ in
            insertIfNeeded()
            touch()
        }
        .onChange(of: note.body) { _, newValue in
            insertIfNeeded()
            touch()
            let next = ReadabilityScorer.score(newValue)
            let oldGrade = Int(readability.grade.rounded())
            let newGrade = Int(next.grade.rounded())
            if oldGrade == newGrade {
                readability = next
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    readability = next
                }
            }
            if highlightsOn {
                recomputeHighlights()
            }
        }
        .onChange(of: enabledCategories) { _, _ in
            if highlightsOn { recomputeHighlights() }
        }
        .onAppear {
            if note.isEmpty {
                focus = .title
            }
            readability = ReadabilityScorer.score(note.body)
        }
        .onDisappear {
            guard note.modelContext != nil else { return }
            if note.isEmpty {
                modelContext.delete(note)
            }
            try? modelContext.save()
        }
    }

    @ViewBuilder
    private var bodyArea: some View {
        ZStack(alignment: .topLeading) {
            if note.body.isEmpty {
                Text("Start writing")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
            }
            HighlightingTextEditor(
                text: $note.body,
                isEditing: $isBodyEditing,
                highlights: highlights,
                highlightsEnabled: highlightsOn
            )
            .frame(minHeight: 320, alignment: .topLeading)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showReadabilityDetail = true
            } label: {
                Text(GradeLabel.display(for: readability.grade))
                    .contentTransition(.numericText(value: readability.grade))
                    .font(.subheadline)
                    .foregroundStyle(.tint)
            }
            .accessibilityLabel("Readability: \(GradeLabel.display(for: readability.grade))")
            .popover(isPresented: $showReadabilityDetail, arrowEdge: .top) {
                readabilityDetail(readability)
                    .presentationCompactAdaptation(.popover)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: toggleHighlights) {
                Image(systemName: highlightsOn ? "eye" : "eye.slash")
                    .font(.title3)
                    .foregroundStyle(highlightsOn ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(highlightsOn ? "Hide highlights" : "Show highlights")
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.45)
                    .onEnded { _ in
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        showHighlightSettings = true
                    }
            )
        }

        ToolbarItem(placement: .topBarTrailing) {
            if focus != nil || isBodyEditing {
                Button("Done") {
                    focus = nil
                    dismissKeyboard()
                }
                .font(.body.weight(.semibold))
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

    private func toggleHighlights() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        if !highlightsOn {
            recomputeHighlights()
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            highlightsOn.toggle()
        }
        if !highlightsOn {
            highlights = []
        }
    }

    private func recomputeHighlights() {
        highlights = HighlightEngine.analyze(note.body, enabled: enabledCategories)
    }

    private func insertIfNeeded() {
        if note.modelContext == nil {
            modelContext.insert(note)
        }
    }

    private func readabilityDetail(_ r: Readability) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Readability")
                .font(.title3.weight(.semibold))
            Divider()
            detailRow("Grade level", String(format: "%.1f", r.grade))
            detailRow("Words", "\(r.words)")
            detailRow("Reading time", readingTime(words: r.words))
            if highlightsOn && !highlights.isEmpty {
                Divider()
                ForEach(HighlightCategory.allCases) { category in
                    if let count = HighlightEngine.counts(for: highlights)[category], count > 0 {
                        HStack(spacing: 8) {
                            Circle().fill(category.color).frame(width: 8, height: 8)
                            Text(category.displayName)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(count)")
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .padding(18)
        .frame(minWidth: 260)
    }

    private func readingTime(words: Int) -> String {
        let total = Int((Double(words) / 200.0 * 60.0).rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return "\(h)h \(m)m \(s)s" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .font(.body)
    }

    private func touch() {
        note.updatedAt = .now
    }
}
