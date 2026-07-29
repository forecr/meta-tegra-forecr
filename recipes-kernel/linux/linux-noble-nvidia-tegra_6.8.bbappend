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
SRCBRANCH:forecr = "JetPack-7.2"
SRCREV:forecr = "7d692fe38085fbb4dab755a01220d6216399cfd9"
KBRANCH:forecr = "${SRCBRANCH}"
KERNEL_REPO:forecr = "${SRC_REPO}"

# Forecr's fork ships the full L4T public-sources tree (kernel/, hardware/,
# nvgpu/, ...), not a bare kernel source tree -- extract the actual kernel
# source up to ${S} before the recipe's patch/config machinery runs. Same
# approach as this layer's scarthgap-branch do_replace_kernel_src_files,
# adjusted for the JetPack-7.2 fork's kernel/kernel-noble/ layout (was
# kernel/kernel-jammy-src/ on the JetPack-6.1 branch). No-op for non-Forecr
# machines, which never fetch the fork and so have no kernel/kernel-noble/
# subdirectory to hoist.
do_replace_kernel_src_files() {
    :
}
do_replace_kernel_src_files:forecr() {
    mkdir -p ${S}/../git_tmp
    mv ${S}/* ${S}/../git_tmp/
    mv ${S}/../git_tmp/kernel/kernel-noble/* ${S}/
    rm -r ${S}/../git_tmp
}
addtask replace_kernel_src_files after do_validate_branches before do_patch

KBUILD_DEFCONFIG:forecr-dsboard-agx = "dsboard_agx_defconfig"
KBUILD_DEFCONFIG:forecr-dsboard-thrmax-t4000 = "dsboard_thrmax_defconfig"
KBUILD_DEFCONFIG:forecr-dsboard-thrmax-t5000 = "dsboard_thrmax_defconfig"
