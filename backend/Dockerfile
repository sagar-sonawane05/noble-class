# Build stage
FROM node:18 AS builder

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY prisma ./prisma
RUN npx prisma generate

COPY src ./src
RUN npm run build

# Production stage
FROM node:18 AS runner

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Prisma CLI is required at runtime for `migrate deploy` and seeding
RUN npm install --no-save prisma ts-node

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma/client ./node_modules/@prisma/client

# Entrypoint: run migrations + seed, then (re)start the server.
# CORS_ORIGIN is resolved at runtime so it can point at the live frontend URL.
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh

# Create persistent static uploads directory
RUN mkdir -p uploads

EXPOSE 5000

ENV PORT=5000
ENV NODE_ENV=production

ENTRYPOINT ["./docker-entrypoint.sh"]
