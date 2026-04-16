import CoreGraphics
import Foundation

enum AccentCharacterInjector {
    static func inject(_ text: String, eventTag: Int64) {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            return
        }

        let scalars = Array(text.utf16)
        let count = scalars.count

        guard
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        else {
            return
        }

        scalars.withUnsafeBufferPointer { buffer in
            guard let pointer = buffer.baseAddress else {
                return
            }

            keyDown.keyboardSetUnicodeString(stringLength: count, unicodeString: pointer)
            keyUp.keyboardSetUnicodeString(stringLength: count, unicodeString: pointer)
        }

        keyDown.flags = []
        keyUp.flags = []
        keyDown.setIntegerValueField(.eventSourceUserData, value: eventTag)
        keyUp.setIntegerValueField(.eventSourceUserData, value: eventTag)
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
