import Foundation

enum HighlightEngine {

    static let defaultEnabledCategories: Set<HighlightCategory> = Set(HighlightCategory.allCases)

    static func analyze(
        _ text: String,
        enabled: Set<HighlightCategory> = defaultEnabledCategories
    ) -> [HighlightRange] {
        guard !text.isEmpty, !enabled.isEmpty else { return [] }
        let analyzed = TextNormalizer.analyze(text)
        var ranges: [HighlightRange] = []

        if enabled.contains(.longSentence) {
            ranges.append(contentsOf: Detectors.detectLongSentences(analyzed))
        }
        if enabled.contains(.mediumSentence) {
            ranges.append(contentsOf: Detectors.detectMediumSentences(analyzed))
        }
        if enabled.contains(.passiveVoice) {
            ranges.append(contentsOf: Detectors.detectPassive(analyzed))
        }
        if enabled.contains(.adverb) {
            ranges.append(contentsOf: Detectors.detectAdverbs(analyzed))
        }
        if enabled.contains(.inflatedVocabulary) {
            ranges.append(contentsOf: Detectors.detectInflatedVocabulary(analyzed))
        }
        if enabled.contains(.filler) {
            ranges.append(contentsOf: Detectors.detectFillers(analyzed))
        }

        return ranges.sorted { lhs, rhs in
            if lhs.range.lowerBound != rhs.range.lowerBound {
                return lhs.range.lowerBound < rhs.range.lowerBound
            }
            return lhs.category.isSentenceLevel && !rhs.category.isSentenceLevel
        }
    }

    static func counts(for ranges: [HighlightRange]) -> [HighlightCategory: Int] {
        var dict: [HighlightCategory: Int] = [:]
        for range in ranges {
            dict[range.category, default: 0] += 1
        }
        return dict
    }
}
