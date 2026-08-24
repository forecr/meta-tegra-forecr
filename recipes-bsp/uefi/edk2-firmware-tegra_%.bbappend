FILESEXTRAPATHS:prepend := "${THISDIR}/edk2-firmware-tegra:"

SRC_URI += " \
    file://forecrblack480.bmp \
    file://forecrblack720.bmp \
    file://forecrblack1080.bmp \
"

do_configure:append() {
    install -m 0644 ${WORKDIR}/forecrblack480.bmp  ${S}/../edk2-nvidia/Silicon/NVIDIA/Drivers/Logo/nvidiagray480.bmp
    install -m 0644 ${WORKDIR}/forecrblack720.bmp  ${S}/../edk2-nvidia/Silicon/NVIDIA/Drivers/Logo/nvidiagray720.bmp
    install -m 0644 ${WORKDIR}/forecrblack1080.bmp ${S}/../edk2-nvidia/Silicon/NVIDIA/Drivers/Logo/nvidiagray1080.bmp
    install -m 0644 ${WORKDIR}/forecrblack720.bmp ${S}/../edk2-nvidia/Silicon/NVIDIA/Drivers/Logo/nvidiablack-1036x864.bmp
}
