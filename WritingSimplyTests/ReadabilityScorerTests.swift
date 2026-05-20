import Testing
@testable import WritingSimply

struct ReadabilityScorerTests {

    @Test func score_empty_returnsZeroGrade() {
        let result = ReadabilityScorer.score("")
        #expect(result.words == 0)
        #expect(result.grade == 0)
    }

    @Test func score_belowThreshold_returnsZeroOrFlooredGrade() {
        let result = ReadabilityScorer.score("just three small words here")
        #expect(result.words == 5)
        #expect(result.grade >= 0)

        let fourteenWords = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen"
        let fourteen = ReadabilityScorer.score(fourteenWords)
        #expect(fourteen.words == 14)
        #expect(fourteen.grade >= 0)
    }

    @Test func score_fifteenWords_countsAccurately() {
        let fifteenWords = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen"
        let result = ReadabilityScorer.score(fifteenWords)
        #expect(result.words == 15)
    }

    @Test func score_paragraph_returnsSensibleValues() {
        let paragraph = """
        The quick brown fox jumps over the lazy dog. \
        The dog sleeps peacefully in the warm afternoon sun. \
        Birds sing softly while leaves rustle in the gentle breeze.
        """
        let result = ReadabilityScorer.score(paragraph)
        #expect(result.words >= 20)
        #expect(result.sentences == 3)
        #expect(result.syllables > 0)
        #expect(result.grade >= 0)
    }

    @Test func score_countsWordsExcludingPunctuation() {
        let text = "hello, world! one two three four five six seven eight nine ten eleven twelve."
        let result = ReadabilityScorer.score(text)
        #expect(result.words == 14)
        let padded = text + " plus one more word makes fifteen."
        let paddedResult = ReadabilityScorer.score(padded)
        #expect(paddedResult.words == 20)
    }

    @Test func score_preservesContractionsAsOneWord() {
        let text = "don't won't can't shouldn't isn't aren't wasn't weren't didn't haven't hasn't hadn't wouldn't couldn't mustn't"
        let result = ReadabilityScorer.score(text)
        #expect(result.words == 15)
    }

    @Test func score_countsSentencesByTerminators() {
        let text = "The first sentence ends here. The second one is also short. The third wraps things up neatly here."
        let result = ReadabilityScorer.score(text)
        #expect(result.sentences == 3)
    }

    @Test func score_collapsesConsecutiveTerminators() {
        let text = "Wait... what just happened?! No way that was possible without some prior planning ahead!!! Really now."
        let result = ReadabilityScorer.score(text)
        #expect(result.sentences == 4)
    }

    @Test func score_zeroSentences_flooredToOne() {
        let text = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen"
        let result = ReadabilityScorer.score(text)
        #expect(result.sentences == 1)
    }

    @Test func score_gradeIsNonNegative() {
        let trivial = "a a a a a a a a a a a a a a a"
        let result = ReadabilityScorer.score(trivial)
        #expect(result.grade >= 0)
    }

    @Test func score_isDeterministic() {
        let text = "Testing repeatability is fundamental to trustworthy software. We expect identical inputs to produce identical outputs."
        let first = ReadabilityScorer.score(text)
        let second = ReadabilityScorer.score(text)
        #expect(first == second)
    }
}
