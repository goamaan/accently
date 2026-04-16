@preconcurrency import AppKit
@preconcurrency import CoreGraphics
import Foundation

@MainActor
final class AccentInputEngine {
    struct Configuration {
        let isEnabled: Bool
        let positionMode: PickerPositionMode
    }

    private static let injectedEventTag: Int64 = 4_263_711

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let panelController = AccentPanelController()
    private let configuration: () -> Configuration
    private let onEventTapAvailabilityChange: (Bool) -> Void
    private let onStatusChange: (String) -> Void
    private let optionsForLetter: (String, Bool) -> [String]?
    private let recordSelection: (String) -> Void

    private var activeSession: AccentSession?

    init(
        configuration: @escaping () -> Configuration,
        onEventTapAvailabilityChange: @escaping (Bool) -> Void,
        onStatusChange: @escaping (String) -> Void,
        optionsForLetter: @escaping (String, Bool) -> [String]?,
        recordSelection: @escaping (String) -> Void
    ) {
        self.configuration = configuration
        self.onEventTapAvailabilityChange = onEventTapAvailabilityChange
        self.onStatusChange = onStatusChange
        self.optionsForLetter = optionsForLetter
        self.recordSelection = recordSelection
    }

    func start() {
        guard eventTap == nil else {
            onEventTapAvailabilityChange(true)
            return
        }

        let eventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let engine = Unmanaged<AccentInputEngine>.fromOpaque(userInfo).takeUnretainedValue()
            return MainActor.assumeIsolated {
                engine.handleEvent(type: type, event: event)
            }
        }

        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: userInfo
        ) else {
            onEventTapAvailabilityChange(false)
            onStatusChange("Input Monitoring needed")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
        onEventTapAvailabilityChange(true)
        onStatusChange("Ready")
    }

    func stop() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }

        runLoopSource = nil
        eventTap = nil
        cancelActiveSession()
        onEventTapAvailabilityChange(false)
    }

    func restart() {
        stop()
        start()
    }

    func cancelActiveSession() {
        activeSession = nil
        panelController.hide()
    }

    func repositionActiveSession() {
        panelController.reposition(mode: configuration().positionMode)
    }

    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }

            return Unmanaged.passUnretained(event)
        }

        if event.getIntegerValueField(.eventSourceUserData) == Self.injectedEventTag {
            return Unmanaged.passUnretained(event)
        }

        let currentConfiguration = configuration()
        guard currentConfiguration.isEnabled else {
            return Unmanaged.passUnretained(event)
        }

        switch type {
        case .keyDown:
            return handleKeyDown(event: event, configuration: currentConfiguration)
        case .keyUp:
            if activeSession != nil {
                return nil
            }
            return Unmanaged.passUnretained(event)
        case .flagsChanged:
            return handleFlagsChanged(event: event, configuration: currentConfiguration)
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleKeyDown(event: CGEvent, configuration: Configuration) -> Unmanaged<CGEvent>? {
        if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 {
            return activeSession == nil ? Unmanaged.passUnretained(event) : nil
        }

        let flags = event.flags

        if let activeSession {
            if isEscape(event: event) {
                cancelActiveSession()
                return nil
            }

            if let pressedLetter = normalizedLetter(from: event) {
                var updatedSession = activeSession

                if pressedLetter == activeSession.baseLetter {
                    updatedSession.advance()
                } else {
                    updatedSession.reverse()
                }

                self.activeSession = updatedSession
                panelController.show(session: updatedSession, mode: configuration.positionMode)
            }

            return nil
        }

        guard triggerIsActive(flags) else {
            return Unmanaged.passUnretained(event)
        }

        guard let pressedLetter = normalizedLetter(from: event),
              let options = optionsForLetter(pressedLetter, shouldUppercase(with: flags))
        else {
            return Unmanaged.passUnretained(event)
        }

        let session = AccentSession(baseLetter: pressedLetter, options: options)
        activeSession = session
        panelController.show(session: session, mode: configuration.positionMode)
        return nil
    }

    private func handleFlagsChanged(event: CGEvent, configuration: Configuration) -> Unmanaged<CGEvent>? {
        guard activeSession != nil else {
            return Unmanaged.passUnretained(event)
        }

        if triggerIsActive(event.flags) {
            return Unmanaged.passUnretained(event)
        }

        commitSelection()
        return Unmanaged.passUnretained(event)
    }

    private func commitSelection() {
        guard let selection = activeSession?.selection else {
            cancelActiveSession()
            return
        }

        activeSession = nil
        panelController.hide()
        recordSelection(selection)
        AccentCharacterInjector.inject(selection, eventTag: Self.injectedEventTag)
    }

    private func normalizedLetter(from event: CGEvent) -> String? {
        guard let nsEvent = NSEvent(cgEvent: event),
              let characters = nsEvent.charactersIgnoringModifiers?.lowercased(),
              let first = characters.unicodeScalars.first,
              characters.count == 1
        else {
            return nil
        }

        guard CharacterSet.letters.contains(first), first.isASCII else {
            return nil
        }

        return String(first)
    }

    private func triggerIsActive(_ flags: CGEventFlags) -> Bool {
        flags.contains(.maskControl) && flags.contains(.maskAlternate)
    }

    private func shouldUppercase(with flags: CGEventFlags) -> Bool {
        triggerIsActive(flags) && flags.contains(.maskShift)
    }

    private func isEscape(event: CGEvent) -> Bool {
        event.getIntegerValueField(.keyboardEventKeycode) == 53
    }
}
