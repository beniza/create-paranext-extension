#!/bin/bash
# Setup script for CPE test suite
# Makes all test scripts executable and verifies environment

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Setting up CPE test suite..."
echo ""

# Make test scripts executable
echo "Making test scripts executable..."
chmod +x "$SCRIPT_DIR/test-runner.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/test-helpers.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/test-unit.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/test-integration.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/test-error-handling.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/test-validation.sh" 2>/dev/null || true

echo "✓ Test scripts configured"
echo ""

# Verify bash is available
if ! command -v bash &> /dev/null; then
    echo "✗ bash is not available"
    echo "  Install Git Bash, WSL, or another bash shell"
    exit 1
fi
echo "✓ bash is available"

# Create logs directory
mkdir -p "$SCRIPT_DIR/test-logs"
echo "✓ Log directory created"
echo ""

echo "Setup complete!"
echo ""
echo "Run tests with:"
echo "  ./tests/test-runner.sh"
echo ""
echo "Or on Windows with Git Bash:"
echo "  bash tests/test-runner.sh"
