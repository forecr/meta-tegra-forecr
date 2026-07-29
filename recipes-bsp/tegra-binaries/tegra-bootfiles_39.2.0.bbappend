# Per-MACHINE pinmux/GPIO/padvoltage BCT file installation, following
# meta-tegra/docs/Creating-a-custom-MACHINE.md ("Add pinmux dtsi files" for
# Orin, "Add pinmux and BCT files" for Thor).

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
CUSTOM_DTSI_DIR := "${THISDIR}/${BPN}"

SRC_URI:append:forecr-dsboard-agx = " \
    file://forecr-dsboard-agx/tegra234-forecr-dsboard-agx-gpio-default.dtsi \
    file://forecr-dsboard-agx/tegra234-forecr-dsboard-agx-padvoltage-default.dtsi \
    file://forecr-dsboard-agx/tegra234-forecr-dsboard-agx-pinmux.dtsi \
"

do_install:append:forecr-dsboard-agx() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-gpio-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-padvoltage-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-pinmux.dtsi ${D}${datadir}/tegraflash/
}

SRC_URI:append:forecr-dsboard-thrmax-t4000 = " \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts \
"
SRC_URI:append:forecr-dsboard-thrmax-t5000 = " \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts \
"

install_forecr_dsboard_thrmax_files() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
}

do_install:append:forecr-dsboard-thrmax-t4000() {
    install_forecr_dsboard_thrmax_files
}
do_install:append:forecr-dsboard-thrmax-t5000() {
    install_forecr_dsboard_thrmax_files
}
