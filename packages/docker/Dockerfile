FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:24-alpine@sha256:f70403e87646dc51b45295f4b8b70cdad0b63d2297c4c9899119b03f7af7a6b3
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
