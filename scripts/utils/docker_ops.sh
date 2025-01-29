#!/bin/bash

source "$(dirname "$0")/utils/merge_config.sh"

# Build and deploy strategy locally
build_strategy() {
    
    

    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    # Check if deployment mode is set
    if [ -z "$DEPLOYMENT_MODE" ]; then
        echo "Error: Deployment mode not set. Run select_deploy_mode first." >&2
        exit 1
    fi
    
    # Set environment variables
    export STRATEGY_CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"
    export MERGED_CONFIG=$(merge_config)
    # export DOCKER_IMAGE=$(yq e '.docker_image // "default"' "$MERGED_CONFIG")
    export DOCKER_IMAGE=$(get_docker_image)

    
    
    echo "Building strategy: $STRATEGY_NAME with config: $CONFIG_NAME in $DEPLOYMENT_MODE mode using $DOCKER_IMAGE"
    
    # Clean up existing dev container
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml down strategy_dev
    
    # Start container and stream logs in foreground
    # docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml build trading-base
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml build strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml up -d strategy_dev
    
    # Wait for container to finish or user interrupt
    echo "Streaming logs (Ctrl+C to stop)..."
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml logs -f strategy_dev || true
    
    # Check if container is still running (live mode) or exited (backtest)
    if [ "$env_mode" = "backtest" ]; then
        cleanup_strategy
    fi
}

# Clean up strategy container and images
cleanup_strategy() {
    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    export STRATEGY_CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"
    export MERGED_CONFIG=$(get_merged_config_name)
    
    echo "Cleaning up strategy: ${STRATEGY_CONTAINER_NAME}"
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml stop strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml rm -f strategy_dev
    
    # Remove any dangling images
    docker image prune -f
}

# Generate a docker-compose file for the selected strategy by:
# 1. Creating a unique compose file for each strategy+config combination
# 2. Applying environment variables to the template file
# 3. Using the specified docker image from config or falling back to default

generate_strategy_compose() {
    local compose_file="base_images/docker-compose.${STRATEGY_NAME}_${CONFIG_NAME}.yml"
    
    export DOCKER_IMAGE=$(yq e '.docker_image // "default"' "$MERGED_CONFIG")
    
    envsubst < "base_images/docker-compose.strategy.template" > "$compose_file"
    
    echo "$compose_file"
}