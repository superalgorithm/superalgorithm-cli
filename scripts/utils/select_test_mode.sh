#!/bin/bash

select_test_mode() {
    # Skip selection if mode is already set
    if [ -n "$DEPLOYMENT_MODE" ]; then
        # Validate the provided mode
        case $DEPLOYMENT_MODE in
            backtest|live)
                return
                ;;
            *)
                echo "Error: Invalid mode '$DEPLOYMENT_MODE'. Must be 'backtest' or 'live'" >&2
                exit 1
                ;;
        esac
    fi

    echo "Select mode:"
    select mode in "backtest" "live"; do
        case $mode in
            backtest|live)
                export DEPLOYMENT_MODE=$mode
                break
                ;;
            *) echo "Invalid option. Please select 1 for backtest or 2 for live.";;
        esac
    done
}