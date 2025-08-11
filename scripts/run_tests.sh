#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

API_PORT="${API_PORT_HOST:-5858}"
AI_PORT="${AI_PORT_HOST:-5859}"

pass() { echo "✅ $1"; }
fail() { echo "❌ $1"; exit 1; }

# --- API ---
status_api_root=$(curl -fsS "http://localhost:${API_PORT}/" | jq -r '.status' || true)
[ "$status_api_root" = "ok" ] || fail "API / must return {status:\"ok\"}"

status_api_health=$(curl -fsS "http://localhost:${API_PORT}/health" | jq -r '.status' || true)
[ "$status_api_health" = "healthy" ] || fail "API /health must return {status:\"healthy\"}"

code_api_404=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${API_PORT}/__not_found__")
[ "$code_api_404" = "404" ] || fail "API 404 route must return 404"

pass "API OK (/, /health, 404)"

# --- AI ---
status_ai_root=$(curl -fsS "http://localhost:${AI_PORT}/" | jq -r '.status' || true)
[ "$status_ai_root" = "ok" ] || fail "AI / must return {status:\"ok\"}"

status_ai_health=$(curl -fsS "http://localhost:${AI_PORT}/health" | jq -r '.status' || true)
[ "$status_ai_health" = "healthy" ] || fail "AI /health must return {status:\"healthy\"}"

code_ai_404=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${AI_PORT}/__not_found__")
[ "$code_ai_404" = "404" ] || fail "AI 404 route must return 404"

pass "AI OK (/, /health, 404)"

# --- Docker healthchecks ---
hc_api=$(docker inspect -f '{{json .State.Health.Status}}' devsecops-ai-platform-api 2>/dev/null || echo '"unknown"')
hc_ai=$(docker inspect -f '{{json .State.Health.Status}}' devsecops-ai-platform-ai 2>/dev/null || echo '"unknown"')
[[ $hc_api == '"healthy"' ]] || fail "Docker healthcheck (API) not healthy (got: $hc_api)"
[[ $hc_ai == '"healthy"' ]] || fail "Docker healthcheck (AI) not healthy (got: $hc_ai)"

pass "Docker healthchecks OK"
echo "🎉 All tests passed."
