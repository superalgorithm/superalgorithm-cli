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

# Check and install dependencies
install_dependencies() {
    echo "Checking dependencies..."
    
    # Check for package manager
    if command -v brew &> /dev/null; then
        # macOS
        if ! command -v fswatch &> /dev/null; then
            echo "Installing fswatch..."
            brew install fswatch
        fi
        if ! command -v yq &> /dev/null; then
            echo "Installing yq..."
            brew install yq
        fi
    elif command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        if ! command -v fswatch &> /dev/null; then
            echo "Installing fswatch..."
            sudo apt-get install -y fswatch
        fi
        if ! command -v yq &> /dev/null; then
            echo "Installing yq..."
            sudo apt-get install -y yq
        fi
    else
        echo "Warning: Could not detect package manager. Please install dependencies manually:"
        echo "- fswatch"
        echo "- yq"
    fi
}

install_dependencies

echo "Superalgorithm CLI installed successfully!"