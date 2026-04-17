# Accently Agent Notes

This repository is a small macOS background utility for typing accented French
characters through a global keyboard chord and a floating picker.

## Product shape

- The app is menubar-style and runs with `LSUIElement = true`.
- The current trigger is `Control + Option`.
- While the trigger is held:
  - pressing a supported base letter opens the accent picker
  - pressing the same letter moves forward
  - pressing a different letter moves backward
  - releasing the modifiers commits the selected accent
- Picker positions are intentionally simple right now: `Center Screen` and
  `Near Mouse`.

## Architecture

- [Sources/Accently/AccentlyApp.swift](Sources/Accently/AccentlyApp.swift)
  owns app startup and the menu bar scene.
- [Sources/Accently/AccentlyStore.swift](Sources/Accently/AccentlyStore.swift)
  owns persisted settings and wires the input engine to the UI.
- [Sources/Accently/AccentInputEngine.swift](Sources/Accently/AccentInputEngine.swift)
  is the core interaction state machine. Be careful here.
- [Sources/Accently/AccentPanelController.swift](Sources/Accently/AccentPanelController.swift)
  manages the floating `NSPanel`.
- [Sources/Accently/AccentUsageStore.swift](Sources/Accently/AccentUsageStore.swift)
  persists learned ordering in `UserDefaults`.

## Input pipeline rules

- Keep the event tap on the main run loop unless there is a very good reason to
  move it.
- Synthetic key events are tagged with `eventSourceUserData` so the app does not
  react to its own injected output. Preserve that behavior if you change text
  insertion.
- Input Monitoring permission is required for the event tap to work. The app
  should fail gently when permission is missing.
- If you change the trigger chord, update both the engine and the menu copy.

## Persistence

- Settings live in `UserDefaults`.
- Learned accent ordering also lives in `UserDefaults`.
- Uppercase ordering should continue to follow the learned lowercase ranking.

## Build and test

- Debug build: `swift build`
- Tests: `swift test`
- Run locally: `./scripts/run-app.sh`
- Stop local app: `./scripts/stop-app.sh`
- Package a release app bundle: `./scripts/package-app.sh`

## Release flow

- GitHub Releases are built from tag pushes that match `v*`.
- The workflow lives in
  [release.yml](.github/workflows/release.yml).
- Packaging is done by
  [package-app.sh](scripts/package-app.sh).
- There is also a local notarization helper in
  [notarize-app.sh](scripts/notarize-app.sh), but
  the current GitHub workflow publishes unsigned-for-distribution builds unless
  Apple signing and notarization are added later.

## Guardrails

- Do not reintroduce caret positioning unless it is demonstrably reliable across
  apps.
- Keep the menu lightweight. The primary UX is the global chord, not a complex
  settings surface.
- If you add packaging resources or plist keys, keep the shell packaging script
  and the README in sync.
