import Testing
@testable import WritingSimply

struct TextNormalizerTests {

    @Test func empty_returnsNoSentences() {
        let analyzed = TextNormalizer.analyze("")
        #expect(analyzed.sentences.isEmpty)
    }

    @Test func singleSentence_returnsOneSentence() {
        let analyzed = TextNormalizer.analyze("Hello world.")
        #expect(analyzed.sentences.count == 1)
        #expect(analyzed.sentences.first?.words.count == 2)
    }

    @Test func bulletDash_excludedFromContent() {
        let text = "- ship the eye icon"
        let analyzed = TextNormalizer.analyze(text)
        #expect(analyzed.sentences.count == 1)
        let sentence = analyzed.sentences[0]
        #expect(sentence.kind == .listItem)
        #expect(sentence.words.map(\.text) == ["ship", "the", "eye", "icon"])
        let dashOutsideRange = text.firstIndex(of: "-")!
        #expect(sentence.range.lowerBound > dashOutsideRange)
    }

    @Test func bulletStar_treatedSameAsDash() {
        let dashAnalyzed = TextNormalizer.analyze("- one\n- two")
        let starAnalyzed = TextNormalizer.analyze("* one\n* two")
        #expect(dashAnalyzed.sentences.count == starAnalyzed.sentences.count)
        #expect(dashAnalyzed.sentences.allSatisfy { $0.kind == .listItem })
        #expect(starAnalyzed.sentences.allSatisfy { $0.kind == .listItem })
    }

    @Test func bulletPoint_unicode() {
        let analyzed = TextNormalizer.analyze("• one\n– two\n— three")
        #expect(analyzed.sentences.count == 3)
        #expect(analyzed.sentences.allSatisfy { $0.kind == .listItem })
    }

    @Test func numberedList_treatedAsListItem() {
        let analyzed = TextNormalizer.analyze("1. one\n2. two")
        #expect(analyzed.sentences.count == 2)
        #expect(analyzed.sentences.allSatisfy { $0.kind == .listItem })
    }

    @Test func wellKnownIsOneToken() {
        let analyzed = TextNormalizer.analyze("This is a well-known fact.")
        let words = analyzed.sentences[0].words.map(\.text)
        #expect(words.contains("well-known"))
        #expect(!words.contains("well"))
        #expect(!words.contains("known"))
    }

    @Test func contractionIsOneToken() {
        let analyzed = TextNormalizer.analyze("Don't worry about it.")
        let words = analyzed.sentences[0].words.map(\.text)
        #expect(words.first == "Don't" || words.first == "don't" || words.contains(where: { $0.lowercased() == "don't" }))
    }

    @Test func abbreviation_doesNotEndSentence() {
        let analyzed = TextNormalizer.analyze("Mr. Smith works at Apple Inc. and ships code.")
        #expect(analyzed.sentences.count == 1)
    }

    @Test func usaAbbreviation_doesNotEndSentence() {
        let analyzed = TextNormalizer.analyze("She lives in the U.S. and works in Canada.")
        #expect(analyzed.sentences.count == 1)
    }

    @Test func multipleSentences_terminator() {
        let analyzed = TextNormalizer.analyze("First sentence here. Second sentence here. Third one too.")
        #expect(analyzed.sentences.count == 3)
    }

    @Test func longBullet_stillTokenizesContent() {
        let bullet = "- this is a really long bullet that has more than thirty words and so on and so on filling up the line with prose"
        let analyzed = TextNormalizer.analyze(bullet)
        #expect(analyzed.sentences.count == 1)
        #expect(analyzed.sentences[0].kind == .listItem)
        #expect(analyzed.sentences[0].words.count > 20)
    }
}
