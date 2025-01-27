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

# Watch for changes
fswatch -o "$PROJECT_ROOT/common" "$PROJECT_ROOT/superalgos" | while read
do
    echo "Change detected, rebuilding..."
    build_strategy  "$DEPLOY_MODE"
done

# Cleanup
trap "kill $LOG_PID" EXIT