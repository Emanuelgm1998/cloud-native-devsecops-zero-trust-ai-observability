#!/bin/bash

echo "📦 Reorganizando estructura del proyecto..."

# Crear estructura base
mkdir -p devsecops-ai-platform/{api/docs,ai,tests,.github/workflows}

# Mover archivos Node.js a /api
if [ -f server.js ]; then
  mv server.js devsecops-ai-platform/api/
fi

if [ -f package.json ]; then
  mv package.json devsecops-ai-platform/api/
fi

if [ -f api/Dockerfile ]; then
  mv api/Dockerfile devsecops-ai-platform/api/Dockerfile
fi

if [ -f api/docs/swagger.json ]; then
  mv api/docs/swagger.json devsecops-ai-platform/api/docs/swagger.json
fi

# Mover archivos Python a /ai
if [ -f anomaly_detector.py ]; then
  mv anomaly_detector.py devsecops-ai-platform/ai/
fi

# Mover tests si existen
if [ -d tests ]; then
  mv tests/* devsecops-ai-platform/tests/ 2>/dev/null
fi

# Mover workflows si existen
if [ -d .github/workflows ]; then
  mv .github/workflows/* devsecops-ai-platform/.github/workflows/ 2>/dev/null
fi

echo "✅ Proyecto reordenado en 'devsecops-ai-platform/' con estructura profesional."
