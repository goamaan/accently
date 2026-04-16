import Foundation

final class AccentUsageStore {
    private let defaults: UserDefaults
    private let usageKey: String

    init(
        defaults: UserDefaults = .standard,
        usageKey: String = "Accently.AccentUsageCounts"
    ) {
        self.defaults = defaults
        self.usageKey = usageKey
    }

    func orderedOptions(for baseLetter: String, uppercase: Bool) -> [String]? {
        guard let options = AccentCatalog.baseOptions(for: baseLetter) else {
            return nil
        }

        let counts = loadCounts()
        let sorted = options
            .enumerated()
            .sorted { lhs, rhs in
                let leftCount = counts[normalizedKey(for: lhs.element), default: 0]
                let rightCount = counts[normalizedKey(for: rhs.element), default: 0]

                if leftCount != rightCount {
                    return leftCount > rightCount
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)

        if uppercase {
            return sorted.map { $0.uppercased() }
        }

        return sorted
    }

    func record(selection: String) {
        let key = normalizedKey(for: selection)
        var counts = loadCounts()
        counts[key, default: 0] += 1
        defaults.set(counts, forKey: usageKey)
    }

    func reset() {
        defaults.removeObject(forKey: usageKey)
    }

    private func loadCounts() -> [String: Int] {
        defaults.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
    }

    private func normalizedKey(for accent: String) -> String {
        accent.lowercased()
    }
}
