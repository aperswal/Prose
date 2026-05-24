import SwiftUI

struct HighlightsSettingsSheet: View {
    @Binding var enabledCategories: Set<HighlightCategory>
    let counts: [HighlightCategory: Int]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(HighlightCategory.allCases) { category in
                        Toggle(isOn: bindingFor(category)) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                Text(category.displayName)
                                Spacer()
                                Text("\(counts[category, default: 0])")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }
                } footer: {
                    Text("Tap to toggle a category. Counts update as you type.")
                }
            }
            .navigationTitle("Highlights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
        }
    }

    private func bindingFor(_ category: HighlightCategory) -> Binding<Bool> {
        Binding(
            get: { enabledCategories.contains(category) },
            set: { isOn in
                if isOn { enabledCategories.insert(category) } else { enabledCategories.remove(category) }
            }
        )
    }
}
