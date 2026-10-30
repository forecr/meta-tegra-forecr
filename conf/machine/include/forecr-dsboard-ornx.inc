# Shared settings for Forecr DSBOARD-ORNX (Orin NX / Orin Nano modules).
#
# Each conf/machine/forecr-dsboard-ornx-*.conf first requires meta-tegra's
# stock machine for its module SKU (p3768-0000-p3767-XXXX.conf), which
# supplies the per-SKU boot settings (SDRAM BCT, BPMP DTB, chip SKU,
# nvpmodel, storage layout), then sets FORECR_ORNX_MODULE and requires this
# file. Everything here comes AFTER the stock require on purpose:
# tegra-common.inc does a hard `MACHINE_EXTRA_RRECOMMENDS = ...`, which
# would wipe anything appended before it.

# "forecr" = any Forecr machine; "forecr-dsboard-ornx" = all four ORNX SKU
# machines (used by the tegra-bootfiles, kernel and DTB bbappends).
MACHINEOVERRIDES =. "forecr:forecr-dsboard-ornx:"

# Forecr device tree from forecr_xavier_kernel (JetPack-7.2.1), "super"
# variant to match meta-tegra's -nv-super DTBs and *_super nvpmodel configs.
KERNEL_DEVICETREE = "tegra234-p3768-0000+${FORECR_ORNX_MODULE}-nv-super-dsboard-ornx.dtb"

# Board-specific pinmux/padvoltage (from Jetson_Pinmux/DSBOARD-ORNX_Orin).
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra234-forecr-dsboard-ornx-pinmux.dtsi"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra234-forecr-dsboard-ornx-padvoltage-default.dtsi"

# UPHY lane config: gbe-uphy-config-9 instead of the devkit's -8, as in
# Forecr's DSBOARD-ORNX SDK Manager BSP (replace_bsp_files.sh).
TEGRA_FLASHVAR_ODMDATA = "gbe-uphy-config-9,hsstp-lane-map-3,hsio-uphy-config-0"

# AI/multimedia stack -- same set as the other Forecr machines.
# kernel-module-vfat: dsboard_ornx_defconfig builds VFAT as a module, and
# /boot/efi (the ESP, vfat) fails to mount without it.
require conf/machine/include/forecr-recommends.inc

MACHINE_EXTRA_RRECOMMENDS += "\
    kernel-module-vfat \
"
