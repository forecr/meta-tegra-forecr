SUMMARY = "Forecr board udev rule overrides"
DESCRIPTION = "Device-node permission fixes needed for interactive (non-root) \
users on Forecr dev images"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "(tegra)"

# /dev/udmabuf defaults to root:kvm 0660 -- nvv4l2decoder needs it whenever
# its output feeds nvstreammux (any real DeepStream pipeline), and it's
# opened by whichever user runs the GStreamer pipeline, not just root.
# The default interactive user (weston) got a plain "Permission denied" opening it directly, even
# after CONFIG_UDMABUF was enabled in the kernel and the device
# node existed.
SRC_URI = "file://99-forecr-udmabuf.rules"

S = "${UNPACKDIR}"

do_install() {
    install -m 0644 -D -t ${D}${sysconfdir}/udev/rules.d ${UNPACKDIR}/99-forecr-udmabuf.rules
}

FILES:${PN} = "${sysconfdir}/udev/rules.d"
