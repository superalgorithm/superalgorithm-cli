#!/bin/bash
set -e

source "$(dirname "$0")/utils/docker_ops.sh"
source "$(dirname "$0")/utils/select_environment.sh"

select_environment

cleanup_all