SRCBRANCH = "JetPack-6.2.2"
SRCREV = "ad540c6e1b1438358e0ed496d4d1f736e1786bed"
KBRANCH = "${SRCBRANCH}"
SRC_REPO = "github.com/forecr/forecr_xavier_kernel.git;protocol=https"

BB_ENV_PASSTHROUGH_ADDITIONS = "FORECR_CARRIER_BOARD_TYPE"
FORECR_CARRIER_BOARD_TYPE ??= "JETSON"

python () {
    if d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-AGX":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_agx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-AGXMAX":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_agx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-NX2":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_nx2_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-ORNX":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_ornx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-ORNX-LAN":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_ornx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "DSBOARD-ORNXS":
        d.setVar("KBUILD_DEFCONFIG", "dsboard_ornx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "MILBOARD-AGX":
        d.setVar("KBUILD_DEFCONFIG", "milboard_agx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "RAIBOARD-AGX":
        d.setVar("KBUILD_DEFCONFIG", "raiboard_agx_defconfig")
    elif d.getVar("FORECR_CARRIER_BOARD_TYPE") == "RAIBOARD-ORNX":
        d.setVar("KBUILD_DEFCONFIG", "raiboard_ornx_defconfig")
    else:
        d.setVar("KBUILD_DEFCONFIG", "defconfig")
}

do_replace_kernel_src_files() {
	mkdir -p ${S}/../git_tmp
	mv ${S}/* ${S}/../git_tmp/
	mv ${S}/../git_tmp/kernel/kernel-jammy-src/* ${S}/
	rm -r ${S}/../git_tmp
}
addtask replace_kernel_src_files after do_validate_branches before do_patch
