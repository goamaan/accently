import AppKit
import SwiftUI

@main
struct AccentlyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = AccentlyStore()

    var body: some Scene {
        MenuBarExtra("Accently", systemImage: "textformat.alt") {
            MenuBarContentView()
                .environmentObject(store)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
