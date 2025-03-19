
do_install:append() {
    # Apply the system config for AGX Orin
    sed -i "s/cvb_eeprom_read_size = <0x100>;/cvb_eeprom_read_size = <0x0>;/g" ${D}${datadir}/tegraflash/tegra234-mb2-bct-common.dtsi
    # Apply the system config for Orin NX / Orin Nano
    sed -i "s/cvb_eeprom_read_size = <0x100>;/cvb_eeprom_read_size = <0x0>;/g" ${D}${datadir}/tegraflash/tegra234-mb2-bct-misc-p3767-0000.dts
}

