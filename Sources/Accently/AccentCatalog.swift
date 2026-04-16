import Foundation

enum AccentCatalog {
    private static let frenchAccents: [String: [String]] = [
        "a": ["à", "â", "æ"],
        "c": ["ç"],
        "e": ["é", "è", "ê", "ë"],
        "i": ["î", "ï"],
        "o": ["ô", "œ"],
        "u": ["ù", "û", "ü"],
        "y": ["ÿ"]
    ]

    static func baseOptions(for baseLetter: String) -> [String]? {
        frenchAccents[baseLetter.lowercased()]
    }

    static func options(for baseLetter: String, uppercase: Bool) -> [String]? {
        guard let options = baseOptions(for: baseLetter) else {
            return nil
        }

        if uppercase {
            return options.map { $0.uppercased() }
        }

        return options
    }

    static func isSupported(letter: String) -> Bool {
        frenchAccents[letter.lowercased()] != nil
    }
}
