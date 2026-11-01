# TearFree backport for the rotated internal panel

## Exact tested environment

- CHUWI MiniBook X Intel U300; one device.
- Linux Mint 22.3 Cinnamon 6.6.9, X11; Intel i915 / Mesa iris / Xorg modesetting.
- Kernel 7.0.0-38-generic with the separate DSI initialization workaround.
- Original source/binary package: `2:21.1.12-1ubuntu1.9` (Ubuntu Noble).
- Locally built packages: `xserver-xorg-core` and `xserver-common`, both `2:21.1.12-1ubuntu1.9+chuwi1`.
- Internal display: DSI-1, native 1200×1920 at 50 Hz, rotated `right`.

Before: vertical tear on the landscape display, absent with rotation disabled; `Option "TearFree" is not used`.
After: `TearFree: enabled`; tearing absent. Desktop and X-Plane 11 showed no noticeable slowdown to the tester. This is an observation, not a benchmark or broad compatibility claim.

## Source and adaptations

External backport by Rahul Chandra, dated 2023-07-20, based on Xorg development code, originally targeting 21.1.8:

- [BLFS patch page](https://wiki.linuxfromscratch.org/blfs/attachment/ticket/18316/xorg-server-21.1.8-tearfree-backport.patch)
- [Raw patch](https://wiki.linuxfromscratch.org/blfs/raw-attachment/ticket/18316/xorg-server-21.1.8-tearfree-backport.patch)

Adaptations made during the successful build:

1. Exclude its meson.build hunk, whose version context differs; retain the minimum Meson version change to >=0.56.0 separately.
2. Apply the TearFree backport first in the Quilt series. It incorporates the functionality of Ubuntu's `modesetting-Fix-dirty-updates-for-sw-rotation.patch` (upstream commit db9e9d45e8ba73510f11eb9e534c176102f6623e). Comment out that duplicate series entry, retaining the patch file. Keep the other distribution patches.
3. Remove the backport's unmatched `PixmapScreenInit` declaration from include/pixmap.h. Otherwise generated sdksyms references an implementation absent from this source tree and linking fails.

The package version is 21.1.12 although meson.build in this source reports 21.1.11. Do not edit the upstream version merely to match the package name.

## Build

Enable **Source code repositories** in Mint Software Sources (`sudo mintsources`), then:

```bash
sudo /usr/bin/apt update
sudo /usr/bin/apt install build-essential devscripts quilt curl python3
sudo /usr/bin/apt build-dep xorg-server
DEBFULLNAME='Your Name' DEBEMAIL='you@example.com' bash scripts/build-tearfree-noble.sh
```

The helper creates a new workspace, downloads the exact source and external patch, applies the documented adaptations and builds with two jobs. It never installs packages. The helper has syntax/fixture checks only; its underlying manual procedure succeeded on the target laptop. Review the downloaded upstream patch before building it. The downloaded file and its SHA256 are retained with the build for provenance; this is not an independently pinned upstream hash.

The exact source version must remain available in your configured repositories. If unavailable, stop and port to the new source version; do not silently substitute versions. Mint's `apt` wrapper can handle commands differently, so the examples use `/usr/bin/apt` explicitly.

## Install with local rollback packages

Before installation, save both originals:

```bash
mkdir -p ~/tmp/chuwi-xorg-tearfree/rollback
cd ~/tmp/chuwi-xorg-tearfree/rollback
/usr/bin/apt download 'xserver-xorg-core=2:21.1.12-1ubuntu1.9' 'xserver-common=2:21.1.12-1ubuntu1.9'
```

Stop if either download fails. Change to the directory containing your newly built packages, then:

```bash
sudo /usr/bin/apt install   ./xserver-common_21.1.12-1ubuntu1.9+chuwi1_all.deb   ./xserver-xorg-core_21.1.12-1ubuntu1.9+chuwi1_amd64.deb
```

Both packages are required because of the core package's versioned dependency. Do not install every .deb produced by the source build. If APT proposes removals, cancel and investigate.

Ensure the active Xorg Device section using `Driver "modesetting"` contains:

```text
Option "TearFree" "true"
```

On the tested machine this option already existed and simply became effective after installing the patched server. Inspect `/etc/X11/xorg.conf` and `/etc/X11/xorg.conf.d/` before editing; avoid creating competing Device sections. Do not switch to the legacy Intel DDX driver.

Save work and reboot. Verify:

```bash
dpkg-query -W xserver-xorg-core xserver-common
grep -i tearfree /var/log/Xorg.0.log
```

Expected runtime line: `modeset(0): TearFree: enabled`. Test window motion and your normal applications. Kernel rotation scripts do not need to be re-enabled for TearFree.

## Rollback

If the graphical session fails, use Ctrl+Alt+F3 and log in. Restore both original packages:

```bash
cd ~/tmp/chuwi-xorg-tearfree/rollback
sudo dpkg -i   ./xserver-common_21.1.12-1ubuntu1.9_all.deb   ./xserver-xorg-core_21.1.12-1ubuntu1.9_amd64.deb
sudo reboot
```

The original server ignores TearFree. This rollback does not modify the separate i915 module workaround.

## Updates and licensing

A newer distribution Xorg package may replace the custom version and remove TearFree support. Recheck the runtime log after Xorg updates. Do not indefinitely hold security updates. Rebuild against a newer source after reviewing patch applicability.

No prebuilt binaries are included in this documentation archive: the tested binaries remain on the laptop. Release binaries should include both required packages, checksums, exact adapted source patches and build metadata. Preserve upstream copyright/license notices. The repository MIT license covers its own helper scripts/documentation, not externally sourced Xorg code.
