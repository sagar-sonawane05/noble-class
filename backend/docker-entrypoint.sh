#!/bin/sh
set -e

# Apply database migrations
echo "Running Prisma migrations..."
npx prisma migrate deploy || echo "Migration deploy failed (continuing)"

# Seed the database (best-effort; skip if already seeded / no seed file)
if [ -f prisma/seed.js ] || [ -f prisma/seed.ts ]; then
  echo "Seeding database..."
  npm run db:seed || echo "Seeding failed or already seeded (continuing)"
fi

# Start the API server
echo "Starting backend server..."
exec node dist/server.js
