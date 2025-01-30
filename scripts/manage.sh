#!/bin/bash
set -e

source "$(dirname "$0")/utils/select_strategy.sh"
source "$(dirname "$0")/utils/select_environment.sh"
source "$(dirname "$0")/utils/select_docker_action.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/docker_ops.sh"

load_env true true

select_strategy

select_environment

select_docker_action

CONTAINER_NAME="${STRATEGY_NAME}_${CONFIG_NAME}"

case $ACTION in
    start)
        echo "Starting $CONTAINER_NAME..."
        execute_docker_command "up -d $CONTAINER_NAME"
        ;;
    stop)
        echo "Stopping $CONTAINER_NAME..."
        execute_docker_command "stop $CONTAINER_NAME"
        ;;
    restart)
        echo "Restarting $CONTAINER_NAME..."
        execute_docker_command "restart $CONTAINER_NAME"
        ;;
    logs)
        echo "Showing logs for $CONTAINER_NAME..."
        execute_docker_command "logs -f $CONTAINER_NAME"
        ;;
    status)
        echo "Status for $CONTAINER_NAME:"
        execute_docker_command "ps $CONTAINER_NAME"
        ;;
esac