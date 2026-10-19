FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:24-alpine@sha256:44fce696f38ba8c987c4db89954051000bbd05ffd8d8659ba15ed4a8602e937f
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
