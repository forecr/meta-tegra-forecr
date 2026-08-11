FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

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

# CONFIG_UDMABUF is not set in the base defconfig on any Forecr board.
# nvv4l2decoder's buffer pool needs /dev/udmabuf when its output feeds nvstreammux 
# without it, the pool degrades. ("Udmabuf allocator not available, 
# can't open /dev/udmabuf: No such file or directory" -> "Uncertain or 
# not enough buffers, enabling copy threshold" -> "Driver should never set 
# v4l2_buffer.field to ANY") and the very next buffer push fails, surfacing 
# (misleadingly) as "Internal data stream error" reported against h264parse 
# rather than the decoder or streammux where the actual problem is.
SRC_URI:append:forecr = " file://udmabuf.cfg"

# Forecr's fork ships the full L4T public-sources tree (kernel/, hardware/,
# nvgpu/, ...), not a bare kernel source tree -- extract the actual kernel
# source up to ${S} before the recipe's patch/config machinery runs. Same
# approach as this layer's scarthgap-branch do_replace_kernel_src_files,
# adjusted for the JetPack-7.2 fork's kernel/kernel-noble/ layout (was
# kernel/kernel-jammy-src/ on the JetPack-6.1 branch). No-op for non-Forecr
# machines, which never fetch the fork and so have no kernel/kernel-noble/
# subdirectory to hoist.
#
# Must run before do_kernel_metadata, not just do_patch: unlike scarthgap's
# kernel recipe, this one inherits kernel-yocto's kmeta machinery, where
# do_kernel_metadata sits in the same after-do_validate_branches /
# before-do_patch window we originally hooked into. Without an explicit
# ordering against do_kernel_metadata too, bitbake doesn't guarantee it runs
# after our mv -- it can inspect arch/arm64/configs/ before the board
# defconfig has been hoisted into place and fail with "KBUILD_DEFCONFIG ...
# not present in the source tree".
do_replace_kernel_src_files() {
    :
}
do_replace_kernel_src_files:forecr() {
    mkdir -p ${S}/../git_tmp
    mv ${S}/* ${S}/../git_tmp/
    mv ${S}/../git_tmp/kernel/kernel-noble/* ${S}/
    rm -rf ${S}/../git_tmp

    # `mv ${S}/*` above only moves visible entries -- .git (a dotdir) is left
    # behind untouched, so it still describes the original nested
    # kernel/kernel-noble/... path layout, not the flattened tree now on
    # disk. kern-tools' patch application is git-index-aware even in its
    # "apply" fallback, so every patch fails with "<path>: does not exist in
    # index" even when the file is genuinely present -- it's consulting a
    # stale index, not a missing file. Re-init git against the flattened
    # tree so the index matches what's actually on disk.
    rm -rf ${S}/.git
    git -C ${S} init -q
    git -C ${S} config user.email "build@localhost"
    git -C ${S} config user.name "build"
    git -C ${S} add -A
    git -C ${S} commit -q -m "forecr_xavier_kernel JetPack-7.2 kernel-noble snapshot"
}
addtask replace_kernel_src_files after do_validate_branches before do_kernel_metadata do_patch

KBUILD_DEFCONFIG:forecr-dsboard-agx = "dsboard_agx_defconfig"
KBUILD_DEFCONFIG:forecr-dsboard-thrmax-t4000 = "dsboard_thrmax_defconfig"
KBUILD_DEFCONFIG:forecr-dsboard-thrmax-t5000 = "dsboard_thrmax_defconfig"
KBUILD_DEFCONFIG:forecr-raiboard-agx = "raiboard_agx_defconfig"