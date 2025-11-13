#!/bin/bash

# deploy.sh - Automates Docker setup and deployment for multiple containers

echo "Starting deployment..."

# 1. Check if Docker and docker-compose are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed."
    exit 1
fi

echo "Docker and docker-compose are installed."

# 2. Build Docker images
echo "Building Docker images..."
docker-compose build
if [ $? -ne 0 ]; then
    echo "Error: Docker image build failed."
    exit 1
fi

# 3. Start all containers
echo "Starting containers..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Error: Failed to start containers."
    exit 1
fi

# 4. Wait a few seconds for containers to initialize
sleep 5

# 5. Get list of all service names from docker-compose.yml
SERVICES=$(docker-compose config --services)

# 6. Check if each container is running
echo "Checking container status..."
ALL_RUNNING=true

for SERVICE in $SERVICES; do
    CONTAINER_ID=$(docker ps --filter "name=${SERVICE}" --filter "status=running" -q)
    if [ -n "$CONTAINER_ID" ]; then
        echo "✅ $SERVICE is running."
    else
        echo "❌ $SERVICE is NOT running."
        ALL_RUNNING=false
    fi
done

# 7. Final status
if [ "$ALL_RUNNING" = true ]; then
    echo "All containers are running successfully!"
else
    echo "Some containers failed to start."
    docker-compose ps
    exit 1
fi
