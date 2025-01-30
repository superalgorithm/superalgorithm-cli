#!/bin/bash

select_environment() {
    # Skip if environment is already set
    if [ -n "$ENV_TYPE" ]; then
        case $ENV_TYPE in
            local|remote)
                return
                ;;
            *)
                echo "Error: Invalid environment '$ENV_TYPE'. Must be 'local' or 'remote'" >&2
                exit 1
                ;;
        esac
    fi

    echo "Select environment:"
    select env in "local" "remote"; do
        case $env in
            local|remote)
                export ENV_TYPE=$env
                break
                ;;
            *) echo "Invalid option. Please select 1 for local or 2 for remote.";;
        esac
    done
}