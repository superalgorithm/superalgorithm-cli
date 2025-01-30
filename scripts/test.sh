#!/bin/bash
set -e

source "$(dirname "$0")/utils/select_strategy.sh"
source "$(dirname "$0")/utils/select_test_mode.sh"
source "$(dirname "$0")/utils/docker_ops.sh"

select_test_mode

select_strategy

cleanup_strategy

build_strategy

trap cleanup_strategy SIGINT SIGTERM EXIT

