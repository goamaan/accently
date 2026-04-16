import AppKit
import Foundation

@MainActor
final class AccentlyStore: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            if !isEnabled {
                engine.cancelActiveSession()
                statusLine = "Paused"
            } else {
                statusLine = eventTapAvailable ? "Ready" : "Input Monitoring needed"
            }
        }
    }

    @Published var positionMode: PickerPositionMode {
        didSet {
            UserDefaults.standard.set(positionMode.rawValue, forKey: Self.positionModeKey)
            engine.repositionActiveSession()
        }
    }

    @Published private(set) var eventTapAvailable = false
    @Published private(set) var statusLine = "Starting"

    let triggerDescription = "Control + Option"

    private static let enabledKey = "Accently.Enabled"
    private static let positionModeKey = "Accently.PositionMode"

    private let usageStore = AccentUsageStore()
    private lazy var engine = makeEngine()

    init() {
        let defaults = UserDefaults.standard
        let storedPosition = defaults.string(forKey: Self.positionModeKey)
        let loadedPosition = storedPosition.flatMap(PickerPositionMode.init(rawValue:)) ?? .centerScreen
        let loadedEnabled = defaults.object(forKey: Self.enabledKey) as? Bool ?? true

        isEnabled = loadedEnabled
        positionMode = loadedPosition

        engine.start()
        refreshStatusLine()
    }

    private func makeEngine() -> AccentInputEngine {
        AccentInputEngine(
            configuration: {
                let defaults = UserDefaults.standard
                let rawMode = defaults.string(forKey: Self.positionModeKey)
                let mode = rawMode.flatMap(PickerPositionMode.init(rawValue:)) ?? .centerScreen
                let enabled = defaults.object(forKey: Self.enabledKey) as? Bool ?? true
                return AccentInputEngine.Configuration(isEnabled: enabled, positionMode: mode)
            },
            onEventTapAvailabilityChange: { [weak self] isAvailable in
                Task { @MainActor [weak self] in
                    self?.eventTapAvailable = isAvailable
                    self?.refreshStatusLine()
                }
            },
            onStatusChange: { [weak self] status in
                Task { @MainActor [weak self] in
                    self?.statusLine = status
                }
            },
            optionsForLetter: { [usageStore] letter, uppercase in
                usageStore.orderedOptions(for: letter, uppercase: uppercase)
            },
            recordSelection: { [usageStore] selection in
                usageStore.record(selection: selection)
            }
        )
    }

    func refreshPermissions() {
        engine.restart()
        refreshStatusLine()
    }

    func openInputMonitoringSettings() {
        openSettingsPane("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    func resetLearnedOrder() {
        usageStore.reset()
        engine.cancelActiveSession()
    }

    private func refreshStatusLine() {
        if !isEnabled {
            statusLine = "Paused"
        } else if !eventTapAvailable {
            statusLine = "Input Monitoring needed"
        } else {
            statusLine = "Ready"
        }
    }

    private func openSettingsPane(_ rawURL: String) {
        guard let url = URL(string: rawURL) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
