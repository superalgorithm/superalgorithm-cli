#!/bin/bash
set -e

# Default installation directory
INSTALL_DIR="$HOME/.superalgorithm"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

# Create installation directory
mkdir -p "$SCRIPTS_DIR"

# Copy scripts and utilities
cp -r scripts/* "$SCRIPTS_DIR/"

# Create main executable
cat > /usr/local/bin/superalgorithm << 'EOF'
#!/bin/bash
export PROJECT_ROOT="$(pwd)"
"$HOME/.superalgorithm/scripts/superalgorithm.sh" "$@"
EOF

# Make executable
chmod +x /usr/local/bin/superalgorithm