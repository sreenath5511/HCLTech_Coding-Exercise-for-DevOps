# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy the rest of the code
COPY . .

# Expose the port (patient: 3000, appointment: 3001)
EXPOSE 3000

# Start the service
CMD ["node", "patient-service.js"]
