#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Accently"
EXECUTABLE_NAME="Accently"
BUNDLE_ID="${ACCENTLY_BUNDLE_ID:-com.accently.app}"
VERSION="${ACCENTLY_VERSION:-0.1.0}"
BUILD_NUMBER="${ACCENTLY_BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
DIST_DIR="$ROOT/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"
ZIP_PATH="$DIST_DIR/$APP_NAME-$VERSION-macos.zip"
ARM_BUILD_DIR="$ROOT/.build/package-arm64"
X86_BUILD_DIR="$ROOT/.build/package-x86_64"
ARM_BINARY="$ARM_BUILD_DIR/arm64-apple-macosx/release/$EXECUTABLE_NAME"
X86_BINARY="$X86_BUILD_DIR/x86_64-apple-macosx/release/$EXECUTABLE_NAME"
UNIVERSAL_BINARY="$MACOS_DIR/$EXECUTABLE_NAME"
PLIST_TEMPLATE="$ROOT/Config/Info.plist.template"
PLIST_PATH="$CONTENTS_DIR/Info.plist"
ICONSET_DIR="$RESOURCES_DIR/AppIcon.iconset"
ICON_PATH="$RESOURCES_DIR/AppIcon.icns"

rm -rf "$APP_DIR" "$ZIP_PATH"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$FRAMEWORKS_DIR"

swift build --package-path "$ROOT" -c release --arch arm64 --scratch-path "$ARM_BUILD_DIR"
swift build --package-path "$ROOT" -c release --arch x86_64 --scratch-path "$X86_BUILD_DIR"

lipo -create "$ARM_BINARY" "$X86_BINARY" -output "$UNIVERSAL_BINARY"
chmod +x "$UNIVERSAL_BINARY"

swift "$ROOT/scripts/generate-app-icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$ICON_PATH"
rm -rf "$ICONSET_DIR"

sed \
    -e "s|__APP_NAME__|$APP_NAME|g" \
    -e "s|__EXECUTABLE__|$EXECUTABLE_NAME|g" \
    -e "s|__BUNDLE_ID__|$BUNDLE_ID|g" \
    -e "s|__VERSION__|$VERSION|g" \
    -e "s|__BUILD__|$BUILD_NUMBER|g" \
    "$PLIST_TEMPLATE" > "$PLIST_PATH"

xcrun swift-stdlib-tool \
    --copy \
    --platform macosx \
    --scan-executable "$UNIVERSAL_BINARY" \
    --unsigned-destination "$FRAMEWORKS_DIR"

if [[ -z "$(find "$FRAMEWORKS_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    rmdir "$FRAMEWORKS_DIR"
fi

if [[ -n "${ACCENTLY_SIGN_IDENTITY:-}" ]]; then
    codesign --force --deep --options runtime --sign "$ACCENTLY_SIGN_IDENTITY" "$APP_DIR"
else
    codesign --force --deep --sign - "$APP_DIR"
fi

codesign --verify --deep --strict "$APP_DIR"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"

echo "App bundle: $APP_DIR"
echo "Zip archive: $ZIP_PATH"
