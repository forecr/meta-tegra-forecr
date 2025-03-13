SRCBRANCH = "JetPack-6.1"
SRCREV = "936a78f28a7abea7d0ceb0e6894e890c964050d2"
KBRANCH = "${SRCBRANCH}"
SRC_REPO = "github.com/forecr/forecr_xavier_kernel.git;protocol=https"

BB_ENV_PASSTHROUGH_ADDITIONS = "FORECR_CARRIER_BOARD_TYPE"
FORECR_DEFCONFIG_FILE ??= "defconfig"
KBUILD_DEFCONFIG = "${FORECR_DEFCONFIG_FILE}"

do_replace_kernel_src_files() {
	mkdir -p ${S}/../git_tmp
	mv ${S}/* ${S}/../git_tmp/
	mv ${S}/../git_tmp/kernel/kernel-jammy-src/* ${S}/
	rm -r ${S}/../git_tmp
}
addtask replace_kernel_src_files before do_kernel_metadata after do_kernel_checkout
