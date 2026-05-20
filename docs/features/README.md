# The WritingSimply feature catalog organizes every check and every piece of UI plumbing as its own feature doc.

## How this folder is organized

Each file in this folder describes one feature in enough detail to start implementation. The features fall into three groups. Infrastructure features in the 00 range cover the editor plumbing that everything else depends on. Deterministic check features in the 10 range cover the rules that can be enforced by code alone. Non-deterministic check features in the 50 range cover the rules that require a language model call.

Every feature doc has the same shape. A title that is a full sentence stating what the feature does. A short context section explaining why the feature exists and how it fits with the rest of the app. A dependencies section listing other features that must land first. An execution list written as a test-driven sequence of small steps, where each test failure leads to the smallest implementation change that makes it pass. An acceptance criteria list of testable outcomes that signal the feature is done.

The titles avoid noun phrases like "filler word detection." They use full sentences that describe what the feature does, so a reader can skim the folder and understand the whole product from filenames alone.

## What is written so far

The five infrastructure docs are complete. There are also six exemplar check docs, one for each of the six patterns the checks fall into. The remaining seventy-three checks share their pattern with one of the exemplars and can be filled in by following the exemplar's structure.

## Index of files in this folder

Infrastructure features that everything else depends on.

- `00-review-mode-toggle.md`
- `01-attributed-string-editor-binding.md`
- `02-inline-flag-underline.md`
- `03-flag-explanation-popover.md`
- `04-inspector-pane.md`

Deterministic check exemplars, one per pattern.

- `10-filler-word-detection.md` is the word-list pattern.
- `11-passive-voice-detection.md` is the regex pattern.
- `12-sentence-length-flag.md` is the per-sentence threshold pattern.
- `13-sentence-length-variance.md` is the piece-level statistic pattern.

Non-deterministic check exemplars, one per pattern.

- `50-visualize-test.md` is the per-sentence language model pattern.
- `51-conviction-check.md` is the piece-level language model pattern.

## Remaining deterministic checks that follow the word-list pattern

Each of these is a separate feature doc to be written in the shape of `10-filler-word-detection.md`. Only the word list and the false-positive examples differ.

- Qualifier and hedge detection covers "kind of," "sort of," "a little bit," "maybe," "I think," "I feel like," "I guess," "perhaps," "somewhat," and "slightly."
- Apologetic preamble detection covers "sorry but," "this might be wrong but," "I'm no expert but," "this might be a stupid question but," "I'm not sure if this is right but," and "forgive me if."
- Empty intensifier detection covers "very," "really," "extremely," "incredibly," "absolutely," "totally," "completely," "truly," "highly," and "utterly."
- Redundant pair detection covers "absolutely essential," "completely finished," "very unique," "totally destroyed," "end result," "free gift," "past history," "future plans," "basic fundamentals," "each and every," and "first and foremost."
- Inflated vocabulary detection covers swaps such as "utilize" to "use," "facilitate" to "help," "ascertain" to "find out," and the full list from the framework, where each match suggests a plainer replacement in the popover.
- Credibility killer detection covers "does that make sense?", "if that makes sense," "you know what I mean?", "right?", "yeah?", and "make sense?".
- Wordy phrase detection covers "in order to," "the reason being is," "what I'm trying to say is," "the thing is that," "it should be noted that," "it is worth mentioning that," "needless to say," "as a matter of fact," "at the end of the day," "when all is said and done," and "the bottom line is."
- Weasel attribution detection covers "some people say," "studies show," "they say," "it is said that," "many believe," "experts agree," and "research suggests" when no specific source is named.
- Over-self-attribution detection covers "I believe that," "in my opinion," "personally I think," "I feel that," "from my perspective," and "if you ask me."
- Weak closer detection covers "so yeah," "anyway," "and stuff like that," "and things like that," "and whatnot," "etc etc," "you get the idea," "and so on and so forth," and "but yeah."
- Abstract buzzword detection covers the Harry Dry list of words a reader cannot visualize, including "seamless," "innovative," "solutions," "synergy," "cutting-edge," "world-class," and the rest.
- Cliche simile and metaphor detection covers a starter list of overused comparisons such as "ran like a madman," "pretty as a summer day," "fought like a tiger," "hit the ground running," and "think outside the box."

## Remaining deterministic checks that follow the regex pattern

Each of these is a separate feature doc to be written in the shape of `11-passive-voice-detection.md`. Only the pattern and the false-positive avoidance differ.

- Adverb detection flags words ending in "-ly" with a small whitelist for words that happen to end in "-ly" without being adverbs, such as "only," "early," "likely," "family," "apply," "reply," "July," "supply," "daily," "weekly," and "monthly."
- Throat-clearing opener detection flags sentence-initial phrases such as "it's important to note that," "the fact of the matter is," "it goes without saying that," "what I want to say is," "let me start by saying," "I just wanted to say," "it is interesting to note that," "it is worth pointing out that," and "it bears mentioning that."
- Weak existence starter detection flags sentence-initial "there is," "there are," "there was," "there were," "there will be," "there have been," and "there has been."
- Front-loaded negative detection flags sentence-initial "I'm not sure," "I don't know if," "I can't say for certain," "I'm not confident," "this may not be," and "I'm not the best person to."
- But-after-positive detection flags any sentence containing a comma followed by "but," surfacing the construction for review without claiming the negation is wrong.
- Scope dilution detection flags sentences and headlines where "and" connects two or more value propositions, using a small list of noun categories to recognize the pattern.
- Adjective-heavy sentence detection flags sentences with three or more adjectives and zero concrete nouns, using a part-of-speech tagger to identify the adjectives and nouns.
- No-concrete-noun detection flags sentences whose every noun is abstract, where concrete and abstract membership comes from a curated list.

## Remaining deterministic checks that follow the per-sentence threshold pattern

Each of these is a separate feature doc to be written in the shape of `12-sentence-length-flag.md`.

- Comma count per sentence flags any sentence with more than two commas.
- Paragraph length flag flags any paragraph over five sentences or one hundred words.
- Wall of text detection flags any stretch of more than two hundred words without a paragraph break, subheading, or visual break.

## Remaining deterministic checks that follow the piece-level statistic pattern

Each of these is a separate feature doc to be written in the shape of `13-sentence-length-variance.md`.

- Words per sentence average flags the piece when the average exceeds twenty-two words.
- Consecutive same-length sentence detection flags three or more consecutive sentences within three words of each other in length.
- Adverb density flag flags the piece when more than three "-ly" adverbs appear per hundred words.
- Passive voice percentage flag flags the piece when more than twenty percent of its sentences are in passive voice.
- Sentence-initial word repetition flag flags three or more consecutive sentences that start with the same word.
- Kaplan word count delta flag estimates how many words could be removed without changing meaning and flags the piece when the share exceeds a threshold.
- Concrete noun density flag flags paragraphs containing zero concrete nouns.
- Fact density flag flags sections containing zero falsifiable claims, where a falsifiable claim includes numbers, dates, proper nouns, or named sources.

The existing Flesch-Kincaid grade chip continues to power the Overview card at the top of the inspector and does not need a separate feature doc, because the work to integrate it lives in `04-inspector-pane.md`.

## Remaining non-deterministic checks that follow the per-sentence language model pattern

Each of these is a separate feature doc to be written in the shape of `50-visualize-test.md`. Only the prompt and the result parsing differ.

- Falsify test asks the model whether each sentence is falsifiable or only subjective.
- Bespoke test asks the model whether each sentence is something only this writer or product could say.
- Single-point test asks the model whether each sentence carries one point or several competing ones.
- Front-loaded test asks the model whether each sentence's key information sits up front or is buried.
- Advances-or-filler test asks the model whether removing the sentence would change the reader's understanding.
- AIDA function test asks the model whether each sentence grabs attention, builds interest, creates desire, or drives action.
- Two-second test asks the model whether a cold reader gets the sentence in under two seconds.
- Hedge justification test asks the model whether each hedge matches the writer's actual level of certainty.
- Claim-or-hedge test asks the model whether the sentence makes a claim or hedges one.
- Landing test asks the model whether each sentence lands at its end or fizzles.
- Cliche figurative language test asks the model whether each metaphor or simile is clichéd or fresh.
- Pointing-versus-talking test asks the model whether each sentence points at evidence or just asserts.
- Intentional-but test asks the model whether each "but" is intentional contrast or accidental undermining.
- Kaplan survival test asks the model whether each sentence would survive being removed.

## Remaining non-deterministic checks that follow the piece-level language model pattern

Each of these is a separate feature doc to be written in the shape of `51-conviction-check.md`. Only the prompt and the result parsing differ.

- Voice test asks the model whether the piece sounds like a person talking or like a textbook.
- One-person test asks the model whether the piece is written to one person or broadcast to an audience.
- Sounding-smart test asks the model whether the writer is trying to sound smart instead of communicating.
- Tone consistency test asks the model whether the tone stays consistent across the piece.
- Out-of-the-oven test asks the model whether the writing feels fresh and immediate or polished into lifelessness.
- Sentence variation intent test asks the model whether the variation feels intentional rather than accidental.
- Rhythm-serves-content test asks the model whether the rhythm fits what is being said.
- Breathing room test asks the model whether the piece gives the reader space to process.
- Description density test asks the model whether descriptions sit at the right density for the moment.
- Detail quality test asks the model whether the details are well-chosen rather than generic.
- Figurative earning test asks the model whether each metaphor and simile earns its place.
- Metonymy suggestion test asks the model whether any sentence would benefit from metonymy in place of the literal noun.
- Contrast-and-polarity test asks the model whether the piece sets up contrast that sharpens both sides.
- Opening hook test asks the model whether the opening is a hook or a warm-up.
- Slippery slope test asks the model whether each sentence pulls the reader into the next.
- Headline sentence test asks the model whether the headline reads as a sentence or a label.
- Scope narrowness test asks the model whether the piece's scope is narrow enough for the idea to land.
- Dividing line test asks the model whether the structure gives the reader clear dividing lines.
- Features-versus-benefits test asks the model whether the piece sells benefits or lists features.
- Feeling-versus-specs test asks the model whether the piece sells a feeling or just transmits specs.
- Dialogue honesty test asks the model whether any dialogue sounds like real people talking.
- Lecturing test asks the model whether the piece lectures the reader or weaves knowledge into the prose.
- Forgotten text test asks the model whether secondary surfaces such as welcome emails or confirmation pages are customized rather than templated.
- Pointing-or-talking piece test asks the model whether the piece as a whole points at evidence or just talks.
- Self-attention test asks the model whether the writing draws attention to its own craft or stays invisible.
- Grade level appropriateness test asks the model whether the calculated Flesch-Kincaid grade is appropriate for the audience and venue.
- Passive justification test asks the model whether each passive flag from the deterministic check is justified in context.
- Only-you-can-write-this test asks the model whether the piece could have been generated by anyone or carries the writer's specific taste and experience.
