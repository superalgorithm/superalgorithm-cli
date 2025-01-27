#!/bin/bash
set -e

source "${PROJECT_ROOT}/scripts/utils/select_strategy.sh"

# Load deployment configuration for remote access
ENV_FILE="${PROJECT_ROOT}/.env"
if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        [[ $key =~ ^[[:space:]]*$ ]] || [[ $key =~ ^# ]] && continue
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')
        export "$key=$value"
    done < "$ENV_FILE"
fi

# Select environment
echo "Select environment:"
select ENV_TYPE in "local" "remote"; do
    case $ENV_TYPE in
        local|remote)
            break
            ;;
        *) echo "Invalid option. Please select 1 for local or 2 for remote.";;
    esac
done

# Select strategy
select_strategy

# Select action
echo "Select action:"
select ACTION in "start" "stop" "restart" "logs" "status"; do
    case $ACTION in
        start|stop|restart|logs|status)
            break
            ;;
        *) echo "Invalid option. Please select a valid action.";;
    esac
done

CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"

# Execute command based on environment
execute_docker_command() {
    local cmd=$1
    if [ "$ENV_TYPE" = "local" ]; then
        docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml $cmd
    else
        if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_SERVER" ]; then
            echo "Error: Remote credentials not found in .env file"
            exit 1
        fi
        ssh $REMOTE_USER@$REMOTE_SERVER "cd /opt/trading && \
            export STRATEGY_NAME=\"$STRATEGY_NAME\" && \
            export STRATEGY_CONTAINER_NAME=\"$CONTAINER_NAME\" && \
            docker compose -f base_images/docker-compose.yml $cmd"
    fi
}

# Execute the selected action
case $ACTION in
    start)
        echo "Starting $CONTAINER_NAME..."
        execute_docker_command "up -d strategy"
        ;;
    stop)
        echo "Stopping $CONTAINER_NAME..."
        execute_docker_command "stop strategy"
        ;;
    restart)
        echo "Restarting $CONTAINER_NAME..."
        execute_docker_command "restart strategy"
        ;;
    logs)
        echo "Showing logs for $CONTAINER_NAME..."
        execute_docker_command "logs -f strategy"
        ;;
    status)
        echo "Status for $CONTAINER_NAME:"
        execute_docker_command "ps strategy"
        ;;
esac