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

SRC_URI:append:forecr-raiboard-agx = " \
    file://forecr-raiboard-agx/tegra234-forecr-raiboard-agx-gpio-default.dtsi \
    file://forecr-raiboard-agx/tegra234-forecr-raiboard-agx-padvoltage-default.dtsi \
    file://forecr-raiboard-agx/tegra234-forecr-raiboard-agx-pinmux.dtsi \
"

do_install:append:forecr-dsboard-agx() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-gpio-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-padvoltage-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-agx/tegra234-forecr-dsboard-agx-pinmux.dtsi ${D}${datadir}/tegraflash/
    # None of Forecr's carrier boards populate the NVIDIA reference carrier's
    # EEPROM -- disable the MB2 read so it doesn't stall/fail trying to read
    # one that isn't there. Confirmed necessary (not just theoretical) by
    # diffing against a hand-tuned NVIDIA-SDK-Manager Linux_for_Tegra tree
    # for this exact board family, where this exact line was the change.
    # Matches this layer's scarthgap-branch fix for AGX Orin.
    sed -i "s/cvb_eeprom_read_size = <0x100>;/cvb_eeprom_read_size = <0x0>;/g" ${D}${datadir}/tegraflash/tegra234-mb2-bct-common.dtsi
}

do_install:append:forecr-raiboard-agx() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-raiboard-agx/tegra234-forecr-raiboard-agx-gpio-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-raiboard-agx/tegra234-forecr-raiboard-agx-padvoltage-default.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-raiboard-agx/tegra234-forecr-raiboard-agx-pinmux.dtsi ${D}${datadir}/tegraflash/
    # None of Forecr's carrier boards populate the NVIDIA reference carrier's
    # EEPROM -- disable the MB2 read so it doesn't stall/fail trying to read
    # one that isn't there. Confirmed necessary (not just theoretical) by
    # diffing against a hand-tuned NVIDIA-SDK-Manager Linux_for_Tegra tree
    # for this exact board family, where this exact line was the change.
    # Matches this layer's scarthgap-branch fix for AGX Orin.
    sed -i "s/cvb_eeprom_read_size = <0x100>;/cvb_eeprom_read_size = <0x0>;/g" ${D}${datadir}/tegraflash/tegra234-mb2-bct-common.dtsi
}

# Each of TEGRA_FLASHVAR_PINMUX_CONFIG/PMC_CONFIG (the two .dts files below)
# is a thin wrapper -- /dts-v1/; / { mb1_bct { padctl@0 / pmc@0 { #include
# "<name>.dtsi" }; }; }; -- around a separate .dtsi fragment carrying the
# actual pin/voltage content, matching NVIDIA's own stock file structure
# (confirmed by inspecting the fetched stock tegra264-mb1-bct-pinmux/
# padvoltage-p3834-xxxx-p4071-0000.dts/.dtsi pair in this recipe's
# work-shared source tree). Pointing TEGRA_FLASHVAR_PINMUX_CONFIG straight at
# bare fragment content (skipping the wrapper) fails do_dump /
# tegraflash_generate_mb1_bct with "DTC command failed" -- dtc rejects a
# file with no /dts-v1/ root. Verified locally with cpp+dtc against the real
# flash package (stock headers + these five files) before wiring this up.
SRC_URI:append:forecr-dsboard-thrmax-t4000 = " \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dtsi \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dtsi \
"
SRC_URI:append:forecr-dsboard-thrmax-t5000 = " \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dtsi \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts \
    file://forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dtsi \
"

install_forecr_dsboard_thrmax_files() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-gpio-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dtsi ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/forecr-dsboard-thrmax/tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dtsi ${D}${datadir}/tegraflash/

    # None of Forecr's carrier boards populate the NVIDIA reference carrier's
    # EEPROM -- disable the MB2 read so it doesn't stall/fail trying to read
    # one that isn't there. Confirmed necessary (not just theoretical) by
    # diffing against a hand-tuned NVIDIA-SDK-Manager Linux_for_Tegra tree
    # for this exact board family (JetPack 7.1 -- most of that diff was
    # legitimate 7.1-vs-7.2 version drift, but this one line was clearly a
    # deliberate hand-applied change, matching this layer's scarthgap-branch
    # fix for AGX Orin exactly). Suspected as the actual cause of an early
    # RCM boot-loop (device repeatedly re-entering APX/recovery mode instead
    # of completing MB1/MB2 boot) seen while bringing up DSBOARD-THRMAX.
    sed -i "s/cvb_eeprom_read_size = <0x100>;/cvb_eeprom_read_size = <0x0>;/g" ${D}${datadir}/tegraflash/tegra264-mb2-bct-common.dtsi
}

do_install:append:forecr-dsboard-thrmax-t4000() {
    install_forecr_dsboard_thrmax_files
}
do_install:append:forecr-dsboard-thrmax-t5000() {
    install_forecr_dsboard_thrmax_files
}
