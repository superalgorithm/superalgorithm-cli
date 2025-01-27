#!/bin/bash
set -e

source "${PROJECT_ROOT}/scripts/utils/select_strategy.sh"
source "${PROJECT_ROOT}/scripts/utils/merge_config.sh"


# Load or create deployment configuration
ENV_FILE="${PROJECT_ROOT}/.env"
if [ -f "$ENV_FILE" ]; then
    # Read each line and export variables
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ $key =~ ^[[:space:]]*$ ]] || [[ $key =~ ^# ]] && continue
        # Remove any surrounding quotes from value
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')
        export "$key=$value"
    done < "$ENV_FILE"
else
    read -p "Enter remote server address: " REMOTE_SERVER
    read -p "Enter remote server username: " REMOTE_USER
    
    # Save to .env file
    echo "REMOTE_SERVER=$REMOTE_SERVER" > "$ENV_FILE"
    echo "REMOTE_USER=$REMOTE_USER" >> "$ENV_FILE"
fi

eval "$(ssh-agent -s)"
ssh-add

select_strategy

export MERGED_CONFIG=$(merge_config)

read -p "Do you want to upload the merged configuration? (y/n): " UPLOAD_CONFIG

echo "Copying project files..."
rsync -av --delete $PROJECT_ROOT/{base_images,common} $REMOTE_USER@$REMOTE_SERVER:/opt/trading/
rsync -av --delete --exclude 'configs' --rsync-path="mkdir -p /opt/trading/superalgos/ && rsync" $PROJECT_ROOT/superalgos/${STRATEGY_NAME}/ $REMOTE_USER@$REMOTE_SERVER:/opt/trading/superalgos/${STRATEGY_NAME}/

if [[ "$UPLOAD_CONFIG" =~ ^[Yy]$ ]]; then
    echo "Uploading merged configuration..."
    echo "$MERGED_CONFIG $STRATEGY_NAME"
    rsync -av "$MERGED_CONFIG" $REMOTE_USER@$REMOTE_SERVER:/opt/trading/superalgos/${STRATEGY_NAME}/config.yaml
fi

echo "Setting up remote environment..."
ssh $REMOTE_USER@$REMOTE_SERVER "cd /opt/trading && \
    export STRATEGY_NAME=\"$STRATEGY_NAME\" && \
    export STRATEGY_CONTAINER_NAME=\"${STRATEGY_NAME}_${CONFIG_NAME}\" && \
    export MERGED_CONFIG=\"$MERGED_CONFIG\" && \
    docker compose -f base_images/docker-compose.yml stop strategy || true && \
    docker compose -f base_images/docker-compose.yml rm -f strategy || true && \
    docker compose -f base_images/docker-compose.yml build trading-base && \
    docker compose -f base_images/docker-compose.yml up -d strategy && \
    docker compose -f base_images/docker-compose.yml logs -f strategy
    "

echo "Deployment complete! Strategy ${STRATEGY_NAME}_${CONFIG_NAME} is running on $REMOTE_SERVER"