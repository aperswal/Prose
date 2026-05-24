import Foundation
import NaturalLanguage

struct AnalyzedSentence {
    enum Kind { case prose, listItem, heading }

    let range: Range<String.Index>
    let words: [AnalyzedWord]
    let kind: Kind
}

struct AnalyzedWord {
    let range: Range<String.Index>
    let text: String
    let isProperNoun: Bool
}

struct AnalyzedText {
    let source: String
    let sentences: [AnalyzedSentence]
}

enum TextNormalizer {

    static func analyze(_ text: String) -> AnalyzedText {
        guard !text.isEmpty else { return AnalyzedText(source: text, sentences: []) }
        var sentences: [AnalyzedSentence] = []

        let lineRanges = splitByLine(text)
        for lineRange in lineRanges {
            let line = String(text[lineRange])
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }

            let (contentRange, kind) = classifyLine(line, lineRange: lineRange, source: text)

            for sentenceRange in splitIntoSentences(text, in: contentRange) {
                let words = tokenizeWords(in: sentenceRange, source: text)
                guard !words.isEmpty else { continue }
                sentences.append(AnalyzedSentence(range: sentenceRange, words: words, kind: kind))
            }
        }

        return AnalyzedText(source: text, sentences: sentences)
    }

    private static func splitByLine(_ text: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var lineStart = text.startIndex
        var i = text.startIndex
        while i < text.endIndex {
            if text[i].isNewline {
                ranges.append(lineStart..<i)
                let next = text.index(after: i)
                lineStart = next
                i = next
            } else {
                i = text.index(after: i)
            }
        }
        if lineStart < text.endIndex {
            ranges.append(lineStart..<text.endIndex)
        }
        return ranges
    }

    private static func classifyLine(
        _ line: String,
        lineRange: Range<String.Index>,
        source: String
    ) -> (Range<String.Index>, AnalyzedSentence.Kind) {
        let leading = line.prefix(while: { $0 == " " || $0 == "\t" })
        let afterLeading = line.index(line.startIndex, offsetBy: leading.count)
        let body = line[afterLeading...]
        let leadingCount = leading.count

        for marker in WordListData.bulletMarkers {
            if body.hasPrefix(marker) {
                let markerCount = marker.count
                let contentStartOffset = leadingCount + markerCount
                let contentStart = source.index(lineRange.lowerBound, offsetBy: contentStartOffset)
                return (contentStart..<lineRange.upperBound, .listItem)
            }
        }

        if matchesNumberedListPrefix(body) {
            let consumed = numberedListPrefixLength(body)
            let contentStartOffset = leadingCount + consumed
            let contentStart = source.index(lineRange.lowerBound, offsetBy: contentStartOffset)
            return (contentStart..<lineRange.upperBound, .listItem)
        }

        if body.first == "#" {
            var idx = body.startIndex
            while idx < body.endIndex && body[idx] == "#" { idx = body.index(after: idx) }
            if idx < body.endIndex && body[idx] == " " {
                let consumed = body.distance(from: body.startIndex, to: body.index(after: idx))
                let contentStartOffset = leadingCount + consumed
                let contentStart = source.index(lineRange.lowerBound, offsetBy: contentStartOffset)
                return (contentStart..<lineRange.upperBound, .heading)
            }
        }

        let contentStart = source.index(lineRange.lowerBound, offsetBy: leadingCount)
        return (contentStart..<lineRange.upperBound, .prose)
    }

    private static func matchesNumberedListPrefix(_ body: Substring) -> Bool {
        var idx = body.startIndex
        var sawDigit = false
        while idx < body.endIndex, body[idx].isASCII, body[idx].isNumber {
            sawDigit = true
            idx = body.index(after: idx)
        }
        guard sawDigit, idx < body.endIndex else { return false }
        if body[idx] == "." || body[idx] == ")" {
            let next = body.index(after: idx)
            return next < body.endIndex && body[next] == " "
        }
        return false
    }

    private static func numberedListPrefixLength(_ body: Substring) -> Int {
        var idx = body.startIndex
        var count = 0
        while idx < body.endIndex, body[idx].isASCII, body[idx].isNumber {
            count += 1
            idx = body.index(after: idx)
        }
        if idx < body.endIndex, body[idx] == "." || body[idx] == ")" {
            count += 1
            idx = body.index(after: idx)
            if idx < body.endIndex, body[idx] == " " {
                count += 1
            }
        }
        return count
    }

    private static func splitIntoSentences(_ source: String, in range: Range<String.Index>) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var sentenceStart = skipLeadingWhitespace(source, from: range.lowerBound, upTo: range.upperBound)
        guard sentenceStart < range.upperBound else { return [] }

        var i = sentenceStart
        while i < range.upperBound {
            let ch = source[i]
            if isSentenceTerminator(ch) {
                let afterTerm = source.index(after: i)
                if isLikelyAbbreviation(source, terminatorAt: i, sentenceStart: sentenceStart) {
                    i = afterTerm
                    continue
                }
                if afterTerm >= range.upperBound {
                    ranges.append(sentenceStart..<afterTerm)
                    sentenceStart = afterTerm
                    i = afterTerm
                    continue
                }
                let nextNonSpace = skipLeadingWhitespace(source, from: afterTerm, upTo: range.upperBound)
                if nextNonSpace >= range.upperBound {
                    ranges.append(sentenceStart..<afterTerm)
                    sentenceStart = nextNonSpace
                    i = nextNonSpace
                    continue
                }
                ranges.append(sentenceStart..<afterTerm)
                sentenceStart = nextNonSpace
                i = nextNonSpace
                continue
            }
            i = source.index(after: i)
        }
        if sentenceStart < range.upperBound {
            ranges.append(sentenceStart..<range.upperBound)
        }
        return ranges
    }

    private static func isSentenceTerminator(_ ch: Character) -> Bool {
        ch == "." || ch == "!" || ch == "?" || ch == "…"
    }

    private static func skipLeadingWhitespace(_ source: String, from: String.Index, upTo: String.Index) -> String.Index {
        var i = from
        while i < upTo && source[i].isWhitespace { i = source.index(after: i) }
        return i
    }

    private static func isLikelyAbbreviation(
        _ source: String,
        terminatorAt: String.Index,
        sentenceStart: String.Index
    ) -> Bool {
        guard source[terminatorAt] == "." else { return false }

        var tokenEnd = terminatorAt
        var idx = terminatorAt
        var hops = 0
        while idx > sentenceStart, hops < 12 {
            let prev = source.index(before: idx)
            let ch = source[prev]
            if ch.isWhitespace { break }
            idx = prev
            hops += 1
        }
        let tokenStart = idx
        tokenEnd = source.index(after: terminatorAt)
        if tokenEnd > source.endIndex { tokenEnd = source.endIndex }
        let token = source[tokenStart..<tokenEnd].lowercased()
        if WordListData.sentenceAbbreviations.contains(token) { return true }

        let prevIdx = source.index(before: terminatorAt)
        if prevIdx >= sentenceStart {
            let prevCh = source[prevIdx]
            if prevCh.isLetter && prevCh.isUppercase {
                let twoBack = prevIdx > sentenceStart ? source.index(before: prevIdx) : prevIdx
                if twoBack == prevIdx || !source[twoBack].isLetter {
                    return true
                }
            }
        }
        return false
    }

    private static func tokenizeWords(in range: Range<String.Index>, source: String) -> [AnalyzedWord] {
        var words: [AnalyzedWord] = []
        var i = range.lowerBound
        while i < range.upperBound {
            if isWordCharacter(source[i]) {
                let start = i
                while i < range.upperBound && isWordCharacter(source[i]) {
                    i = source.index(after: i)
                }
                let end = i
                let text = String(source[start..<end])
                let isProper = isLikelyProperNoun(text, start: start, sentenceStart: range.lowerBound, source: source)
                words.append(AnalyzedWord(range: start..<end, text: text, isProperNoun: isProper))
            } else {
                i = source.index(after: i)
            }
        }
        return words
    }

    private static func isWordCharacter(_ ch: Character) -> Bool {
        if ch.isLetter { return true }
        if ch.isNumber { return true }
        if ch == "'" || ch == "\u{2019}" { return true }
        if ch == "-" { return true }
        return false
    }

    private static func isLikelyProperNoun(_ text: String, start: String.Index, sentenceStart: String.Index, source: String) -> Bool {
        guard let first = text.first, first.isUppercase else { return false }
        return start > sentenceStart
    }
}
