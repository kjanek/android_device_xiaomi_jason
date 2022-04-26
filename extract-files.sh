#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib/libmmcamera2_stats_modules.so)
            "${PATCHELF}" --remove-needed "libandroid.so" "${2}"
            "${PATCHELF}" --remove-needed "libgui.so" "${2}"
            ;;
        vendor/lib/libmmcamera_jason_s5k3p8sp_sunny.so)
            sed -i 's/\x1e\x40\x9a\x99\x99\x99\x99\x99\x3b\x40\x10/\x1e\x40\x9a\x99\x99\x99\x99\x99\x3b\x40\x01/' "${2}"
            ;;
        vendor/lib/libmmcamera_ppeiscore.so)
            "${PATCHELF}" --remove-needed "libgui.so" "${2}"
            ;;
        vendor/lib/libmpbase.so)
            "${PATCHELF}" --remove-needed "libandroid.so" "${2}"
            ;;
	vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so)
            hexdump -ve '1/1 "%.2X"' "${2}" | sed "s/8D0A0094AE1640F9/1F2003D5AE1640F9/g" | xxd -r -p > "${TMPDIR}/${1##*/}"
            mv "${TMPDIR}/${1##*/}" "${2}"
            ;;
        vendor/lib64/hw/camera.xiaomi.so)
            # Before
            # 21 00 80 52     mov        w1,#0x1
            # 29 07 00 94     bl         <EXTERNAL>::android::hardware::configureRpcThr
            # After
            # 21 00 80 52     mov        w1,#0x1
            # 1f 20 03 d5     nop
            sed -i "s/\x21\x00\x80\x52\x29\x07\x00\x94/\x21\x00\x80\x52\x1f\x20\x03\xd5/g" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=jason
export DEVICE_COMMON=sdm660-common
export VENDOR=xiaomi

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
