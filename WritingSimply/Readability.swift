import Foundation

struct Readability: Equatable {
    let words: Int
    let sentences: Int
    let syllables: Int
    let grade: Double
}

enum ReadabilityScorer {
    static func score(_ text: String) -> Readability {
        let words = splitWords(text)
        let sentences = max(1, countSentences(text))
        let syllables = words.reduce(0) { $0 + syllableCount(in: $1) }

        let grade: Double
        if words.isEmpty {
            grade = 0
        } else {
            let wordsPerSentence = Double(words.count) / Double(sentences)
            let syllablesPerWord = Double(syllables) / Double(words.count)
            grade = 0.39 * wordsPerSentence + 11.8 * syllablesPerWord - 15.59
        }

        return Readability(
            words: words.count,
            sentences: sentences,
            syllables: syllables,
            grade: max(0, grade)
        )
    }
}

private func splitWords(_ text: String) -> [Substring] {
    text.split { ch in
        ch.isWhitespace || (ch.isPunctuation && ch != "'")
    }
}

private func countSentences(_ text: String) -> Int {
    var count = 0
    var inTerminator = false
    for ch in text {
        if ch == "." || ch == "!" || ch == "?" {
            if !inTerminator { count += 1 }
            inTerminator = true
        } else if !ch.isWhitespace {
            inTerminator = false
        }
    }
    return count
}

private func syllableCount(in word: Substring) -> Int {
    let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
    let lower = word.lowercased()
    guard !lower.isEmpty else { return 0 }

    var count = 0
    var prevWasVowel = false
    for ch in lower {
        let isVowel = vowels.contains(ch)
        if isVowel && !prevWasVowel { count += 1 }
        prevWasVowel = isVowel
    }
    if lower.hasSuffix("e") && count > 1 { count -= 1 }
    return max(1, count)
}
