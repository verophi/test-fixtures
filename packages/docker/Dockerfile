FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:24-alpine@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
