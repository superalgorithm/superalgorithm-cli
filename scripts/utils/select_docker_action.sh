#!/bin/bash

select_docker_action() {
    # Skip if action is already set
    if [ -n "$ACTION" ]; then
        case $ACTION in
            start|stop|restart|logs|status)
                return
                ;;
            *)
                echo "Error: Invalid action '$ACTION'. Must be one of: start, stop, restart, logs, status" >&2
                exit 1
                ;;
        esac
    fi

    echo "Select action:"
    select action in "start" "stop" "restart" "logs" "status"; do
        case $action in
            start|stop|restart|logs|status)
                export ACTION=$action
                break
                ;;
            *) echo "Invalid option. Please select a valid action.";;
        esac
    done
}