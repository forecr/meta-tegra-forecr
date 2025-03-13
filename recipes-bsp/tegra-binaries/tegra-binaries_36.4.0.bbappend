FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://DSBOARD-AGX/bootloader/ \
                   file://DSBOARD-AGXMAX/bootloader/ \
                   file://DSBOARD-AGXMAX-BEFORE-REV12/bootloader/ \
                   file://DSBOARD-NX2/bootloader/ \
                   file://DSBOARD-ORNX/bootloader/ \
                   file://DSBOARD-ORNX-LAN/bootloader/ \
                   file://DSBOARD-ORNXS/bootloader/ \
                   file://MILBOARD-AGX/bootloader/ \
                   file://MILBOARD-AGX-BEFORE-REV121/bootloader/ \
                   file://RAIBOARD-AGX/bootloader/ \
                   file://RAIBOARD-ORNX/bootloader/ \
"

# FORECR_CARRIER_BOARD_TYPE defined in linux-jammy-nvidia-tegra_5.15.bbappend
BB_ENV_PASSTHROUGH_ADDITIONS = "FORECR_PINMUX_POST_CONFIG"
FORECR_PINMUX_POST_CONFIG ??= ""

do_preconfigure:append() {
    cp -rf ${WORKDIR}/${FORECR_CARRIER_BOARD_TYPE}${FORECR_PINMUX_POST_CONFIG}/bootloader/* ${S}/bootloader/
}
