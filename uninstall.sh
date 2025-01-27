#!/bin/bash
set -e

echo "Uninstalling Superalgorithm CLI..."

# Remove installation directory
if [ -d "$HOME/.superalgorithm" ]; then
    rm -rf "$HOME/.superalgorithm"
    echo "Removed installation directory"
fi

# Remove executable
if [ -f "/usr/local/bin/superalgorithm" ]; then
    sudo rm /usr/local/bin/superalgorithm
    echo "Removed executable"
fi

echo "Superalgorithm CLI uninstalled successfully!"