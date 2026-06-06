FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:20-alpine
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
