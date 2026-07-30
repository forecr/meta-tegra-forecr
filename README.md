# meta-tegra-forecr

Forecr BSP layer for NVIDIA Jetson platforms, based on L4T. This layer
depends on [meta-tegra](https://github.com/OE4T/meta-tegra) (branch
`wrynose`).

* One custom `MACHINE` per real Forecr carrier board (no runtime
  board-selector variable) -- see [Architecture](#architecture).
* Boards covered so far: `forecr-dsboard-agx` (AGX Orin), and Thor's
  `forecr-dsboard-thrmax-t4000` / `forecr-dsboard-thrmax-t5000`.
* `forecr-dsboard-thrmax-t5000` has a **confirmed working end-to-end
  build + flash + boot on real hardware** -- see
  [Known gaps / next steps](#known-gaps--next-steps) for the full chain of
  bugs found and fixed to get there.
* Dev images boot to a passwordless `root` login (see `conf/local-confs/`)
  for board bring-up convenience; not meant for production images.
* AGX Orin config carries the same fixes preemptively but is not yet
  hardware-verified.

- [meta-tegra-forecr](#meta-tegra-forecr)
  - [Architecture](#architecture)
  - [Usage](#usage)
  - [Adding another board](#adding-another-board)
  - [Known gaps / next steps](#known-gaps--next-steps)


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
../build_bitbake.sh <MACHINE> [target]
```
(workspace root) sets up `bitbake`/`openembedded-core`, a per-MACHINE build
dir, and copies that MACHINE's `local.conf` from
`conf/local-confs/<MACHINE>.conf` in this layer into
`build-<MACHINE>/conf/local.conf` -- see its `-h` output.

`conf/local-confs/<MACHINE>.conf` (one per known machine) is a **complete**
`local.conf`, not a fragment -- it's copied over the build directory's
generated default wholesale. This is deliberate: a build directory is never
committed, so any fix made only there (like the `DISTRO_FEATURES`/
`PACKAGE_CLASSES` additions below) is invisible to the next person who
clones this layer unless it's saved back here. When you fix something in a
live `build-<MACHINE>/conf/local.conf`, copy the change back into the
matching file here.

Currently saved for `forecr-dsboard-agx`, `forecr-dsboard-thrmax-t4000`,
`forecr-dsboard-thrmax-t5000` -- each carries:
* `DISTRO_FEATURES:append = " pam"` -- `nodistro`'s baseline feature set
  (this workspace has no `meta-poky` distro-policy layer) doesn't include
  `pam`, which `core-image-weston`'s `weston-xwayland` needs.
* `PACKAGE_CLASSES = "package_deb"` -- dpkg/apt instead of OE-core's default
  opkg/ipk.
* `EXTRA_IMAGE_FEATURES:append = " package-management"` -- installs
  dpkg/apt into the image itself, not just as the build's internal package
  format.

For a MACHINE without a saved conf yet, `build_bitbake.sh` falls back to
patching `MACHINE` into the plain oe-core default and warns -- copy the
resulting `build-<MACHINE>/conf/local.conf` into
`conf/local-confs/<MACHINE>.conf` once it's working to save it for next
time.

## Adding another board

The pinmux source repo (`forecr_blog_source_files/Jetson_Pinmux/`) has ~16
board variants total (DSBOARD/MILBOARD/RAIBOARD x AGX/AGXMAX/AGXS/ORNX/ORNXS/XV2,
plus MILBOARD-THR for Thor).

**For an Orin board:** create `conf/machine/forecr-<board>.conf` requiring
`agx-orin.inc`/`orin-nx.inc`/`orin-nano.inc` + the right carrier `.inc`,
copy that board's three `.dtsi` files into
`recipes-bsp/tegra-binaries/tegra-bootfiles/forecr-<board>/` under
machine-name-based filenames, fix the pinmux file's `#include` line to match
the renamed GPIO file (it's used directly as a kernel-DT fragment -- no
wrapper needed), and add matching `SRC_URI:append:<machine>` /
`do_install:append:<machine>()` blocks to the `tegra-bootfiles` bbappend.

**For a Thor board:** same idea, but `TEGRA_FLASHVAR_PINMUX_CONFIG`/
`PMC_CONFIG` must point at a **wrapper** `.dts`, not the raw pinmux/
padvoltage content -- see `forecr-dsboard-thrmax/tegra264-mb1-bct-pinmux-
forecr-dsboard-thrmax.dts` for the ~7-line template
(`/dts-v1/; / { mb1_bct { padctl@0 { #include "<fragment>.dtsi" }; }; };`,
`pmc@0` for padvoltage). The board's actual pinmux/padvoltage content goes
in the `.dtsi` fragment the wrapper includes, not in the flashvar target
itself. Sanity-check with `cpp -nostdinc -undef -x assembler-with-cpp -I
<dir-with-your-files> -I <dir-with-stock-headers> <wrapper>.dts | dtc -I
dts -O dtb -o /dev/null -` before wiring it into the bbappend -- it should
exit 0 with only `unit_address_vs_reg` warnings.

If a kernel defconfig exists for the new board in the fork, add a
`KBUILD_DEFCONFIG:<machine>` line to the kernel bbappend.

## Known gaps / next steps

* **`core-image-minimal` builds successfully for `forecr-dsboard-thrmax-t5000`**
  (bare OE-core / `openembedded-core` wrynose + `bitbake` master, host: Ubuntu
  24.04 -- required disabling `kernel.apparmor_restrict_unprivileged_userns`,
  see workspace notes).
* **Real-hardware flashing progress, in the order these were found and fixed:**
  1. First attempt failed at `initrd-flash`'s `do_dump` step ("DTC command
     failed" / `OSError: 48`, which is `nverror.NvError_SystemCommand`, not a
     real POSIX errno). Root cause: `TEGRA_FLASHVAR_PINMUX_CONFIG`/
     `PMC_CONFIG` are each supposed to be a **thin wrapper** --
     `/dts-v1/; / { mb1_bct { padctl@0 { #include "<name>.dtsi" }; }; };` for
     pinmux, `pmc@0` for padvoltage -- around a *separate* `.dtsi` fragment
     carrying the actual content, matching NVIDIA's own stock
     `tegra264-mb1-bct-pinmux/padvoltage-p3834-xxxx-p4071-0000.dts`/`.dtsi`
     pair. The Forecr pinmux/padvoltage content from `forecr_blog_source_files`
     matches the fragment's shape (no `/dts-v1/` root), not the wrapper's.
     Fixed in `tegra-bootfiles_39.2.0.bbappend` +
     `tegra-bootfiles/forecr-dsboard-thrmax/` with two small hand-authored
     `.dts` wrappers. **Confirmed fixed on real hardware** -- RCM boot,
     `BR_CID` retrieval, and `bct_br` transfer all succeeded on the next
     attempt (this bug is Thor-specific; AGX Orin's pinmux mechanism is a
     kernel-DT fragment consumed differently and wasn't affected).
  2. Next, a USB write timeout (`Sending bct_br` / `ERROR: might be timeout
     in USB write`) turned out to be host-side USB autosuspend (TLP's udev
     rules setting `power/control=auto` on the recovery-mode device) --
     removing TLP and rebooting resolved it. Unrelated to this layer's
     content, purely a host environment issue; see
     `meta-tegra/docs/Flashing.md`'s troubleshooting section, which calls
     out TLP by name for exactly this symptom.
  3. With both of those fixed, flashing progressed to RCM boot succeeding
     repeatedly but never completing it -- the device kept re-enumerating as
     `0955:7026` (APX/recovery mode) every ~10-50s instead of transitioning
     to the ADB-mode flashing agent (confirmed via `journalctl -k`, boot-loop
     pattern). Root cause found by diffing against a separately-maintained,
     hand-tuned NVIDIA SDK Manager `Linux_for_Tegra` tree for this exact
     board (JetPack 7.1): our Forecr pinmux/padvoltage/gpio `.dtsi` content
     was confirmed byte-identical to that tree's (ruling out wrong pin
     values), but that tree's `tegra264-mb2-bct-common.dtsi` had one
     deliberate change stock doesn't: `cvb_eeprom_read_size = <0x100>` →
     `<0x0>`, i.e. the exact EEPROM-disable fix `scarthgap` applied for AGX
     Orin, now confirmed needed for Thor too. None of Forecr's boards
     populate the NVIDIA reference carrier's EEPROM. Fixed in both
     `do_install:append:forecr-dsboard-agx()` and
     `install_forecr_dsboard_thrmax_files()` in the same bbappend. Applied,
     but turned out **not** to be what was blocking the boot -- see next
     item. Left in place since the underlying fact (no EEPROM on these
     boards) is still true and worth having regardless.
  4. With BCT/pinmux and EEPROM both ruled out, and a genuine (not
     mid-retry-impatience) `NvError_Timeout` from `CheckUSBServiceInit`
     confirmed via a full uninterrupted `initrd-flash` run, we got a serial
     console on the board's debug port and watched a real flash attempt live.
     MB1/MB2/firmware loading all complete cleanly with no errors. The boot
     then hangs **forever** right after Hafnium (secure-world hypervisor)
     loads OP-TEE as a secure partition:
     ```
     INFO: Loading VM id 0x8001: optee.
     INFO: Hafnium initialisation completed
     WARNING: Stage-2 page fault: pc=0x1f9ce23800, vmid=0x8001, vcpu=0, vaddr=0x0, ipaddr=0x0, mode=0x2 0x7c
     NOTICE: Injecting Data Abort exception into VM 0x8001.
     WARNING: Stage-2 page fault: pc=0x200, vmid=0x8001, vcpu=0, vaddr=0x200, ipaddr=0x200, mode=0x4 0x7c
     NOTICE: Injecting Instruction Abort exception into VM 0x8001.
     ```
     repeating indefinitely -- OP-TEE null-derefs a few thousand bytes into
     its own init, and its exception handling is itself broken (faults
     trying to execute at `0x200`), so it never recovers and never hands
     control back. This is *why* USB/ADB never comes up during flashing:
     execution never reaches UEFI or the kernel at all. **This is unrelated
     to anything `meta-tegra-forecr` customizes** -- OP-TEE doesn't consume
     carrier-board pinmux/BCT, and secure-os is provided entirely by
     `meta-tegra` (`PREFERRED_PROVIDER_virtual/secure-os`,
     `TEGRA_OPTEE_VERSION`). Strongly suspect this reproduces identically on
     the stock `jetson-agx-thor-t5000`/devkit machine, i.e. a `wrynose`/T264
     OP-TEE build bug, not a Forecr-board issue (not confirmed against the
     stock machine directly -- just strongly implied by OP-TEE being
     carrier-agnostic). `USE_PREBUILT_OPTEE = "1"` (use NVIDIA's prebuilt
     secure-os binary instead of meta-tegra's from-source OP-TEE 4.6 build)
     added to all three `conf/local-confs/` files.
     **CONFIRMED FIXED** -- rebuilt with this setting and reflashed
     `forecr-dsboard-thrmax-t5000`: RCM boot proceeded past the point that
     previously hung forever, ADB came online normally, full partition flash
     completed, ending in `initrd-flash`'s own
     `"Flashing finished Successfully!!"`. **First fully successful
     build+flash on real Forecr Thor hardware.** Booting into the flashed
     OS (post-flash power cycle, watching for a kernel boot + login prompt
     on serial) is the next thing to confirm -- getting `initrd-flash` to
     report success confirms the boot0/secure-world/bootloader chain works,
     not that the actual Linux userspace comes up cleanly.
* Two real bugs were found and fixed getting the kernel fork building (both
  fixed directly in `linux-noble-nvidia-tegra_6.8.bbappend`, worth reading
  the comments there if porting this pattern elsewhere):
  1. `do_kernel_metadata` sits in the same
     after-`do_validate_branches`/before-`do_patch` window our source-swap
     task was hooked into, and isn't guaranteed to run after it -- fixed by
     also ordering explicitly before `do_kernel_metadata`.
  2. Flattening the fork's `kernel/kernel-noble/` tree up to `${S}` with
     `mv ${S}/*` leaves `.git` behind untouched (glob doesn't match
     dotdirs), so it keeps describing the original nested path layout.
     `kern-tools`' patch application is git-index-aware even in its "apply"
     fallback, so every patch failed with "does not exist in index" against
     files that were genuinely present on disk. Fixed by re-`git init`-ing
     against the flattened tree.
  `SRCREV` is still pinned to the `JetPack-7.2` branch HEAD at the time this
  was written -- re-verify/re-pin periodically.
* Custom device tree (kernel-side DT deltas beyond boot-time pinmux) not
  addressed -- `wrynose` builds DTBs from source via the `tegra-devicetree`
  bbclass (`nvidia-kernel-oot-dtb`), unlike `scarthgap`'s precompiled `.dtb`
  blob install. See "Custom Device Tree" in
  `meta-tegra/docs/Creating-a-custom-MACHINE.md`.
* Only tested with `core-image-minimal`. `core-image-weston` needed
  `DISTRO_FEATURES:append = " pam"` (now in the template) -- other image
  targets may surface more `nodistro`-baseline gaps the same way.
