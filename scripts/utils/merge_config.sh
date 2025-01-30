#!/bin/bash

# merges the config.yaml from the selected docker image and the strategy configuration into the final config.yaml
merge_config() {
    DOCKER_IMAGE=$(get_docker_image)
    
    local base_config="${PROJECT_ROOT}/base_images/${DOCKER_IMAGE}/config.yaml"
    local strategy_config="${PROJECT_ROOT}/superalgos/${STRATEGY_NAME}/configs/${CONFIG_NAME}.yaml"
    local output_config="${PROJECT_ROOT}/.tmp/${STRATEGY_NAME}_${CONFIG_NAME}_merged.yaml"
    local tmp_config="${PROJECT_ROOT}/.tmp/temp_${STRATEGY_NAME}_${CONFIG_NAME}.yaml"
    
    # Create tmp directory
    mkdir -p "${PROJECT_ROOT}/.tmp"
    
    # First merge to a temporary file
    yq eval-all --unwrapScalar=false '. as $item ireduce ({}; . * $item )' "$base_config" "$strategy_config" > "$tmp_config"
    
    # Verify temp file
    if [ ! -f "$tmp_config" ] || [ ! -s "$tmp_config" ]; then
        echo "Error: Failed to create temporary config file" >&2
        exit 1
    fi
    
    # Move temp file to final location atomically
    mv "$tmp_config" "$output_config"
    
    # Final verification
    if [ ! -f "$output_config" ]; then
        echo "Error: Failed to create final config file" >&2
        exit 1
    fi
    
    echo "$output_config"
}

# gets the name of the merged config, we use this for any cleanup tasks that do not require the creation of the config
get_merged_config_name() {
    local output_config="${PROJECT_ROOT}/.tmp/${STRATEGY_NAME}_${CONFIG_NAME}_merged.yaml"
    echo "$output_config"
}

# reads the docker image from the strategy config, returns "default" if no docker_image key is present
get_docker_image() {
    local docker_image=$(yq e '.docker_image // "default"' "${PROJECT_ROOT}/superalgos/${STRATEGY_NAME}/configs/${CONFIG_NAME}.yaml")
    echo "$docker_image"
}