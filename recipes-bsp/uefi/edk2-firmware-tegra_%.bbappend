# Use Forecr's prebuilt UEFI for RAIBOARD-AGX instead of the from-source build.
# Author: Kaya Kaan Tuna <kayatuna@forecr.io>

FILESEXTRAPATHS:prepend:forecr := "${THISDIR}/${BPN}:"

SRC_URI:append:forecr-raiboard-agx = " file://forecr-raiboard-agx/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-raiboard-agx() {
    install -m 0644 ${UNPACKDIR}/forecr-raiboard-agx/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

SRC_URI:append:forecr-dsboard-agx = " file://forecr-dsboard-agx/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-dsboard-agx() {
    install -m 0644 ${UNPACKDIR}/forecr-dsboard-agx/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

SRC_URI:append:forecr-dsboard-agxmax = " file://forecr-dsboard-agxmax/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-dsboard-agxmax() {
    install -m 0644 ${UNPACKDIR}/forecr-dsboard-agxmax/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

SRC_URI:append:forecr-dsboard-agxs = " file://forecr-dsboard-agxs/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-dsboard-agxs() {
    install -m 0644 ${UNPACKDIR}/forecr-dsboard-agxs/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

SRC_URI:append:forecr-milboard-agx = " file://forecr-milboard-agx/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-milboard-agx() {
    install -m 0644 ${UNPACKDIR}/forecr-milboard-agx/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}

SRC_URI:append:forecr-milboard-agxmax = " file://forecr-milboard-agxmax/uefi_t23x_general_RELEASE.bin"
do_deploy:append:forecr-milboard-agxmax() {
    install -m 0644 ${UNPACKDIR}/forecr-milboard-agxmax/uefi_t23x_general_RELEASE.bin ${DEPLOYDIR}/${TEGRA_FLASHVAR_UEFI_IMAGE}.bin
}