#!/bin/bash

merge_config() {
    local base_config="${PROJECT_ROOT}/base_images/default/config.yaml"
    local strategy_config="${PROJECT_ROOT}/superalgos/${STRATEGY_NAME}/configs/${CONFIG_NAME}.yaml"
    local output_config="${PROJECT_ROOT}/.tmp/${STRATEGY_NAME}_${CONFIG_NAME}_merged.yaml"
    
    # Clean up existing merged config if it exists
    rm -rf "$output_config"
    
    # Create tmp directory if it doesn't exist
    mkdir -p "${PROJECT_ROOT}/.tmp"
    
    # Force reload by creating a new merge
    yq eval-all --unwrapScalar=false '. as $item ireduce ({}; . * $item )' "$base_config" "$strategy_config" > "$output_config"
    
    # Verify the file was created and is not empty
    if [ ! -s "$output_config" ]; then
        echo "Error: Failed to create merged config file" >&2
        exit 1
    fi
    
    echo "$output_config"
}