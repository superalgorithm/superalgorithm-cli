#!/bin/bash

source "$(dirname "$0")/utils/merge_config.sh"


# Build base image
build_base_image() {
    echo "Building base trading image..."
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml build trading-base
    echo "Base image built successfully!"
}

# Build and deploy strategy
build_strategy() {
    local env_mode=${1:-"live"}
    
    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    # Set environment variables
    export DEPLOYMENT_MODE=$env_mode
    export STRATEGY_CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"
    export MERGED_CONFIG=$(merge_config)
    
    echo "Building strategy: $STRATEGY_NAME with config: $CONFIG_NAME in $env_mode mode"
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml build strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml up -d --force-recreate strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml logs -f --tail=0 strategy_dev &
    LOG_PID=$!
}

# Clean up strategy container and images
cleanup_strategy() {
    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    export STRATEGY_CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"
    export MERGED_CONFIG=$(merge_config)
    
    echo "Cleaning up strategy: ${STRATEGY_CONTAINER_NAME}"
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml stop strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml rm -f strategy_dev
    
    # Remove any dangling images
    docker image prune -f
}