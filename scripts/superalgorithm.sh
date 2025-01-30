#!/bin/bash
set -e

source "$(dirname "$0")/utils/env.sh"

usage() {
    echo "Usage:"
    echo "  superalgorithm test <strategy> <config> [--mode live|backtest]"
    echo "  superalgorithm deploy <strategy> <config> [--upload-config]"
    echo "  superalgorithm manage <strategy> <config> <local|remote> <start|stop|restart|logs|status>"
    echo "  superalgorithm cleanup <local|remote>"
    echo "  superalgorithm init"
    echo "  superalgorithm update"
    echo "  superalgorithm uninstall"
    echo "  superalgorithm --help"
}

# If no arguments, show interactive menu
if [ $# -eq 0 ]; then
    show_menu() {
        echo "What would you like to do?"
        echo "1) Test strategy locally"
        echo "2) Deploy to remote server"
        echo "3) Manage running strategies"
        echo "4) Cleanup docker resources"
        echo "5) Initialize new project"
        echo "6) Update superalgorithm cli"
        echo "7) Uninstall superalgorithm cli"
        echo "8) Help"
        echo "q) Quit"
    }

    # Main loop
    while true; do
        
        trap "exit 0" TERM
        
        show_menu
        
        read -p "Select an option: " choice
        
        case $choice in
            1)
                $CLI_ROOT/scripts/test.sh
                ;;
            2)
                $CLI_ROOT/scripts/deploy.sh
                ;;
            3)
                $CLI_ROOT/scripts/manage.sh
                ;;
            4)
                $CLI_ROOT/scripts/cleanup.sh
                ;;
            5)
                $HOME/.superalgorithm/scripts/init.sh
                ;;
            6)
                $HOME/.superalgorithm/scripts/update.sh
                ;;
            7)
                read -p "Are you sure you want to uninstall? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    rm -rf "$HOME/.superalgorithm"
                    sudo rm /usr/local/bin/superalgorithm
                    echo "Superalgorithm CLI uninstalled successfully!"
                    exit 0
                fi
                ;;
            8)
                usage
                ;;
            q)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
else
    case "$1" in
        test)
            if [ $# -lt 3 ]; then
                usage
                exit 1
            fi
            export STRATEGY_NAME="$2"
            export CONFIG_NAME="$3"
            export DEPLOYMENT_MODE="live"  # default
            shift 3
            while [ $# -gt 0 ]; do
                case "$1" in
                    --mode)
                        export DEPLOYMENT_MODE="$2"
                        shift 2
                        ;;
                    *)
                        usage
                        exit 1
                        ;;
                esac
            done
            $CLI_ROOT/scripts/test.sh
            ;;
        deploy)
            if [ $# -lt 3 ]; then
                usage
                exit 1
            fi
            export STRATEGY_NAME="$2"
            export CONFIG_NAME="$3"
            export UPLOAD_CONFIG="n"
            shift 3
            while [ $# -gt 0 ]; do
                case "$1" in
                    --upload-config)
                        export UPLOAD_CONFIG="y"
                        shift
                        ;;
                    *)
                        usage
                        exit 1
                        ;;
                esac
            done
            $CLI_ROOT/scripts/deploy.sh
            ;;
        manage)
            if [ $# -ne 5 ]; then
                usage
                exit 1
            fi
            export STRATEGY_NAME="$2"
            export CONFIG_NAME="$3"
            export ENV_TYPE="$4"
            export ACTION="$5"
            # Validate environment type
            case "$ENV_TYPE" in
                local|remote)
                    ;;
                *)
                    echo "Error: Environment must be 'local' or 'remote'" >&2
                    exit 1
                    ;;
            esac
            $CLI_ROOT/scripts/manage.sh
            ;;
        init|update|uninstall)
            $CLI_ROOT/scripts/"$1".sh
            ;;
        --help)
            usage
            exit 0
            ;;
        cleanup)
            if [ $# -ne 2 ]; then
                usage
                exit 1
            fi
            export ENV_TYPE="$2"
            # Validate environment type
            case "$ENV_TYPE" in
                local|remote)
                    ;;
                *)
                    echo "Error: Environment must be 'local' or 'remote'" >&2
                    exit 1
                    ;;
            esac
            $CLI_ROOT/scripts/cleanup.sh
            ;;
        *)
            usage
            exit 1
            ;;
    esac
fi