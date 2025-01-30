#!/bin/bash

# loads environment variables from .env or creates it if mising
load_env() {
    local create_if_missing=${1:-false}
    local init_ssh=${2:-false}
    ENV_FILE="${PROJECT_ROOT}/.env"

    if [ -f "$ENV_FILE" ]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^[[:space:]]*$ ]] || [[ $key =~ ^# ]] && continue
            value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')
            export "$key=$value"
        done < "$ENV_FILE"
    elif [ "$create_if_missing" = true ]; then
        read -p "Enter remote server address: " REMOTE_SERVER
        read -p "Enter remote server username: " REMOTE_USER
        
        echo "REMOTE_SERVER=$REMOTE_SERVER" > "$ENV_FILE"
        echo "REMOTE_USER=$REMOTE_USER" >> "$ENV_FILE"
        
        export REMOTE_SERVER
        export REMOTE_USER
    fi

    # Initialize SSH agent if requested
    if [ "$init_ssh" = true ]; then
        eval "$(ssh-agent -s)" >/dev/null
        ssh-add 2>/dev/null
    fi
}