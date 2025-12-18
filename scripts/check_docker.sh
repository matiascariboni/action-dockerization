#!/bin/bash
set -e

echo "🔍 Checking Docker installation..."

# Check if Docker is installed and accessible
if command -v docker &> /dev/null; then
    echo "✅ Docker is already installed"
    docker --version

    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        echo "✅ Docker daemon is running"
    else
        echo "⚠️  Docker is installed but daemon is not running"
        echo "🔧 Starting Docker daemon..."
        sudo systemctl start docker || true
        sudo chmod 666 /var/run/docker.sock || true

        if docker info &> /dev/null; then
            echo "✅ Docker daemon started successfully"
        else
            echo "❌ Failed to start Docker daemon"
            exit 1
        fi
    fi
else
    echo "❌ Docker not found. Installing Docker..."

    # Update package list
    sudo apt-get update -qq

    # Install Docker
    echo "📦 Installing docker.io package..."
    sudo apt-get install -y docker.io

    # Start and enable Docker service
    echo "🚀 Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Fix permissions
    sudo chmod 666 /var/run/docker.sock

    # Verify installation
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        echo "✅ Docker installed and running successfully"
        docker --version
    else
        echo "❌ Docker installation failed"
        exit 1
    fi
fi

echo "✅ Docker is ready to use"