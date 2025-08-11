FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --no-audit --no-fund
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
