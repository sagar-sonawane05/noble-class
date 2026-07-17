# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build

# Production stage (using Nginx to serve the static React SPA)
FROM nginx:1.25-alpine AS runner

# Copy built static assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Runtime API URL injection:
# The frontend resolves the backend URL from `window.__API_URL__` at runtime.
# We ship a small config script and substitute its value from the RUNTIME_API_URL
# environment variable using nginx's sub_filter, so the SPA can talk to the
# correct backend without needing a rebuild.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY runtime-env.sh /docker-entrypoint.d/40-runtime-env.sh
RUN chmod +x /docker-entrypoint.d/40-runtime-env.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
