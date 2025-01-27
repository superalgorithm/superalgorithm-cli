#!/bin/bash
set -e

# Default installation directory
INSTALL_DIR="$HOME/.superalgorithm"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
TEMP_DIR="/tmp/superalgorithm-install"

# Clone repository
echo "Downloading superalgorithm-cli..."
rm -rf "$TEMP_DIR"
git clone https://github.com/superalgorithm/superalgorithm-cli.git "$TEMP_DIR"

# Create installation directory
mkdir -p "$SCRIPTS_DIR"

# Copy scripts and utilities
cp -r "$TEMP_DIR/scripts/"* "$SCRIPTS_DIR/"

# Set execute permissions for all scripts
chmod -R +x "$SCRIPTS_DIR/"*.sh

# Create main executable
cat > /usr/local/bin/superalgorithm << 'EOF'
#!/bin/bash
export PROJECT_ROOT="$(pwd)"
"$HOME/.superalgorithm/scripts/superalgorithm.sh" "$@"
EOF

# Make executable
chmod +x /usr/local/bin/superalgorithm

# Cleanup
rm -rf "$TEMP_DIR"

echo "Superalgorithm CLI installed successfully!"