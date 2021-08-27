#!/bin/bash

set -o errexit -o pipefail

[[ $# -eq 1 ]] || exit 1

DEVICE=$1

if [[ $DEVICE != redfin && $DEVICE != bramble && $DEVICE != barbet ]]; then
    echo invalid device codename
    exit 1
fi

if [[ $DEVICE != redfin ]]; then
    DEVICE=bramble
fi

ROOT_DIR=$(realpath ../../..)

PATH="$ROOT_DIR/prebuilts/build-tools/linux-x86/bin:$PATH"
PATH="$ROOT_DIR/prebuilts/build-tools/path/linux-x86:$PATH"
PATH="$ROOT_DIR/kernel/prebuilts/build-tools/linux-x86/bin:$PATH"
PATH="$ROOT_DIR/prebuilts/gas/linux-x86:$PATH"
PATH="$ROOT_DIR/prebuilts/clang/host/linux-x86/clang-r383902/bin:$PATH"
PATH="$ROOT_DIR/prebuilts/misc/linux-x86/libufdt:$PATH"
export LD_LIBRARY_PATH="$ROOT_DIR/prebuilts/clang/host/linux-x86/clang-r383902/lib64:$LD_LIBRARY_PATH"
export DTC_EXT="$ROOT_DIR/kernel/prebuilts/build-tools/linux-x86/bin/dtc"
export DTC_OVERLAY_TEST_EXT="$ROOT_DIR/kernel/prebuilts/build-tools/linux-x86/bin/ufdt_apply_overlay"

export KBUILD_BUILD_VERSION=1
export KBUILD_BUILD_USER=grapheneos
export KBUILD_BUILD_HOST=grapheneos
export KBUILD_BUILD_TIMESTAMP="$(date -ud "@$(git show -s --format=%ct)")"

chrt -bp 0 $$

make \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
    ${DEVICE}_defconfig

make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_COMPAT=arm-linux-gnueabi-

cp out/arch/arm64/boot/{dtbo.img,Image.lz4} "$ROOT_DIR/device/google/${DEVICE}-kernel"
cp out/arch/arm64/boot/dts/google/qcom-base/lito.dtb "$ROOT_DIR/device/google/${DEVICE}-kernel"
