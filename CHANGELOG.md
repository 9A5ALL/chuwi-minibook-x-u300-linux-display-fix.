# Changelog

## Proposed v0.2.0 — 2026-11-01

- Document the tested modesetting TearFree backport for Ubuntu Noble Xorg 21.1.12-1ubuntu1.9.
- Record local package version 2:21.1.12-1ubuntu1.9+chuwi1 and successful runtime verification.
- Document overlapping Ubuntu rotation patch and removal of an unmatched PixmapScreenInit declaration.
- Replace recommended five-second rotation polling with saved Cinnamon configuration.
- Retain one-shot LightDM rotation and legacy watcher fallback.
- Add reproducible build helper, release asset collector, installation and rollback instructions.
- Retain the original i915 timeout patch and Secure Boot documentation.

Status: one-device testing; no controlled performance benchmark. New helper scripts reproduce the documented procedure but have not been executed on the target laptop.
