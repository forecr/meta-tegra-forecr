require conf/machine/include/p4071.inc

MACHINEOVERRIDES =. "forecr:forecr-milboard-thr:"

# Board-specific pinmux/padvoltage.
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra264-mb1-bct-pinmux-forecr-milboard-thr.dts"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra264-mb1-bct-padvoltage-forecr-milboard-thr.dts"

require conf/machine/include/forecr-recommends.inc

MACHINE_EXTRA_RRECOMMENDS += "\
    kernel-module-vfat \
"
