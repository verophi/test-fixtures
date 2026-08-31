FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:24-alpine@sha256:e67514e5d0f6c46656005e1b693b2ec9d52e80b641307de684d4a015ba7a4eaf
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
