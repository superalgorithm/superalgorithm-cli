#!/bin/bash

select_deploy_mode() {

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