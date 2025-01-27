#!/bin/bash

# Get the absolute path to the CLI installation directory
export CLI_ROOT="$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)"

# Get the current working directory (where the CLI is called from)
export PROJECT_ROOT="$(pwd)"