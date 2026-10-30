# DSBOARD-AGXS common definitions

MACHINEOVERRIDES =. "forecr:forecr-dsboard-agxs:"

# The -base DTB here avoids a kernel panic, as this lets userspace set
# up a USB gadget device for flashing purposes.
KERNEL_DEVICETREE = "tegra234-p3737-0000+${FORECR_ORIN_MODULE}-nv-dsboard-agxs-base.dtb"
TEGRA_BUPGEN_SPECS = "fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;chipsku=00:00:00:D0;bup_type=bl \
                       fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;bup_type=kernel"

TEGRA_FLASHVAR_PMIC_CONFIG ?= "tegra234-mb1-bct-pmic-p3701-0005.dts"

# Board-specific pinmux/padvoltage.
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra234-forecr-dsboard-agxs-pinmux.dtsi"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra234-forecr-dsboard-agxs-padvoltage-default.dtsi"

require conf/machine/include/agx-orin.inc
require conf/machine/include/p3737.inc

TEGRA_PLUGIN_MANAGER_OVERLAYS = "L4TConfiguration.dtbo tegra234-p3737-0000+p3701-0000-dynamic.dtbo tegra234-carveouts.dtbo tegra-optee.dtbo"

require conf/machine/include/forecr-recommends.inc
