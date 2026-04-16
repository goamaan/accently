#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Accently"
VERSION="${ACCENTLY_VERSION:-0.1.0}"
APP_PATH="${1:-$ROOT/dist/Accently.app}"
ZIP_PATH="${2:-$ROOT/dist/$APP_NAME-$VERSION-macos.zip}"
NOTARY_PROFILE="${ACCENTLY_NOTARY_PROFILE:-}"

if [[ -z "$NOTARY_PROFILE" ]]; then
    echo "Set ACCENTLY_NOTARY_PROFILE to a notarytool keychain profile name."
    exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
    echo "Missing app bundle at $APP_PATH"
    exit 1
fi

if [[ ! -f "$ZIP_PATH" ]]; then
    echo "Missing zip archive at $ZIP_PATH"
    exit 1
fi

xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Notarized and stapled: $APP_PATH"
echo "Updated archive: $ZIP_PATH"
