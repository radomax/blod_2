# Production stage
FROM node:18-alpine AS production

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S svelte -u 1001

# Change ownership of the app directory to the nodejs user
RUN chown -R svelte:nodejs /app
USER svelte

# Expose port
EXPOSE 3023

# Start the application
CMD ["node", "build"]