#!/bin/sh
# Injects the runtime API URL into the deployed SPA before nginx starts.
# The frontend reads window.__API_URL__ (see src/services/api.ts). We create a
# small config.js that sets this global, then rewrite the placeholder string
# "__RUNTIME_API_URL__" that we inject at build time into the bundle/HTML.

set -e

API_URL="${RUNTIME_API_URL:-}"

if [ -z "$API_URL" ]; then
  echo "RUNTIME_API_URL not set; frontend will fall back to VITE_API_URL or localhost."
  exit 0
fi

echo "Configuring frontend to use API: $API_URL"

# Write the runtime config script consumed by the app.
cat > /usr/share/nginx/html/runtime-config.js <<EOF
window.__API_URL__ = "$API_URL";
EOF

# Replace the build-time placeholder injected by vite.config.ts.
# Works on the HTML entry and any hashed JS bundles that contain it.
find /usr/share/nginx/html -type f \( -name "*.html" -o -name "*.js" \) -exec \
  sed -i "s#__RUNTIME_API_URL__#${API_URL}#g" {} +
