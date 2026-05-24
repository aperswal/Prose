import Foundation

enum WordListData {

    static let fillers: [String] = [
        "basically", "literally", "you know", "i mean", "just",
        "actually", "honestly", "obviously", "clearly", "right"
    ]

    static let inflatedVocabulary: [String: String] = [
        "utilize": "use",
        "utilizes": "uses",
        "utilized": "used",
        "utilizing": "using",
        "facilitate": "help",
        "facilitates": "helps",
        "facilitated": "helped",
        "facilitating": "helping",
        "ascertain": "find out",
        "ascertains": "finds out",
        "ascertained": "found out",
        "optimize": "improve",
        "optimizes": "improves",
        "optimized": "improved",
        "optimizing": "improving",
        "leverage": "use",
        "leverages": "uses",
        "leveraged": "used",
        "leveraging": "using",
        "endeavor": "try",
        "endeavors": "tries",
        "endeavored": "tried",
        "commence": "start",
        "commences": "starts",
        "commenced": "started",
        "commencing": "starting",
        "terminate": "end",
        "terminates": "ends",
        "terminated": "ended",
        "terminating": "ending",
        "regarding": "about",
        "subsequent": "next",
        "prior to": "before"
    ]

    static let adverbWhitelist: Set<String> = [
        "only", "early", "likely", "family", "apply", "reply",
        "july", "supply", "daily", "weekly", "monthly",
        "friendly", "lovely", "lonely", "silly", "ugly",
        "holy", "ally", "jolly", "homely", "manly",
        "bully", "rally", "bubbly", "wobbly", "wiggly",
        "fly", "ply", "sly", "shy", "spy", "try", "cry", "dry", "fry", "pry", "sty",
        "italy", "sicily", "rally", "tally", "valley", "alley", "belly",
        "billy", "willy", "kelly", "molly", "polly", "wally", "wembley"
    ]

    static let sentenceAbbreviations: Set<String> = [
        "mr.", "mrs.", "ms.", "dr.", "sr.", "jr.", "st.",
        "inc.", "co.", "ltd.", "corp.",
        "ph.d.", "m.d.", "b.a.", "m.a.",
        "e.g.", "i.e.", "etc.", "vs.", "cf.",
        "no.", "vol.",
        "ave.", "blvd.", "rd.", "apt.",
        "jan.", "feb.", "mar.", "apr.", "jun.", "jul.", "aug.",
        "sep.", "sept.", "oct.", "nov.", "dec.",
        "mon.", "tue.", "wed.", "thu.", "fri.", "sat.", "sun.",
        "a.m.", "p.m.",
        "u.s.", "u.k.", "u.n.", "e.u.", "u.s.a."
    ]

    static let bulletMarkers: [String] = ["- ", "* ", "• ", "– ", "— ", "‣ ", "· "]

    static let passiveAuxiliaries: Set<String> = [
        "am", "is", "are", "was", "were", "be", "been", "being",
        "get", "gets", "got", "gotten", "getting"
    ]
}
