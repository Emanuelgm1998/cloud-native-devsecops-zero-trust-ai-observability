#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
API="${API_PORT_HOST:-5858}"
AI="${AI_PORT_HOST:-5859}"

# Si no responden 5858/5859, probamos 3000/5000 como fallback
try() { curl -fsS "http://localhost:$1$2" >/dev/null 2>&1; }
pick_port(){ def="$1"; alt="$2"; path="$3"; if try "$def" "$path"; then echo "$def"; elif try "$alt" "$path"; then echo "$alt"; else echo "$def"; fi; }

API_EFF="$(pick_port "$API" 3000 /health)"
AI_EFF="$(pick_port "$AI" 5000 /health)"

echo "🌐 Verificando API (:${API_EFF})…"
curl -fsS "http://localhost:${API_EFF}/" >/dev/null && echo "✅ API / OK" || { echo "❌ API / FAIL"; exit 1; }
curl -fsS "http://localhost:${API_EFF}/health" >/dev/null && echo "✅ API /health OK" || { echo "❌ API /health FAIL"; exit 1; }

echo "🧠 Verificando AI (:${AI_EFF})…"
curl -fsS "http://localhost:${AI_EFF}/" >/dev/null && echo "✅ AI / OK" || { echo "❌ AI / FAIL"; exit 1; }
curl -fsS "http://localhost:${AI_EFF}/health" >/dev/null && echo "✅ AI /health OK" || { echo "❌ AI /health FAIL"; exit 1; }

echo "🎉 Todo OK"
