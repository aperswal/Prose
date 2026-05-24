import Foundation

enum Detectors {

    static func detectLongSentences(_ analyzed: AnalyzedText) -> [HighlightRange] {
        var out: [HighlightRange] = []
        for sentence in analyzed.sentences where sentence.words.count > 30 {
            out.append(HighlightRange(
                category: .longSentence,
                range: sentence.range,
                detailLabel: "\(sentence.words.count) words"
            ))
        }
        return out
    }

    static func detectMediumSentences(_ analyzed: AnalyzedText) -> [HighlightRange] {
        var out: [HighlightRange] = []
        for sentence in analyzed.sentences {
            let count = sentence.words.count
            if count >= 20 && count <= 30 {
                out.append(HighlightRange(
                    category: .mediumSentence,
                    range: sentence.range,
                    detailLabel: "\(count) words"
                ))
            }
        }
        return out
    }

    static func detectAdverbs(_ analyzed: AnalyzedText) -> [HighlightRange] {
        var out: [HighlightRange] = []
        for sentence in analyzed.sentences {
            for word in sentence.words {
                let lower = word.text.lowercased()
                guard lower.hasSuffix("ly"), lower.count >= 4 else { continue }
                guard !WordListData.adverbWhitelist.contains(lower) else { continue }
                guard !word.isProperNoun else { continue }
                out.append(HighlightRange(category: .adverb, range: word.range))
            }
        }
        return out
    }

    static func detectFillers(_ analyzed: AnalyzedText) -> [HighlightRange] {
        return findPhrasesInWords(Set(WordListData.fillers), category: .filler, in: analyzed)
    }

    static func detectInflatedVocabulary(_ analyzed: AnalyzedText) -> [HighlightRange] {
        var out: [HighlightRange] = []
        let map = WordListData.inflatedVocabulary
        let phrasesByLength = bucketPhrases(by: Array(map.keys))
        for sentence in analyzed.sentences {
            var i = 0
            while i < sentence.words.count {
                var matched = false
                for n in phrasesByLength.keys.sorted(by: >) {
                    guard i + n <= sentence.words.count else { continue }
                    let span = sentence.words[i..<(i + n)]
                    let joined = span.map { $0.text.lowercased() }.joined(separator: " ")
                    if let replacement = map[joined] {
                        let start = span.first!.range.lowerBound
                        let end = span.last!.range.upperBound
                        out.append(HighlightRange(
                            category: .inflatedVocabulary,
                            range: start..<end,
                            replacement: replacement,
                            detailLabel: joined
                        ))
                        i += n
                        matched = true
                        break
                    }
                }
                if !matched { i += 1 }
            }
        }
        return out
    }

    static func detectPassive(_ analyzed: AnalyzedText) -> [HighlightRange] {
        var out: [HighlightRange] = []
        for sentence in analyzed.sentences {
            var i = 0
            while i < sentence.words.count {
                let lower = sentence.words[i].text.lowercased()
                if WordListData.passiveAuxiliaries.contains(lower) {
                    var foundAt = -1
                    let maxLook = min(i + 3, sentence.words.count - 1)
                    var j = i + 1
                    while j <= maxLook {
                        let candidate = sentence.words[j].text.lowercased()
                        if isPastParticiple(candidate) {
                            foundAt = j
                            break
                        }
                        j += 1
                    }
                    if foundAt >= 0 {
                        let start = sentence.words[i].range.lowerBound
                        let end = sentence.words[foundAt].range.upperBound
                        out.append(HighlightRange(category: .passiveVoice, range: start..<end))
                        i = foundAt + 1
                        continue
                    }
                }
                i += 1
            }
        }
        return out
    }

    // MARK: - Helpers

    private static let irregularParticiples: Set<String> = [
        "been", "become", "begun", "bent", "born", "broken", "brought", "built",
        "bought", "burnt", "burst", "caught", "chosen", "come", "cost", "cut",
        "done", "drawn", "driven", "eaten", "fallen", "felt", "fought", "found",
        "given", "gone", "gotten", "had", "heard", "held", "hidden", "hit",
        "hurt", "kept", "known", "laid", "led", "left", "lent", "let", "lost",
        "made", "meant", "met", "paid", "put", "read", "run", "said", "seen",
        "sent", "set", "shaken", "shot", "shown", "shut", "slept", "sold",
        "sought", "spent", "spoken", "spread", "stood", "stuck", "sworn",
        "taken", "taught", "thought", "thrown", "told", "understood", "won",
        "written", "lit", "fit", "split", "torn", "worn"
    ]

    private static func isPastParticiple(_ word: String) -> Bool {
        if irregularParticiples.contains(word) { return true }
        if word.hasSuffix("ed") && word.count >= 5 { return true }
        return false
    }

    private static func findPhrasesInWords(
        _ phrases: Set<String>,
        category: HighlightCategory,
        in analyzed: AnalyzedText
    ) -> [HighlightRange] {
        var out: [HighlightRange] = []
        let phrasesByLength = bucketPhrases(by: Array(phrases))
        for sentence in analyzed.sentences {
            var i = 0
            while i < sentence.words.count {
                var matched = false
                for n in phrasesByLength.keys.sorted(by: >) {
                    guard i + n <= sentence.words.count else { continue }
                    let span = sentence.words[i..<(i + n)]
                    let joined = span.map { $0.text.lowercased() }.joined(separator: " ")
                    if phrasesByLength[n]?.contains(joined) == true {
                        let start = span.first!.range.lowerBound
                        let end = span.last!.range.upperBound
                        out.append(HighlightRange(category: category, range: start..<end))
                        i += n
                        matched = true
                        break
                    }
                }
                if !matched { i += 1 }
            }
        }
        return out
    }

    private static func bucketPhrases(by phrases: [String]) -> [Int: Set<String>] {
        var buckets: [Int: Set<String>] = [:]
        for phrase in phrases {
            let n = phrase.split(separator: " ").count
            buckets[n, default: []].insert(phrase)
        }
        return buckets
    }
}
