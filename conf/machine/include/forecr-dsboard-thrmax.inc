require conf/machine/include/p4071.inc

MACHINEOVERRIDES =. "forecr:forecr-dsboard-thrmax:"

# Board-specific pinmux/padvoltage.
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra264-mb1-bct-pinmux-forecr-dsboard-thrmax.dts"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra264-mb1-bct-padvoltage-forecr-dsboard-thrmax.dts"

require conf/machine/include/forecr-recommends.inc