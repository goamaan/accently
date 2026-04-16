import Foundation
import Testing
@testable import Accently

struct AccentUsageStoreTests {
    @Test
    func sortsOptionsByRecordedFrequency() throws {
        let suiteName = "AccentlyTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let store = AccentUsageStore(defaults: defaults, usageKey: "Usage")

        store.record(selection: "ê")
        store.record(selection: "ê")
        store.record(selection: "é")

        let options = store.orderedOptions(for: "e", uppercase: false)
        #expect(options == ["ê", "é", "è", "ë"])
    }

    @Test
    func preservesLearnedOrderForUppercase() throws {
        let suiteName = "AccentlyTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let store = AccentUsageStore(defaults: defaults, usageKey: "Usage")

        store.record(selection: "û")
        store.record(selection: "ù")
        store.record(selection: "û")

        let options = store.orderedOptions(for: "u", uppercase: true)
        #expect(options == ["Û", "Ù", "Ü"])
    }

    @Test
    func resetClearsRecordedOrder() throws {
        let suiteName = "AccentlyTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let store = AccentUsageStore(defaults: defaults, usageKey: "Usage")

        store.record(selection: "ë")
        store.record(selection: "ë")
        store.reset()

        let options = store.orderedOptions(for: "e", uppercase: false)
        #expect(options == ["é", "è", "ê", "ë"])
    }
}
