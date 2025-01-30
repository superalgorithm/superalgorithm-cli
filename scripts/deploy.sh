#!/bin/bash
set -e

source "$(dirname "$0")/utils/select_strategy.sh"
source "$(dirname "$0")/utils/merge_config.sh"
source "$(dirname "$0")/utils/docker_ops.sh"
source "$(dirname "$0")/utils/load_env.sh"

load_env true true

select_strategy

export MERGED_CONFIG=$(merge_config)
DOCKER_IMAGE=$(get_docker_image)
COMPOSE_FILE=$(generate_strategy_compose)

read -p "Do you want to upload the merged configuration? (y/n): " UPLOAD_CONFIG

echo "Copying project files..."
rsync -av --delete $PROJECT_ROOT/{base_images,common} $REMOTE_USER@$REMOTE_SERVER:/opt/trading/
rsync -av --delete --exclude 'configs' --rsync-path="mkdir -p /opt/trading/superalgos/ && rsync" $PROJECT_ROOT/superalgos/${STRATEGY_NAME}/ $REMOTE_USER@$REMOTE_SERVER:/opt/trading/superalgos/${STRATEGY_NAME}/

if [[ "$UPLOAD_CONFIG" =~ ^[Yy]$ ]]; then
    echo "Uploading merged configuration..."
    echo "$MERGED_CONFIG $STRATEGY_NAME"
    echo "$MERGED_CONFIG $REMOTE_USER@$REMOTE_SERVER:/opt/trading/superalgos/${STRATEGY_NAME}/config.yaml"
    rsync -av "$MERGED_CONFIG" $REMOTE_USER@$REMOTE_SERVER:/opt/trading/superalgos/${STRATEGY_NAME}/config.yaml
fi

echo "Setting up remote environment... $DOCKER_IMAGE"

ssh $REMOTE_USER@$REMOTE_SERVER "cd /opt/trading && \
    export STRATEGY_NAME=\"$STRATEGY_NAME\" && \
    export CONFIG_NAME\=\"$CONFIG_NAME\" && \
    export DOCKER_IMAGE=\"$DOCKER_IMAGE\" && \
    
    if docker ps -a --format '{{.Names}}' | grep -q \"^${STRATEGY_NAME}_${CONFIG_NAME}$\"; then \
        echo \"Found existing container ${STRATEGY_NAME}_${CONFIG_NAME}, removing...\" && \
        docker stop ${STRATEGY_NAME}_${CONFIG_NAME} 2>/dev/null || true && \
        docker rm ${STRATEGY_NAME}_${CONFIG_NAME} 2>/dev/null || true; \
    fi && \
    
    docker compose -f base_images/docker-compose.yml -f $COMPOSE_FILE build --no-cache ${STRATEGY_NAME}_${CONFIG_NAME} && \
    docker compose -f base_images/docker-compose.yml -f $COMPOSE_FILE up -d ${STRATEGY_NAME}_${CONFIG_NAME}"

echo "Deployment complete! Strategy ${STRATEGY_NAME}_${CONFIG_NAME} is running on $REMOTE_SERVER"