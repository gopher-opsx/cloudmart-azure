FROM node:22-alpine AS build
WORKDIR /app
COPY apps/storefront/package.json apps/storefront/package-lock.json ./
RUN npm ci
COPY apps/storefront/ .
RUN npm run build
FROM nginx:1.29-alpine
COPY apps/storefront/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/storefront/browser /usr/share/nginx/html
EXPOSE 80
