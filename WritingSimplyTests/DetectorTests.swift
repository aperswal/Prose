import Testing
@testable import WritingSimply

struct DetectorTests {

    @Test func longSentence_flaggedWhenOver30Words() {
        let text = "Mary had a little lamb and the lamb was really very fluffy and it was utilized as a great example of an absolutely essential point that was kind of basically being made by the author here."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectLongSentences(analyzed)
        #expect(ranges.count == 1)
        #expect(ranges.first?.category == .longSentence)
    }

    @Test func mediumSentence_flaggedBetween20And30() {
        let text = "This sentence has exactly twenty one words and it should be flagged as medium because the count sits between twenty and thirty."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectMediumSentences(analyzed)
        #expect(ranges.count == 1)
        #expect(ranges.first?.category == .mediumSentence)
    }

    @Test func shortSentence_notFlagged() {
        let text = "Short and simple."
        let analyzed = TextNormalizer.analyze(text)
        #expect(Detectors.detectLongSentences(analyzed).isEmpty)
        #expect(Detectors.detectMediumSentences(analyzed).isEmpty)
    }

    @Test func adverb_flaggedOnLyWord() {
        let text = "She walked quickly to the store."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectAdverbs(analyzed)
        #expect(ranges.count == 1)
    }

    @Test func adverbWhitelist_notFlagged() {
        let text = "I post daily and reply weekly to questions."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectAdverbs(analyzed)
        #expect(ranges.isEmpty)
    }

    @Test func adverb_properNounNotFlagged() {
        let text = "I visited Wembley yesterday."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectAdverbs(analyzed)
        let flagged = ranges.map { String(text[$0.range]) }
        #expect(!flagged.contains("Wembley"))
    }

    @Test func filler_flaggedSingleWord() {
        let text = "I basically agree with the plan."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectFillers(analyzed)
        #expect(ranges.count == 1)
        #expect(String(text[ranges[0].range]) == "basically")
    }

    @Test func filler_flaggedMultiWordPhrase() {
        let text = "I mean, the idea is good, you know?"
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectFillers(analyzed)
        let snippets = ranges.map { String(text[$0.range]).lowercased() }
        #expect(snippets.contains("i mean"))
        #expect(snippets.contains("you know"))
    }

    @Test func inflated_flaggedWithReplacement() {
        let text = "We need to utilize the new framework."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectInflatedVocabulary(analyzed)
        #expect(ranges.count == 1)
        #expect(ranges.first?.replacement == "use")
    }

    @Test func inflated_priorTo_twoWordMatch() {
        let text = "Submit the form prior to the deadline."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectInflatedVocabulary(analyzed)
        #expect(ranges.count == 1)
        #expect(ranges.first?.replacement == "before")
    }

    @Test func passive_simpleBeForm() {
        let text = "The package was delivered yesterday."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectPassive(analyzed)
        #expect(ranges.count == 1)
    }

    @Test func passive_irregularParticiple() {
        let text = "The vase was broken by the cat."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectPassive(analyzed)
        #expect(ranges.count == 1)
    }

    @Test func passive_activeNotFlagged() {
        let text = "The cat broke the vase."
        let analyzed = TextNormalizer.analyze(text)
        let ranges = Detectors.detectPassive(analyzed)
        #expect(ranges.isEmpty)
    }

    @Test func engine_canonical_producesExpectedCategories() {
        let text = "Mary had a little lamb, and the lamb was really very fluffy, and it was utilized as a great example of an absolutely essential point that was kind of basically being made by the author."
        let ranges = HighlightEngine.analyze(text)
        let categories = Set(ranges.map(\.category))
        #expect(categories.contains(.longSentence))
        #expect(categories.contains(.adverb))
        #expect(categories.contains(.passiveVoice))
        #expect(categories.contains(.inflatedVocabulary))
        #expect(categories.contains(.filler))
    }

    @Test func bulletList_noFalseFlagsOnMarker() {
        let text = "- Ship the eye icon\n- Ship the highlights\n- Ship the explainer"
        let ranges = HighlightEngine.analyze(text)
        let snippets = ranges.map { String(text[$0.range]) }
        #expect(!snippets.contains(where: { $0.contains("-") && $0.count <= 3 }))
    }
}
