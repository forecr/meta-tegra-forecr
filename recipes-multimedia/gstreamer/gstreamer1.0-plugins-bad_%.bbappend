# Gstreamer 1.26 Deepstream fix .bbappend file
# Author: Kaya Kaan Tuna <kayatuna@forecr.io>

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-waylandsink-never-use-the-udmabuf-pool.patch"
