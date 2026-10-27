# Bitbake append file to add Forecr's custom device trees for DSBOARD-ORNX.
# Fetches the board .dts/.dtsi files from Forecr's kernel fork and copies
# them over NVIDIA's before the DTBs are compiled.

SRC_REPO_FORECR_ORNX_DTS ?= "github.com/forecr/forecr_xavier_kernel.git;protocol=https"
SRCBRANCH_FORECR_ORNX_DTS ?= "JetPack-7.2.1"

SRC_URI:append:forecr-dsboard-ornx = " \
    git://${SRC_REPO_FORECR_ORNX_DTS};branch=${SRCBRANCH_FORECR_ORNX_DTS};name=forecr-ornx-dts;destsuffix=forecr-ornx-dts-tmp \
"
SRCREV_forecr-ornx-dts = "f3d3deba9e68139055b2de7398108e5dfab1d855"

add_forecr_ornx_dts_files() {
    cp -rf ${UNPACKDIR}/forecr-ornx-dts-tmp/hardware/nvidia/t23x/nv-public/nv-platform/. ${DT_FILES_PATH}
    cp -rf ${UNPACKDIR}/forecr-ornx-dts-tmp/hardware/nvidia/t23x/nv-public/. ${DT_NV_BASE}/t23x/nv-public
    rm -rf ${UNPACKDIR}/forecr-ornx-dts-tmp
    # Forecr .dts files set nvidia,dtsfilename = __FILE__, which cpp expands
    # to the absolute build path and trips the buildpaths QA check. Use the
    # bare file name instead (stock NVIDIA .dts files don't set it at all).
    grep -rl --include='*.dts' 'nvidia,dtsfilename = __FILE__' ${DT_NV_BASE}/t23x/nv-public | while read -r f; do
        sed -i "s|nvidia,dtsfilename = __FILE__;|nvidia,dtsfilename = \"$(basename $f)\";|" "$f"
    done
}
do_configure:prepend:forecr-dsboard-ornx() {
    add_forecr_ornx_dts_files
}
