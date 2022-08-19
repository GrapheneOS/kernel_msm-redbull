#!/bin/bash

set -o errexit -o pipefail

[[ $# -eq 1 ]] || exit 1

DEVICE=$1

if [[ $DEVICE != redfin && $DEVICE != bramble && $DEVICE != barbet && $DEVICE != redbull ]]; then
    echo invalid device codename
    exit 1
fi

BUILD_CONFIG=private/msm-google/build.config.redbull.vintf build/build.sh
