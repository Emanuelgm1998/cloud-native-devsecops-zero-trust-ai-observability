#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

API_PORT="${API_PORT_HOST:-5858}"
AI_PORT="${AI_PORT_HOST:-5859}"

echo "🌐 Verificando API Node.js…"
curl -fsS "http://localhost:${API_PORT}/" | (jq . 2>/dev/null || cat) >/dev/null && echo "✅ API / OK"
curl -fsS "http://localhost:${API_PORT}/health" | (jq . 2>/dev/null || cat) >/dev/null && echo "✅ API /health OK"

echo "🧠 Verificando Flask AI…"
curl -fsS "http://localhost:${AI_PORT}/" | (jq . 2>/dev/null || cat) >/dev/null && echo "✅ AI / OK"
curl -fsS "http://localhost:${AI_PORT}/health" | (jq . 2>/dev/null || cat) >/dev/null && echo "✅ AI /health OK"

echo "🎉 Todo OK"
