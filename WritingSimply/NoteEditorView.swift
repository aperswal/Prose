import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var modelContext

    enum Field: Hashable {
        case title
        case body
    }

    @FocusState private var focus: Field?
    @State private var readability: Readability = ReadabilityScorer.score("")
    @State private var showReadabilityDetail = false
    @State private var bodySelection: TextSelection? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $note.title)
                    .font(.title.bold())
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($focus, equals: .title)
                    .onSubmit { jumpFromTitleToBody() }

                TextField("Start writing", text: $note.body, selection: $bodySelection, axis: .vertical)
                    .font(.title3)
                    .textInputAutocapitalization(.sentences)
                    .focused($focus, equals: .body)
                    .frame(minHeight: 320, alignment: .topLeading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showReadabilityDetail = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Grade")
                        Text("\(Int(readability.grade.rounded()))")
                            .contentTransition(.numericText(value: readability.grade))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Readability grade \(Int(readability.grade.rounded()))")
                .popover(isPresented: $showReadabilityDetail, arrowEdge: .top) {
                    readabilityDetail(readability)
                        .presentationCompactAdaptation(.popover)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if focus != nil {
                    Button("Done") { focus = nil }
                        .font(.body.weight(.semibold))
                } else {
                    Button { focus = .body } label: {
                        Image(systemName: "pencil")
                            .font(.title3)
                    }
                    .accessibilityLabel("Edit")
                }
            }
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

    private func jumpFromTitleToBody() {
        if !note.body.isEmpty {
            note.body = "\n" + note.body
        }
        bodySelection = TextSelection(insertionPoint: note.body.startIndex)
        focus = .body
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
        }
        .padding(18)
        .frame(minWidth: 240)
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
