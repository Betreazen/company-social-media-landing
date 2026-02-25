# ---- Stage 1: Build the Astro static site ----
FROM node:20-alpine AS build

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy source files and build
COPY . .
RUN npm run build

# ---- Stage 2: Serve with Nginx ----
FROM nginx:1.27-alpine AS production

# Update packages to fix vulnerabilities
RUN apk update && apk upgrade --no-cache

# Remove default Nginx config and static content
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf

# Copy the Astro build output to Nginx serving directory
COPY --from=build /app/dist /usr/share/nginx/html

# Copy Nginx config (HTTP-only by default for initial launch)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
