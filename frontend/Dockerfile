FROM node:20.18-alpine AS builder

# Update system packages to fix vulnerabilities
RUN apk update && apk upgrade --no-cache

WORKDIR /app

# Copy package files
COPY frontend/package*.json ./

# Install dependencies
# Use npm install to generate package-lock.json if it doesn't exist
RUN npm install --prefer-offline --no-audit

# Copy source code
COPY frontend/ .

# Copy config files for build
COPY config/ /app/config/

# Build the application
RUN npm run build

# Production stage
FROM node:20.18-alpine

# Update system packages to fix vulnerabilities
RUN apk update && apk upgrade --no-cache

WORKDIR /app

# Copy built files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# No need to install again, copy from builder

# Expose port
EXPOSE 4321

# Start the application
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4321"]
