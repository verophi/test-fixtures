FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:26-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
