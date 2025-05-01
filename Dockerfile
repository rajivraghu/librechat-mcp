# Base image
FROM node:20-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk curl bash unzip ca-certificates libjemalloc2 \
    fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
    libatk1.0-0 libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 \
    libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils wget gnupg && \
    # Add Chrome repository and key
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Set jemalloc
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Install JBang
RUN curl -Ls https://sh.jbang.dev | bash -s - app setup

# Add JBang to PATH
ENV PATH="/root/.jbang/bin:${PATH}"

# Create app directory
RUN mkdir -p /app
WORKDIR /app

# Copy project files
COPY . .

# Install Node.js dependencies and build frontend
RUN npm install --no-audit && \
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    npm prune --production && \
    npm cache clean --force

# Expose application port
EXPOSE 3080

# Start the backend
CMD ["npm", "run", "backend"]
