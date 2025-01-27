#!/bin/bash
set -e

source "$(dirname "$0")/utils/env.sh"

show_menu() {
    echo "What would you like to do?"
    echo "1) Test Strategy Locally"
    echo "2) Deploy Strategy to Remote Server"
    echo "3) Manage Running Strategies"
    echo "4) Update Scripts"
    echo "q) Quit"
}

# Main loop
while true; do
    show_menu
    read -p "Select an option: " choice
    case $choice in
        1)
            $PROJECT_ROOT/scripts/test.sh
            ;;
        2)
            $PROJECT_ROOT/scripts/deploy.sh
            ;;
        3)
            $PROJECT_ROOT/scripts/manage.sh
            ;;
        4)
            $HOME/.superalgorithm/scripts/update.sh
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