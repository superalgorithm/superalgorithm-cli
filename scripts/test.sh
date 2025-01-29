#!/bin/bash
set -e

source "$(dirname "$0")/utils/select_strategy.sh"
source "$(dirname "$0")/utils/select_deploy_mode.sh"
source "$(dirname "$0")/utils/docker_ops.sh"

select_deploy_mode

echo $DEPLOYMENT_MODE

select_strategy

cleanup_strategy

build_strategy

# Handle cleanup based on mode
if [ "$DEPLOYMENT_MODE" = "live" ]; then
    trap cleanup_strategy SIGINT SIGTERM EXIT
fi
