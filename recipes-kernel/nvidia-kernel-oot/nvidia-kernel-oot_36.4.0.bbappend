FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://DSBOARD-AGX/kernel/ \
                   file://DSBOARD-AGXMAX/kernel/ \
                   file://DSBOARD-NX2/kernel/ \
                   file://DSBOARD-ORNX/kernel/ \
                   file://DSBOARD-ORNX-LAN/kernel/ \
                   file://DSBOARD-ORNXS/kernel/ \
                   file://MILBOARD-AGX/kernel/ \
                   file://RAIBOARD-AGX/kernel/ \
                   file://RAIBOARD-ORNX/kernel/ \
"

# FORECR_CARRIER_BOARD_TYPE defined in linux-jammy-nvidia-tegra_5.15.bbappend

do_install:append() {
    cp -f ${WORKDIR}/${FORECR_CARRIER_BOARD_TYPE}/kernel/* ${D}/boot/devicetree/
}
