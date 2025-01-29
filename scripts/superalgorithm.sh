#!/bin/bash
set -e

source "$(dirname "$0")/utils/env.sh"

show_menu() {
    echo "What would you like to do?"
    echo "1) Test strategy locally"
    echo "2) Deploy to remote server"
    echo "3) Manage running strategies"
    echo "4) Initialize new project"
    echo "5) Update superalgorithm cli"
    echo "6) Uninstall superalgorithm cli"
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
            $HOME/.superalgorithm/scripts/init.sh
            ;;
        5)
            $HOME/.superalgorithm/scripts/update.sh
            ;;
        6)
            read -p "Are you sure you want to uninstall? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -rf "$HOME/.superalgorithm"
                sudo rm /usr/local/bin/superalgorithm
                echo "Superalgorithm CLI uninstalled successfully!"
                exit 0
            fi
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