# meta-tegra-forecr

Forecr BSP layer for NVIDIA Jetson platforms, based on L4T. This layer
depends on [meta-tegra](https://github.com/OE4T/meta-tegra) (branch
`wrynose`).

## Architecture

Follows [meta-tegra's Creating-a-custom-MACHINE guide](https://github.com/OE4T/meta-tegra/blob/wrynose/docs/Creating-a-custom-MACHINE.md):
one custom `MACHINE` per real Forecr carrier board, with
`TEGRA_FLASHVAR_PINMUX_CONFIG`/`TEGRA_FLASHVAR_PMC_CONFIG` set directly in
each machine `.conf` to point at that board's pinmux/padvoltage BCT files
(generated from NVIDIA's pinmux spreadsheet tool). No runtime board-selector
variable -- `MACHINE` is the only thing you need to set.

* `conf/machine/forecr-dsboard-agx.conf` -- DSBOARD-AGX (AGX Orin / P3701)
* `conf/machine/forecr-dsboard-thrmax-t4000.conf` -- DSBOARD-THRMAX, T4000 module
* `conf/machine/forecr-dsboard-thrmax-t5000.conf` -- DSBOARD-THRMAX, T5000 module

Each machine `require`s the matching upstream SoM `.inc` (`agx-orin.inc`,
`agx-thor-t4000.inc`/`agx-thor-t5000.inc`) plus the closest carrier `.inc`
(`p3737.inc`/`p4071.inc`) for a starting peripheral set -- the wifi/bt/eth
`MACHINE_EXTRA_RRECOMMENDS` those `.inc` files add describe NVIDIA's own
devkit carrier and will need overriding once Forecr's actual BOM is known.
Each machine `.conf` also prepends a shared `forecr` token to
`MACHINEOVERRIDES`, so recipe bbappends can target "any Forecr machine" with
one `:forecr` override instead of repeating every machine name.

Pinmux files live under
`recipes-bsp/tegra-binaries/tegra-bootfiles/<machine>/`, renamed to embed
the machine name per the guide's convention (e.g.
`tegra234-forecr-dsboard-agx-pinmux.dtsi`). Installed via
`tegra-bootfiles_39.2.0.bbappend` using `do_install:append:<machine>()`
blocks, exactly as the guide describes. One subtlety the guide's Orin
section flags but the Thor section omits: each pinmux file `#include`s a
GPIO-default file by literal filename, so renaming the pinmux file requires
fixing that `#include` line to match the renamed GPIO file -- done for both
boards here (verified by grepping the actual `#include` lines, not assumed).

The kernel recipe (`recipes-kernel/linux/linux-noble-nvidia-tegra_6.8.bbappend`)
follows the same `MACHINE`-based selection: `SRC_REPO`/`SRCBRANCH`/`SRCREV`
are overridden only under the `:forecr` override (so stock upstream machines
are unaffected if this layer is present in `BBLAYERS`), pointing at
`forecr_xavier_kernel.git`'s `JetPack-7.2` branch, and `KBUILD_DEFCONFIG` is
set per exact machine (`dsboard_agx_defconfig`, `dsboard_thrmax_defconfig`).

## Usage

```
MACHINE ?= "forecr-dsboard-agx"
# or "forecr-dsboard-thrmax-t4000" / "forecr-dsboard-thrmax-t5000"
```
in `local.conf`, with both `meta-tegra` and `meta-tegra-forecr` in
`BBLAYERS` (forecr after tegra), then `bitbake core-image-minimal`.

## Adding another board

The pinmux source repo (`forecr_blog_source_files/Jetson_Pinmux/`) has ~16
board variants total (DSBOARD/MILBOARD/RAIBOARD x AGX/AGXMAX/AGXS/ORNX/ORNXS/XV2,
plus MILBOARD-THR for Thor). To add one: create a new
`conf/machine/forecr-<board>.conf` requiring the right SoM/carrier `.inc`
pair, copy that board's three `.dtsi`/`.dts` files into
`recipes-bsp/tegra-binaries/tegra-bootfiles/forecr-<board>/` under
machine-name-based filenames, fix the pinmux file's `#include` line to match
the renamed GPIO file, and add matching `SRC_URI:append:<machine>` /
`do_install:append:<machine>()` blocks to the `tegra-bootfiles` bbappend. If
a kernel defconfig exists for that board in the fork, add a
`KBUILD_DEFCONFIG:<machine>` line to the kernel bbappend.

## Known gaps / next steps

* **Kernel fork not build-verified.** `SRCREV` is pinned to the
  `JetPack-7.2` branch HEAD at the time this was written -- re-verify/re-pin
  before relying on it. Local patch/`.cfg` files from the base recipe may
  not apply cleanly against the fork's tree (see comment in the bbappend).
* EEPROM disable (`cvb_eeprom_read_size` sed fix that this layer's
  `scarthgap` branch applied unconditionally in `tegra-bootfiles`) not
  carried over -- the target filename it patched may differ under
  `wrynose`'s BSP version and wasn't verified against the actual fetched
  source tree.
* Custom device tree (kernel-side DT deltas beyond boot-time pinmux) not
  addressed -- `wrynose` builds DTBs from source via the `tegra-devicetree`
  bbclass (`nvidia-kernel-oot-dtb`), unlike `scarthgap`'s precompiled `.dtb`
  blob install. See "Custom Device Tree" in
  `meta-tegra/docs/Creating-a-custom-MACHINE.md`.
* None of this has been run through an actual `bitbake` build -- no build
  environment (poky/bblayers.conf/local.conf) exists in this workspace yet.
