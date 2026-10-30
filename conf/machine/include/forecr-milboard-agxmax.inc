# MILBOARD-AGXMAX common definitions

MACHINEOVERRIDES =. "forecr:forecr-milboard-agxmax:"

# The -base DTB here avoids a kernel panic, as this lets userspace set
# up a USB gadget device for flashing purposes.
KERNEL_DEVICETREE = "tegra234-p3737-0000+${FORECR_ORIN_MODULE}-nv-milboard-agxmax-base.dtb"
TEGRA_BUPGEN_SPECS = "fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;chipsku=00:00:00:D0;bup_type=bl \
                       fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;bup_type=kernel"

TEGRA_FLASHVAR_PMIC_CONFIG ?= "tegra234-mb1-bct-pmic-p3701-0005.dts"

# Board-specific pinmux/padvoltage.
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra234-forecr-milboard-agxmax-pinmux.dtsi"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra234-forecr-milboard-agxmax-padvoltage-default.dtsi"
TEGRA_FLASHVAR_ODMDATA = "gbe-uphy-config-22,hsstp-lane-map-3,nvhs-uphy-config-0,hsio-uphy-config-16,gbe0-enable-10g"

require conf/machine/include/agx-orin.inc
require conf/machine/include/p3737.inc

TEGRA_PLUGIN_MANAGER_OVERLAYS = "L4TConfiguration.dtbo tegra234-p3737-0000+p3701-0000-dynamic.dtbo tegra234-carveouts.dtbo tegra-optee.dtbo"

require conf/machine/include/forecr-recommends.inc
