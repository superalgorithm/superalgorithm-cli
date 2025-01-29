#!/bin/bash

merge_config() {
    
    DOCKER_IMAGE=$(get_docker_image)
    
    local base_config="${PROJECT_ROOT}/base_images/${DOCKER_IMAGE}/config.yaml"
    # Fallback to default if custom base config doesn't exist
    if [ ! -f "$base_config" ]; then
        base_config="${PROJECT_ROOT}/base_images/default/config.yaml"
    fi
    
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

    # echo "Waiting for config file to be ready..."
    # sleep 4
    # if [ ! -f "$MERGED_CONFIG" ]; then
    #     echo "Error: Config file not found at $MERGED_CONFIG" >&2
    #     exit 1
    # fi
    
    echo "$output_config"
}

# gets the name of the merged config, we use this for any cleanup tasks that do not require the creation of the config
get_merged_config_name() {
    local output_config="${PROJECT_ROOT}/.tmp/${STRATEGY_NAME}_${CONFIG_NAME}_merged.yaml"
    echo "$output_config"
}

get_docker_image() {
    local docker_image=$(yq e '.docker_image // "default"' "${PROJECT_ROOT}/superalgos/${STRATEGY_NAME}/configs/${CONFIG_NAME}.yaml")
    echo "$docker_image"
}