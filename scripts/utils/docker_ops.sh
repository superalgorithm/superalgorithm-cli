#!/bin/bash

source "$(dirname "$0")/utils/merge_config.sh"
source "$(dirname "$0")/utils/load_env.sh"

# Builds and deploys strategy on the local docker host
build_strategy() {
    
    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    # Check if deployment mode is set
    if [ -z "$DEPLOYMENT_MODE" ]; then
        echo "Error: Deployment mode not set. Run select_test_mode first." >&2
        exit 1
    fi
    
    # Set environment variables
    export MERGED_CONFIG=$(merge_config)
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

# Cleans up local strategy container and images
cleanup_strategy() {
    # Check if strategy is selected
    if [ -z "$STRATEGY_NAME" ] || [ -z "$CONFIG_NAME" ]; then
        echo "Error: Strategy not selected. Run select_strategy first." >&2
        exit 1
    fi
    
    export MERGED_CONFIG=$(get_merged_config_name)
    
    echo "Cleaning up strategy: ${STRATEGY_NAME}_${CONFIG_NAME}"
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml stop strategy_dev
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml rm -f strategy_dev
    
    # Remove any dangling images
    docker image prune -f
}

# Generates the docker-compose file for the selected strategy from the docker-compose.strategy.template.
generate_strategy_compose() {
    local compose_file="base_images/docker-compose.${STRATEGY_NAME}_${CONFIG_NAME}.yml"
    
    export DOCKER_IMAGE=$(yq e '.docker_image // "default"' "$MERGED_CONFIG")
    
    envsubst < "base_images/docker-compose.strategy.template" > "$compose_file"
    
    echo "$compose_file"
}

# Execute command based on environment
execute_docker_command() {
    local cmd=$1
    COMPOSE_FILE="base_images/docker-compose.${STRATEGY_NAME}_${CONFIG_NAME}.yml"
    
    if [ "$ENV_TYPE" = "local" ]; then
        docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml -f $PROJECT_ROOT/$COMPOSE_FILE $cmd
    else
        if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_SERVER" ]; then
            echo "Error: Remote credentials not found in .env file"
            exit 1
        fi
        ssh $REMOTE_USER@$REMOTE_SERVER "cd /opt/trading && \
            export STRATEGY_NAME=\"$STRATEGY_NAME\" && \
            docker compose -f base_images/docker-compose.yml -f $COMPOSE_FILE $cmd"
    fi
}

cleanup_all() {
    echo "WARNING: This will remove all stopped containers, unused images, and build cache."
    read -p "Are you sure you want to proceed? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        return
    fi
    
    echo "Cleaning up containers and images..."
    
    if [ "$ENV_TYPE" = "local" ]; then
        # Clean local docker
        docker container prune -f
        docker image prune -af
        docker builder prune -f
    else

        load_env true true

        if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_SERVER" ]; then
            echo "Error: Remote credentials not found in .env file"
            exit 1
        fi
        # Clean remote docker
        ssh $REMOTE_USER@$REMOTE_SERVER "
            echo 'Cleaning up remote containers and images...' && \
            docker container prune -f && \
            docker image prune -af && \
            docker builder prune -f"
    fi
    
    echo "Cleanup complete!"
}