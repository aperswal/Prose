import SwiftUI
import UIKit

enum HighlightCategory: String, CaseIterable, Identifiable, Hashable {
    case longSentence
    case mediumSentence
    case passiveVoice
    case adverb
    case inflatedVocabulary
    case filler

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .longSentence: return "Long sentences"
        case .mediumSentence: return "Medium sentences"
        case .passiveVoice: return "Passive voice"
        case .adverb: return "Adverbs"
        case .inflatedVocabulary: return "Inflated vocabulary"
        case .filler: return "Filler words"
        }
    }

    var color: Color {
        switch self {
        case .longSentence:       return Color(uiColor: .systemRed)
        case .mediumSentence:     return Color(uiColor: .systemYellow)
        case .passiveVoice:       return Color(uiColor: .systemPurple)
        case .adverb:             return Color(uiColor: .systemOrange)
        case .inflatedVocabulary: return Color(uiColor: .systemTeal)
        case .filler:             return Color(uiColor: .systemPink)
        }
    }

    var isSentenceLevel: Bool {
        switch self {
        case .longSentence, .mediumSentence, .passiveVoice: return true
        case .adverb, .inflatedVocabulary, .filler: return false
        }
    }

    var explanation: String {
        switch self {
        case .longSentence:
            return "Sentences over 30 words usually carry more than one idea. Split it where the “and” or “but” lives."
        case .mediumSentence:
            return "This sentence is on the long side. Tighten it, or split it, if a reader has to slow down to follow."
        case .passiveVoice:
            return "Passive sentences hide who did what. Rewrite so the subject does the action."
        case .adverb:
            return "Adverbs prop up weak verbs. Cut it, or pick a stronger verb that does the work alone."
        case .inflatedVocabulary:
            return "A simpler word reads at a lower grade and lands harder."
        case .filler:
            return "Filler words fade out. Cutting them makes the sentence stronger without losing meaning."
        }
    }
}

struct HighlightRange: Identifiable, Hashable {
    let id: UUID
    let category: HighlightCategory
    let range: Range<String.Index>
    let replacement: String?
    let detailLabel: String?

    init(category: HighlightCategory, range: Range<String.Index>, replacement: String? = nil, detailLabel: String? = nil) {
        self.id = UUID()
        self.category = category
        self.range = range
        self.replacement = replacement
        self.detailLabel = detailLabel
    }
}
