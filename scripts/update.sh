#!/bin/bash
set -e

REPO_URL="https://github.com/superalgorithm/superalgorithm-cli.git"
TEMP_DIR="/tmp/superalgorithm-update"
INSTALL_DIR="$HOME/.superalgorithm"

# Clone latest version
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR"

# Update scripts
cp -r "$TEMP_DIR/scripts/"* "$INSTALL_DIR/scripts/"

# Set execute permissions for all scripts
chmod -R +x "$INSTALL_DIR/scripts/"*.sh

# Cleanup
rm -rf "$TEMP_DIR"

echo "Superalgorithm scripts updated successfully!"
echo "Restarting CLI to apply updates..."
echo "Please run 'superalgorithm' again."

# Force exit the entire CLI
kill -9 $$ || true