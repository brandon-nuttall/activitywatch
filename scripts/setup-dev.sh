#!/bin/bash
# ActivityWatch Development Environment Setup
# This script initializes the development environment for ActivityWatch

set -e

echo "ActivityWatch Development Environment Setup"
echo "============================================"
echo ""

# Check prerequisites
check_prerequisite() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: $1 is required but not installed."
        exit 1
    fi
}

echo "Checking prerequisites..."
check_prerequisite python3
check_prerequisite cargo
check_prerequisite node

echo "✓ Python 3 found"
echo "✓ Rust toolchain found"
echo "✓ Node.js found"
echo ""

# Initialize submodules if needed
if [ ! -d "aw-core/aw_core" ]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
    echo "✓ Submodules initialized"
    echo ""
fi

# Create virtual environment if needed
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
echo "✓ Virtual environment activated"
echo ""

# Install Poetry
echo "Installing Poetry..."
pip install poetry==1.4.2
echo "✓ Poetry installed"
echo ""

# Install Python dependencies
echo "Installing Python dependencies..."
poetry install
echo "✓ Python dependencies installed"
echo ""

# Build components
echo "Building ActivityWatch components..."
make build
echo "✓ Build complete"
echo ""

echo "============================================"
echo "Setup complete! You can now run:"
echo ""
echo "  # Start the server (testing mode)"
echo "  aw-server --testing"
echo ""
echo "  # Run watchers"
echo "  aw-watcher-window --testing"
echo "  aw-watcher-afk --testing"
echo ""
echo "  # Run tests"
echo "  make test"
echo ""
echo "  # Open web UI"
echo "  # Navigate to http://localhost:5666"
echo ""
