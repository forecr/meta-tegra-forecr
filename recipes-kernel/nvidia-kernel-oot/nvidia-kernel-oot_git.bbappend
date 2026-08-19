# Bitbake append file to add our custom devicetrees
# Author: Kaya Kaan Tuna <kayatuna@forecr.io>

SRC_REPO_FORECR_T23X_DTS ?= "github.com/forecr/forecr_xavier_kernel.git;protocol=https"
SRCBRANCH_FORECR_T23X_DTS ?= "JetPack-7.2"

SRC_URI:append:forecr-raiboard-agx = " \
    git://${SRC_REPO_FORECR_T23X_DTS};branch=${SRCBRANCH_FORECR_T23X_DTS};name=forecr-dts;destsuffix=${BPN}-${PV}/forecr-dts-tmp \
"
# Same fork commit the kernel recipe itself
SRCREV_forecr-dts = "7d692fe38085fbb4dab755a01220d6216399cfd9"

add_forecr_raiboard_dts_files() {
    :
}
add_forecr_raiboard_dts_files:forecr-raiboard-agx() {
    cp -a ${S}/forecr-dts-tmp/hardware/nvidia/. ${S}/hardware/nvidia/
    rm -rf ${S}/forecr-dts-tmp
}
do_unpack[postfuncs] += "add_forecr_raiboard_dts_files"
