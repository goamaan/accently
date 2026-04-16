#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BINARY="$ROOT/.build/debug/Accently"

pkill -f "$BINARY" 2>/dev/null || true
echo "Accently stopped"
