# Use Forecr's prebuilt UEFI for RAIBOARD-AGX instead of the from-source build.
# Author: Kaya Kaan Tuna <kayatuna@forecr.io>

FILESEXTRAPATHS:prepend:forecr-raiboard-agx := "${THISDIR}/${BPN}:"
SRC_URI:append:forecr-raiboard-agx = " file://forecr-raiboard-agx/uefi_t23x_general_RELEASE.bin"

do_deploy:append:forecr-raiboard-agx() {
    install -m 0644 ${UNPACKDIR}/forecr-raiboard-agx/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

FILESEXTRAPATHS:prepend:forecr-dsboard-agx :=  "${THISDIR}/${BPN}:"
SRC_URI:append:forecr-dsboard-agx = " file://forecr-dsboard-agx/uefi_t23x_general_RELEASE.bin"

do_deploy:append:forecr-dsboard-agx() {
    install -m 0644 ${UNPACKDIR}/forecr-dsboard-agx/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}