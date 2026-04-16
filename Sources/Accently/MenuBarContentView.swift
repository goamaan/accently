import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var store: AccentlyStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Enable Accently", isOn: $store.isEnabled)

            VStack(alignment: .leading, spacing: 6) {
                Text(store.statusLine)
                    .font(.system(size: 12, weight: .semibold))

                Text("\(store.triggerDescription) for lowercase")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Text("Add Shift for uppercase")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Picker("Picker position", selection: $store.positionMode) {
                ForEach(PickerPositionMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Divider()

            permissionRow(
                title: "Input Monitoring",
                granted: store.eventTapAvailable,
                actionTitle: "Open Input Monitoring Settings",
                action: store.openInputMonitoringSettings
            )

            Button("Check Input Monitoring Again") {
                store.refreshPermissions()
            }

            Divider()

            Button("Reset Learned Order") {
                store.resetLearnedOrder()
            }

            Divider()

            Button("Quit Accently") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(14)
        .frame(width: 280)
    }

    @ViewBuilder
    private func permissionRow(
        title: String,
        granted: Bool,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text(granted ? "\(title) ready" : "\(title) needed")
            } icon: {
                Image(systemName: granted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(granted ? Color.green : Color.red)
            }
            .font(.system(size: 11, weight: .medium))

            if !granted {
                Button(actionTitle, action: action)
                    .font(.system(size: 11))
                    .buttonStyle(.plain)
            }
        }
    }
}
