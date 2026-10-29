# DSBOARD-AGXMAX common definitions

MACHINEOVERRIDES =. "forecr:forecr-dsboard-agxmax:"

# The -base DTB here avoids a kernel panic, as this lets userspace set
# up a USB gadget device for flashing purposes.
KERNEL_DEVICETREE = "tegra234-p3737-0000+${FORECR_ORIN_MODULE}-nv-dsboard-agxmax-base.dtb"
TEGRA_BUPGEN_SPECS = "fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;chipsku=00:00:00:D0;bup_type=bl \
                       fab=300;boardsku=${TEGRA_BOARDSKU};boardrev=;bup_type=kernel"

TEGRA_FLASHVAR_PMIC_CONFIG ?= "tegra234-mb1-bct-pmic-p3701-0005.dts"

# Board-specific pinmux/padvoltage.
TEGRA_FLASHVAR_PINMUX_CONFIG = "tegra234-forecr-dsboard-agxmax-pinmux.dtsi"
TEGRA_FLASHVAR_PMC_CONFIG = "tegra234-forecr-dsboard-agxmax-padvoltage-default.dtsi"

require conf/machine/include/agx-orin.inc
require conf/machine/include/p3737.inc

TEGRA_PLUGIN_MANAGER_OVERLAYS = "L4TConfiguration.dtbo tegra234-p3737-0000+p3701-0000-dynamic.dtbo tegra234-carveouts.dtbo tegra-optee.dtbo"

# DeepStream SDK. deepstream-9.1/-pyds and their meta-tegra-community-only
# DEPENDS (yaml-cpp-080, opentelemetry-cpp-1230, python3-cuda,
# python3-pyclibrary) are vendored directly into this layer's
# recipes-devtools/ and recipes-support/
#
# nv3dsink itself is broken on real Thor hardware (X11-only upstream
# source vs. Xwayland/split-GPU topology not getting GL acceleration --
# full diagnosis in forecr-dsboard-thrmax-t5000.conf). waylandsink is the
# confirmed-working alternative for any custom pipeline/app on Thor; not
# yet tested on AGX Orin, but added here too since Orin likely doesn't
# have the same split display/render topology (single integrated GPU) --
# worth confirming whether nv3dsink even has the same problem there.
MACHINE_EXTRA_RRECOMMENDS += "\
    cudnn \
    deepstream-9.1 \
    deepstream-9.1-samples \
    deepstream-9.1-pyds \
    deepstream-9.1-pyds-samples \
    gstreamer1.0-plugins-bad-videoparsersbad \
    gstreamer1.0-plugins-nveglgles \
    gstreamer1.0-plugins-nvvideosinks \
    gstreamer1.0-plugins-bad-waylandsink \
    udev-rules-forecr \
"
