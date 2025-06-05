FROM node:18-alpine AS base
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY apps/web/package*.json ./
RUN npm install --only=production

# Build the app
FROM base AS builder
COPY apps/web/package*.json ./
RUN npm install
COPY apps/web .
RUN npm run build

# Production image
FROM base AS runner
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
