import Foundation

struct AccentSession: Equatable {
    let baseLetter: String
    let options: [String]
    private(set) var selectedIndex: Int = 0

    var selection: String {
        options[selectedIndex]
    }

    mutating func advance() {
        guard !options.isEmpty else {
            return
        }

        selectedIndex = (selectedIndex + 1) % options.count
    }

    mutating func reverse() {
        guard !options.isEmpty else {
            return
        }

        selectedIndex = (selectedIndex - 1 + options.count) % options.count
    }
}
