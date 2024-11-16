# Use Node.js official image as base
FROM node:18-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and lock file
COPY package.json package-lock.json ./

# Install dependencies and cache them
RUN npm install --frozen-lockfile

# Copy application code
COPY . .

# Build the Next.js application
RUN npm run build

# Use a lightweight image for production
FROM node:18-alpine AS runner

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose the port Next.js will run on
EXPOSE 3000

# Set environment variable
ENV NODE_ENV production

# Start the Next.js application
CMD ["npm", "start"]
