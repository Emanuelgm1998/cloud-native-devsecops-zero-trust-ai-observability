#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stop_pid(){
  local f="$1"
  [ -f "$f" ] || return 0
  local pid; pid="$(cat "$f" || true)"
  [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null && kill "$pid" || true
  sleep 1; kill -9 "${pid:-999999}" 2>/dev/null || true
  rm -f "$f"
}
stop_pid "$ROOT/api.pid"
stop_pid "$ROOT/ai.pid"
echo "🛑 Servicios detenidos."
