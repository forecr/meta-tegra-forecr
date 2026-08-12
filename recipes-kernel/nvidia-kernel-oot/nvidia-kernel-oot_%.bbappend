SRC_URI += "git://github.com/forecr/forecr_xavier_kernel.git;protocol=https;branch=JetPack-6.2.2;name=forecr-dts;destsuffix=forecr-dts"
SRCREV_forecr-dts = "ad540c6e1b1438358e0ed496d4d1f736e1786bed"

INSANE_SKIP:nvidia-kernel-oot-devicetrees += "buildpaths"

do_unpack[postfuncs] += "replace_t23x_nv_public"

python replace_t23x_nv_public () {
    import shutil, os

    workdir = d.getVar('WORKDIR')
    src = os.path.join(workdir, 'forecr-dts', 'hardware', 'nvidia', 't23x', 'nv-public')
    dst = os.path.join(workdir, d.getVar('BP'), 'hardware', 'nvidia', 't23x', 'nv-public')

    if not os.path.isdir(src):
        bb.fatal("forecr t23x/nv-public tree not found at %s" % src)

    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)
}
