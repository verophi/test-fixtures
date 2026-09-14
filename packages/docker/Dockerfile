FROM nginx:1.24-alpine AS web
WORKDIR /usr/share/nginx/html

FROM node:24-alpine@sha256:50c8e8ca1d27439048670df5883f32d57cf81cff6233222c893fd0d9884cbd81
WORKDIR /app
COPY . .
CMD ["node", "index.js"]
