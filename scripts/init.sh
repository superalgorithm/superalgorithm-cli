#!/bin/bash
set -e

TEMPLATE_DIR="$HOME/.superalgorithm/template"
TARGET_DIR="$(pwd)"

# Clone template if not exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Downloading project template..."
    git clone https://github.com/superalgorithm/superalgorithm-cli.git "$TEMPLATE_DIR"
fi

# List directories to copy
DIRS_TO_COPY=(
    "base_images"
    "common"
    "superalgos"
    "tests"
)

FILES_TO_COPY=(
    ".dockerignore"
    ".gitignore"
)

# Ask for confirmation
echo "This will initialize a new project in: $TARGET_DIR"
echo "The following will be created:"
for dir in "${DIRS_TO_COPY[@]}"; do
    echo "- $dir/"
done
for file in "${FILES_TO_COPY[@]}"; do
    echo "- $file"
done

read -p "Continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Initialization cancelled."
    exit 0
fi

# Copy directories
for dir in "${DIRS_TO_COPY[@]}"; do
    if [ -d "$TARGET_DIR/$dir" ]; then
        echo "Directory $dir already exists, merging..."
        cp -rn "$TEMPLATE_DIR/$dir/"* "$TARGET_DIR/$dir/"
    else
        echo "Creating $dir..."
        cp -r "$TEMPLATE_DIR/$dir" "$TARGET_DIR/"
    fi
done

# Copy files
for file in "${FILES_TO_COPY[@]}"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "File $file already exists, skipping..."
    else
        echo "Creating $file..."
        cp "$TEMPLATE_DIR/$file" "$TARGET_DIR/"
    fi
done

echo "Project initialized successfully!"