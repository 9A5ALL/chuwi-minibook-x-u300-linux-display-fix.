# v0.2.0 — TearFree display and saved Cinnamon rotation

This update documents two improvements tested on a CHUWI MiniBook X Intel U300 running Linux Mint 22.3 Cinnamon on X11:

- A modesetting TearFree backport eliminates visible tearing when the native portrait panel is rotated to landscape.
- Cinnamon restores saved rotation after reboot and lid resume without a five-second polling script.

## Tested packages

`xserver-xorg-core` and `xserver-common`: `2:21.1.12-1ubuntu1.9+chuwi1`, built from Ubuntu Noble's `2:21.1.12-1ubuntu1.9` source.

Runtime confirmation: `modeset(0): TearFree: enabled`. No noticeable desktop or X-Plane 11 slowdown was reported; no controlled performance benchmark was performed.

## Scope

The earlier i915 DSI link-ready timeout workaround is unchanged. LightDM still rotates the login display once. Display Settings orientation selection remains unavailable. Kernel panel-orientation metadata has not been tested. These are one-device results.

Read `docs/TEARFREE.md` before installing binaries or building. Install the core and common packages together, save both original packages for rollback, and verify checksums. Package updates may replace the local patch. These binaries are for the documented amd64/Noble environment, not arbitrary distributions or kernels.

## Credits

The TearFree backport is sourced from Rahul Chandra's BLFS attachment, based on Xorg development code. The local adaptations preserve the overlapping software-rotation fix and correct an unmatched declaration for this source version. See the documentation for source links and licensing scope.
