# Vendored from OE4T/meta-tegra-community (wrynose branch) -- a transitive
# DEPENDS of python3-cuda not packaged anywhere else in this workspace's
# layers. Re-sync from there on version bumps:
# https://github.com/OE4T/meta-tegra-community/blob/wrynose/recipes-devtools/python/python3-pyclibrary_0.2.2.bb
SUMMARY = "C parser and ctypes automation for python"
HOMEPAGE = "https://pyclibrary.readthedocs.io/en/latest/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3e0779d1fc89e60083c1d63c61507990"

SRC_URI[sha256sum] = "9902fffe361bb86f57ab62aa4195ec4dd382b63c5c6892be6d9784ec0a3575f7"

S = "${UNPACKDIR}/pyclibrary-${PV}"

inherit pypi setuptools3

BBCLASSEXTEND = "native nativesdk"
RDEPENDS:${PN} = "python3-pyparsing"
