#!/bin/bash
set -e

source "$(dirname "$0")/utils/select_strategy.sh"
source "$(dirname "$0")/utils/docker_ops.sh"

# Select mode
echo "Select mode:"
select mode in "backtest" "live"; do
    case $mode in
        backtest|live)
            DEPLOY_MODE=$mode
            break
            ;;
        *) echo "Invalid option. Please select 1 for backtest or 2 for live.";;
    esac
done

select_strategy

cleanup_strategy

build_base_image

build_strategy "$DEPLOY_MODE"

# Cleanup
cleanup() {
    echo "Cleaning up..."
    kill $LOG_PID 2>/dev/null || true
    cleanup_strategy
    docker compose -f $PROJECT_ROOT/base_images/docker-compose.yml down
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Watch for changes
fswatch -o "$PROJECT_ROOT/common" "$PROJECT_ROOT/superalgos" | while read
do
    echo "Change detected, rebuilding..."
    build_strategy  "$DEPLOY_MODE"
done

