#!/usr/bin/env bash
#
# build_bitbake.sh -- set up and drive a bitbake build for this workspace.
#
# Usage:
#   ./build_bitbake.sh [-y] [-h] <MACHINE> [bitbake-target]
#
# Example:
#   ./build_bitbake.sh forecr-dsboard-thrmax-t5000
#   ./build_bitbake.sh -y forecr-dsboard-agx core-image-minimal
#
# What it does:
#   1. Checks (and optionally installs) host build dependencies.
#   2. Clones bitbake + openembedded-core next to this script if missing
#      (meta-tegra / meta-tegra-forecr are expected to already be here).
#   3. Creates/updates a per-MACHINE build directory's local.conf/bblayers.conf.
#   4. Runs a couple of `bitbake -e` / `bitbake-layers` sanity checks so a
#      typo in a machine .conf or bbappend fails fast instead of two hours
#      into a build.
#   5. Runs bitbake for the requested target (default: core-image-minimal).
#
# NOTE: the openembedded-core branch (wrynose) is confirmed to exist and
# match meta-tegra's LAYERSERIES_COMPAT. The bitbake branch below (master)
# is a best-effort pairing -- bitbake doesn't use codename branches, and
# wrynose is oe-core's current development track with no numbered release
# yet. If bitbake refuses to run due to a version mismatch, check
# meta/conf/bitbake.conf's BB_MIN_VERSION in your openembedded-core checkout
# and switch to the matching bitbake release branch instead.

set -euo pipefail

THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
META_TEGRA_FORECR_DIR="$(dirname ${THIS_SCRIPT})"
YOCTO_DIR="$(readlink -f ${META_TEGRA_FORECR_DIR}/..)"

BITBAKE_URI="https://git.openembedded.org/bitbake"
BITBAKE_BRANCH="master"
BITBAKE_DIR="$YOCTO_DIR/bitbake"

OECORE_URI="https://git.openembedded.org/openembedded-core"
OECORE_BRANCH="wrynose"
OECORE_DIR="$YOCTO_DIR/openembedded-core"

META_OE_URI="https://git.openembedded.org/meta-openembedded"
META_OE_BRANCH="wrynose"
META_OE_DIR="$YOCTO_DIR/meta-openembedded"

META_TEGRA_DIR="$YOCTO_DIR/meta-tegra"

# Sub-layers inside the meta-openembedded monorepo that deepstream (and its
# DEPENDS chain -- grpc, protobuf, jsoncpp, mosquitto, python bindings) need.
# Each is its own BBFILE_COLLECTIONS entry, added to bblayers.conf separately.
# (deepstream itself, plus the handful of its DEPENDS not packaged anywhere
# else -- yaml-cpp-080, opentelemetry-cpp-1230, python3-cuda,
# python3-pyclibrary -- are vendored directly into meta-tegra-forecr's own
# recipes-devtools/ and recipes-support/, rather than pulling in the whole
# meta-tegra-community layer for a handful of recipes.)
META_OE_SUBLAYERS=(
    "$META_OE_DIR/meta-oe"
    "$META_OE_DIR/meta-python"
    "$META_OE_DIR/meta-networking"
)

KNOWN_MACHINES=(
    forecr-dsboard-agx
    forecr-dsboard-thrmax-t4000
    forecr-dsboard-thrmax-t5000
)

REQUIRED_PACKAGES=(
    gawk wget git diffstat unzip texinfo gcc build-essential chrpath
    socat cpio python3 python3-pip python3-pexpect xz-utils debianutils
    iputils-ping python3-git python3-jinja2 python3-subunit zstd liblz4-tool
    file locales libacl1
    bash bmap-tools cpp device-tree-compiler gdisk libxml2-utils tar udisks2 usbutils
)

ASSUME_YES=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [-y] [-h] <MACHINE> [bitbake-target]

Known meta-tegra-forecr MACHINEs:
$(for m in "${KNOWN_MACHINES[@]}"; do echo "  - $m"; done)

  -y   assume "yes" for installing missing host packages (non-interactive)
  -h   show this help

Example:
  $(basename "$0") forecr-dsboard-thrmax-t5000
EOF
    exit "${1:-1}"
}

while getopts "yh" opt; do
    case "$opt" in
        y) ASSUME_YES=1 ;;
        h) usage 0 ;;
        *) usage 1 ;;
    esac
done
shift $((OPTIND - 1))

[ $# -ge 1 ] || usage
MACHINE="$1"
TARGET="${2:-core-image-minimal}"

known=0
for m in "${KNOWN_MACHINES[@]}"; do
    [ "$MACHINE" = "$m" ] && known=1
done
if [ "$known" -eq 0 ]; then
    echo "warning: '$MACHINE' is not one of the known meta-tegra-forecr machines (see -h) -- continuing anyway" >&2
fi

BUILD_DIR="$YOCTO_DIR/build-$MACHINE"

# --- 1. host package check --------------------------------------------------
echo "==> Checking host build dependencies..."
if ! command -v dpkg >/dev/null 2>&1; then
    echo "warning: dpkg not found -- skipping dependency check (not a Debian/Ubuntu host?)" >&2
else
    missing=()
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        echo "Missing packages: ${missing[*]}"
        if [ "$ASSUME_YES" -eq 1 ]; then
            reply="y"
        else
            read -rp "Install them now with sudo apt install? [y/N] " reply
        fi
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            sudo apt-get update
            sudo apt-get install -y "${missing[@]}"
        else
            echo "Continuing without installing -- the build may fail." >&2
        fi
    else
        echo "All required host packages are present."
    fi
fi

# --- 2. fetch bitbake + openembedded-core if missing ------------------------
clone_if_missing() {
    local dir="$1" uri="$2" branch="$3"
    if [ -d "$dir/.git" ]; then
        echo "==> $(basename "$dir") already present at $dir (branch: $(git -C "$dir" branch --show-current 2>/dev/null || echo '?')) -- leaving it alone"
    else
        echo "==> Cloning $uri (branch $branch) into $dir"
        git clone -b "$branch" "$uri" "$dir"
    fi
}

clone_if_missing "$BITBAKE_DIR" "$BITBAKE_URI" "$BITBAKE_BRANCH"
clone_if_missing "$OECORE_DIR" "$OECORE_URI" "$OECORE_BRANCH"
clone_if_missing "$META_OE_DIR" "$META_OE_URI" "$META_OE_BRANCH"

for d in "$META_TEGRA_DIR" "$META_TEGRA_FORECR_DIR"; do
    if [ ! -d "$d/.git" ]; then
        echo "error: expected layer not found at $d -- clone it first" >&2
        exit 1
    fi
done

# --- 3. build directory / conf setup ----------------------------------------
echo "==> Setting up build directory: $BUILD_DIR"
# oe-init-build-env must be sourced (not executed) so it can export env vars
# into this shell; since we're already inside this script's own subshell,
# that's fine -- the bitbake invocation later reuses the same shell.
#
# oe-init-build-env (and the scripts it pulls in) reference variables like
# BBSERVER without defaults and aren't written to be `set -u`-safe, so relax
# strict mode just for this call.
set +euo pipefail
source "$OECORE_DIR/oe-init-build-env" "$BUILD_DIR" >/dev/null
set -euo pipefail

BBLAYERS_CONF="$BUILD_DIR/conf/bblayers.conf"
LOCAL_CONF="$BUILD_DIR/conf/local.conf"

for layer in "$META_TEGRA_DIR" "${META_OE_SUBLAYERS[@]}" "$META_TEGRA_FORECR_DIR"; do
    grep -qF "$layer" "$BBLAYERS_CONF" 2>/dev/null || bitbake-layers add-layer "$layer"
done

# Per-MACHINE local.conf lives in the layer itself (conf/local-confs/) so it
# carries over when someone else clones this repo, rather than living only
# in a build directory that never gets committed. If one exists for this
# MACHINE, it fully replaces the oe-init-build-env-generated default;
# otherwise fall back to just patching MACHINE into the generated default
# (works for a MACHINE nobody has saved a canned conf for yet).
CANNED_LOCAL_CONF="$META_TEGRA_FORECR_DIR/conf/local-confs/$MACHINE.conf"
if [ -f "$CANNED_LOCAL_CONF" ]; then
    cp "$CANNED_LOCAL_CONF" "$LOCAL_CONF"
    echo "==> Copied $CANNED_LOCAL_CONF to $LOCAL_CONF"
else
    echo "warning: no canned local.conf for '$MACHINE' at $CANNED_LOCAL_CONF -- using the generated default with MACHINE patched in. Consider saving one (see meta-tegra-forecr/README.md)." >&2
    # Idempotent: drop any previous MACHINE line (default sample or a prior
    # run of this script) and append a fresh hard assignment so it always wins.
    sed -i '/^MACHINE /d' "$LOCAL_CONF"
    echo "MACHINE = \"$MACHINE\"" >> "$LOCAL_CONF"
fi
echo "==> MACHINE set to '$MACHINE' in $LOCAL_CONF"

# --- 4. pre-build sanity checks ----------------------------------------------
echo "==> Verifying layers and override resolution before building..."
bitbake-layers show-layers

echo "--- tegra-bootfiles pinmux/BCT overrides ---"
bitbake -e tegra-bootfiles | grep -E '^(TEGRA_FLASHVAR_PINMUX_CONFIG|TEGRA_FLASHVAR_PMC_CONFIG|MACHINEOVERRIDES)=' || \
    echo "warning: could not read expected TEGRA_FLASHVAR_*/MACHINEOVERRIDES values" >&2

echo "--- kernel fork/defconfig overrides ---"
bitbake -e virtual/kernel | grep -E '^(SRCREV|SRCBRANCH|KBUILD_DEFCONFIG)=' || \
    echo "warning: could not read expected kernel SRCREV/SRCBRANCH/KBUILD_DEFCONFIG values" >&2

# --- 5. build -----------------------------------------------------------------
echo "==> Building '$TARGET' for MACHINE='$MACHINE'"
bitbake "$TARGET"

echo "==> Build finished. Images are under:"
echo "    $BUILD_DIR/tmp/deploy/images/$MACHINE/"
echo "See meta-tegra/docs/Flashing.md for how to flash the result."
