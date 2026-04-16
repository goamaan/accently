#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BINARY="$ROOT/.build/debug/Accently"

swift build --package-path "$ROOT"
pkill -f "$BINARY" 2>/dev/null || true
"$BINARY" >/tmp/accently.log 2>&1 &

echo "Accently started"
echo "Log: /tmp/accently.log"
