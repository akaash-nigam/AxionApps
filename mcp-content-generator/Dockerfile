# Multi-stage build for smaller image size
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and source code FIRST
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src

# Install dependencies (this will trigger prepare script and build)
RUN npm install --legacy-peer-deps

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only (ignore scripts to avoid prepare hook)
RUN npm install --only=production --legacy-peer-deps --ignore-scripts

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Create directory for generated files
RUN mkdir -p /app/generated && chmod 777 /app/generated

# Set environment variable defaults
ENV OUTPUT_DIR=/app/generated
ENV NODE_ENV=production

# Expose port (not needed for stdio but good practice)
EXPOSE 3000

# Run the MCP server
CMD ["node", "dist/index.js"]
