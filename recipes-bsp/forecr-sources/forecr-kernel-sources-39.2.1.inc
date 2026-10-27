# Point Forecr machines (MACHINEOVERRIDES contains "forecr", set by each
# conf/machine/forecr-*.conf) at Forecr's kernel fork, and select a per-board
# defconfig by MACHINE. All overrides below are scoped so building a stock
# upstream machine (e.g. jetson-agx-orin-devkit) with this layer present in
# BBLAYERS is unaffected.
#
# NOT YET BUILD-VERIFIED. Known risk: the base recipe's local patch/config
# files (libbpf/perf fixes, disable-fw-user-helper.cfg, systemd.cfg,
# disable-module-signing.cfg, fbcon.cfg, tegra-ip-nf.cfg) are written against
# NVIDIA's canonical l4t-r39.2 linux-noble.git tree; whether they apply
# cleanly against Forecr's forked tree (which already carries its own L4T
# patch set) is unverified -- if do_patch fails, check whether the fork
# already includes the fix and SRC_URI:remove the redundant one.
SRC_REPO:forecr = "github.com/forecr/forecr_xavier_kernel.git;protocol=https"
SRCBRANCH:forecr = "JetPack-7.2.1"
SRCREV:forecr = "f3d3deba9e68139055b2de7398108e5dfab1d855"
KBRANCH:forecr = "${SRCBRANCH}"
KERNEL_REPO:forecr = "${SRC_REPO}"