#!/usr/bin/env bash
set -Eeuo pipefail
echo "API /status:" && curl -s http://localhost:3000/status && echo
echo "AI  /health:" && curl -s http://localhost:5000/health && echo
echo "AI  /detect:" && curl -s -X POST http://localhost:5000/detect -H "Content-Type: application/json" -d '{"data":[1,2,3,100]}' && echo
echo "API /detect:" && curl -s -X POST http://localhost:3000/detect -H "Content-Type: application/json" -d '{"data":[1,2,3,100]}' && echo
