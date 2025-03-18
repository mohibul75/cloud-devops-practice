FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN apk add --no-cache python3 make g++ \
    && yarn install  \
    && yarn cache clean


FROM node:18-alpine AS runner
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN mkdir -p /etc/todos && \
    addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app /etc/todos


ENV NODE_ENV=production \
    PORT=3000

USER nodejs

EXPOSE 3000

CMD ["node", "src/index.js"]