# Bitbake append file to add our custom devicetrees
# Author: Kaya Kaan Tuna <kayatuna@forecr.io>

require recipes-bsp/forecr-sources/forecr-kernel-sources-39.2.1.inc

SRC_URI:append:forecr = " \
    git://${SRC_REPO};branch=${SRCBRANCH};name=forecr-dts;destsuffix=forecr-dts-tmp \
"

# "cp: cannot stat …" error changed to UNPACKDIR
add_forecr_raiboard_dts_files() {
    cp -rf ${UNPACKDIR}/forecr-dts-tmp/hardware/nvidia/t23x/nv-public/nv-platform/. ${DT_FILES_PATH}
    cp -rf ${UNPACKDIR}/forecr-dts-tmp/hardware/nvidia/t23x/nv-public/. ${DT_NV_BASE}/t23x/nv-public
    rm -rf ${UNPACKDIR}/forecr-dts-tmp
    # Forecr .dts files set nvidia,dtsfilename = __FILE__, which cpp expands
    # to the absolute build path and trips the buildpaths QA check. Use the
    # bare file name instead (stock NVIDIA .dts files don't set it at all).
    grep -rl --include='*.dts' 'nvidia,dtsfilename = __FILE__' ${DT_NV_BASE}/t23x/nv-public | while read -r f; do
        sed -i "s|nvidia,dtsfilename = __FILE__;|nvidia,dtsfilename = \"$(basename $f)\";|" "$f"
    done
}

do_configure:prepend:forecr() {
    add_forecr_raiboard_dts_files
}