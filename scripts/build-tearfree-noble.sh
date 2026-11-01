#!/usr/bin/env bash
# Build the exact tested Noble source package; never install it automatically.
set -euo pipefail
base_version='2:21.1.12-1ubuntu1.9'
custom_version="${base_version}+chuwi1"
workspace=$(mktemp -d "${TMPDIR:-/tmp}/chuwi-xorg-build.XXXXXXXX")
printf 'Build workspace: %s\n' "$workspace"
cd "$workspace"
/usr/bin/apt source "xorg-server=$base_version"
source_dir="$workspace/xorg-server-21.1.12"
[[ -d "$source_dir/debian/patches" ]] || { echo 'Unexpected source layout' >&2; exit 1; }
curl --fail --location --retry 2 \
  'https://wiki.linuxfromscratch.org/blfs/raw-attachment/ticket/18316/xorg-server-21.1.8-tearfree-backport.patch' \
  -o upstream-tearfree.patch
sha256sum upstream-tearfree.patch > upstream-tearfree.patch.sha256
python3 - <<'PYTHON'
from pathlib import Path
raw = Path('upstream-tearfree.patch').read_text()
assert 'PixmapScreenInit' in raw and 'OPTION_TEARFREE' in raw, 'Unexpected upstream patch'
parts = raw.split('diff --color ')
assert len(parts) > 2, 'Unexpected patch format'
removed = 0
out = parts[0]
for part in parts[1:]:
    if part.splitlines()[0].split()[-1].endswith('/meson.build'):
        removed += 1
    else:
        out += 'diff --color ' + part
assert removed == 1, 'Expected one meson.build section'
Path('tearfree-adjusted.patch').write_text(out)
PYTHON
cd "$source_dir"
[[ $(dpkg-parsechangelog -S Version) == "$base_version" ]] || exit 1
export QUILT_PATCHES=debian/patches
# Depending on source format, extraction can leave distribution patches applied.
if [[ -s .pc/applied-patches ]]; then quilt pop -a; fi
quilt import -P chuwi-tearfree.patch ../tearfree-adjusted.patch
python3 - <<'PYTHON'
from pathlib import Path
p = Path('debian/patches/series')
lines = p.read_text().splitlines(keepends=True)
target = 'modesetting-Fix-dirty-updates-for-sw-rotation.patch'
idx = [i for i,l in enumerate(lines) if l.strip() and not l.lstrip().startswith('#') and l.split()[0] == target]
assert len(idx) == 1, 'Expected one Ubuntu rotation patch'
lines[idx[0]] = '# Included in chuwi-tearfree.patch: ' + lines[idx[0]]
p.write_text(''.join(lines))
PYTHON
quilt push -a
quilt new chuwi-fix-pixmap-declaration.patch
quilt add include/pixmap.h meson.build
python3 - <<'PYTHON'
from pathlib import Path
p = Path('include/pixmap.h')
lines = p.read_text().splitlines(keepends=True)
found = [l for l in lines if 'PixmapScreenInit' in l]
assert len(found) == 1 and found[0].lstrip().startswith('extern '), 'Unexpected declaration'
p.write_text(''.join(l for l in lines if 'PixmapScreenInit' not in l))
p = Path('meson.build')
s = p.read_text()
old = "meson_version: '>= 0.47.0'"
assert s.count(old) == 1, 'Unexpected Meson requirement'
p.write_text(s.replace(old, "meson_version: '>= 0.56.0'"))
PYTHON
quilt refresh
# Supply DEBFULLNAME and DEBEMAIL in your environment for maintainer identity.
: "${DEBFULLNAME:?Set DEBFULLNAME before running this script}"
: "${DEBEMAIL:?Set DEBEMAIL before running this script}"
export DEBFULLNAME DEBEMAIL
dch --newversion "$custom_version" --distribution noble \
  'Backport modesetting TearFree support for the rotated CHUWI display.'
dpkg-buildpackage -b -uc -us -j2 2>&1 | tee "$workspace/build.log"
printf '\nPackages and build.log: %s\nNo packages were installed.\n' "$workspace"
