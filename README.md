# Accently

Accently is a tiny macOS utility for typing French accents without breaking your
flow.

Hold a keyboard chord, tap a letter, and a floating picker appears. Tap the same
letter to move forward through accent variants, tap a different letter to move
backward, then release the chord to insert the selected character.

## What it does

- Runs in the background as a lightweight menu bar app
- Opens a floating accent picker while you hold the trigger
- Learns which accents you pick most and moves those to the front over time
- Supports lowercase and uppercase accented characters
- Lets you place the picker in the center of the screen or near the mouse

## Current trigger

- `Control + Option` for lowercase
- `Control + Option + Shift` for uppercase

Supported French base letters:

- `a` -> `à`, `â`, `æ`
- `c` -> `ç`
- `e` -> `é`, `è`, `ê`, `ë`
- `i` -> `î`, `ï`
- `o` -> `ô`, `œ`
- `u` -> `ù`, `û`, `ü`
- `y` -> `ÿ`

## Install

The simplest path is from GitHub Releases:

1. Open the [Releases page](https://github.com/goamaan/accently/releases).
2. Download the latest `Accently-<version>-macos.zip`.
3. Unzip it.
4. Move `Accently.app` to `/Applications`.
5. Open the app.
6. In System Settings, allow **Input Monitoring** for Accently.

If macOS warns on first launch, that is expected until Developer ID signing and
Apple notarization are added to the release pipeline.

## Local development

Requirements:

- macOS 13+
- Xcode with command line tools
- Swift 5.10+

Useful commands:

```bash
swift build
swift test
./scripts/run-app.sh
./scripts/stop-app.sh
```

The local runner writes logs to `/tmp/accently.log`.

## Packaging

To build a distributable `.app` bundle and zip locally:

```bash
./scripts/package-app.sh
```

That script:

- builds both `arm64` and `x86_64`
- creates a universal app binary with `lipo`
- generates an app icon
- writes the app `Info.plist`
- copies any needed Swift runtime libraries
- signs the bundle
- produces `dist/Accently.app`
- produces `dist/Accently-<version>-macos.zip`

Optional environment variables:

```bash
ACCENTLY_VERSION=0.1.0
ACCENTLY_BUILD_NUMBER=42
ACCENTLY_BUNDLE_ID=com.example.accently
ACCENTLY_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
./scripts/package-app.sh
```

## GitHub Releases

This repo includes a release workflow at
[.github/workflows/release.yml](.github/workflows/release.yml).

When you push a tag like `v0.1.1`, GitHub Actions will:

1. build the packaged app
2. zip it
3. create a checksum
4. publish or update the matching GitHub Release

Example:

```bash
git tag -a v0.1.1 -m "Accently 0.1.1"
git push origin v0.1.1
```

## Notarization

There is a local helper for notarization:

```bash
ACCENTLY_NOTARY_PROFILE=your-profile ./scripts/notarize-app.sh
```

That expects an existing `notarytool` keychain profile. The current GitHub
workflow does not notarize automatically yet.

## Project layout

```text
accently/
├── Sources/Accently/
├── Tests/AccentlyTests/
├── scripts/
├── Config/
└── .github/workflows/
```

Core files:

- [AccentlyApp.swift](Sources/Accently/AccentlyApp.swift)
- [AccentlyStore.swift](Sources/Accently/AccentlyStore.swift)
- [AccentInputEngine.swift](Sources/Accently/AccentInputEngine.swift)
- [AccentPanelController.swift](Sources/Accently/AccentPanelController.swift)
- [AccentUsageStore.swift](Sources/Accently/AccentUsageStore.swift)

## Status

This is a clean first version of the app:

- global accent picker works
- learned ordering works
- GitHub release packaging works

The next obvious upgrades are launch at login, configurable key chords, and
proper notarized public releases.
