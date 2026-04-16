import Testing
@testable import Accently

struct AccentSessionTests {
    @Test
    func advancesThroughOptions() {
        var session = AccentSession(baseLetter: "e", options: ["é", "è", "ê"])

        session.advance()
        #expect(session.selection == "è")

        session.advance()
        #expect(session.selection == "ê")

        session.advance()
        #expect(session.selection == "é")
    }

    @Test
    func reversesThroughOptions() {
        var session = AccentSession(baseLetter: "e", options: ["é", "è", "ê"])

        session.reverse()
        #expect(session.selection == "ê")

        session.reverse()
        #expect(session.selection == "è")
    }

    @Test
    func uppercasesOptions() {
        let options = AccentCatalog.options(for: "e", uppercase: true)
        #expect(options == ["É", "È", "Ê", "Ë"])
    }
}
