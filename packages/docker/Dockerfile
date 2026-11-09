FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:26-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
