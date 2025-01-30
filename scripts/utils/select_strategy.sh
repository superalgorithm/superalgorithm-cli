#!/bin/bash

select_strategy() {
    local strategies_dir="./superalgos"
    
    # Skip if both strategy and config are already set
    if [ -n "$STRATEGY_NAME" ] && [ -n "$CONFIG_NAME" ]; then
        # Validate strategy exists
        if [ ! -d "$strategies_dir/$STRATEGY_NAME" ]; then
            echo "Error: Strategy '$STRATEGY_NAME' not found" >&2
            exit 1
        fi
        # Validate config exists
        if [ ! -f "$strategies_dir/$STRATEGY_NAME/configs/${CONFIG_NAME}.yaml" ]; then
            echo "Error: Config '${CONFIG_NAME}.yaml' not found for strategy '$STRATEGY_NAME'" >&2
            exit 1
        fi
        return
    fi

    echo "Available strategies:"
    local strategies=($(ls $strategies_dir))
    
    if [ ${#strategies[@]} -eq 0 ]; then
        echo "No strategies found in $strategies_dir"
        exit 1
    fi
    
    select strategy in "${strategies[@]}"; do
        if [ -n "$strategy" ]; then
            export STRATEGY_NAME=$strategy
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    
    echo "Available configs for $STRATEGY_NAME:"
    local configs=($(ls $strategies_dir/$STRATEGY_NAME/configs))
    
    if [ ${#configs[@]} -eq 0 ]; then
        echo "No configs found for $STRATEGY_NAME/configs"
        exit 1
    fi
    
    select config in "${configs[@]}"; do
        if [ -n "$config" ]; then
            export CONFIG_NAME=${config%.*}  # Remove file extension
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}