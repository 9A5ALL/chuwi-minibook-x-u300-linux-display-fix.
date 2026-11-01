#!/usr/bin/env bash
# Collect already-built packages and exact source packaging. No root required.
set -euo pipefail
build_dir=${1:?Usage: collect-release-assets.sh BUILD_DIRECTORY NEW_OUTPUT_DIRECTORY}
output_dir=${2:?Usage: collect-release-assets.sh BUILD_DIRECTORY NEW_OUTPUT_DIRECTORY}
build_dir=$(realpath "$build_dir")
[[ ! -e "$output_dir" ]] || { echo 'Output directory must not already exist' >&2; exit 1; }
version='2:21.1.12-1ubuntu1.9+chuwi1'
core="$build_dir/xserver-xorg-core_21.1.12-1ubuntu1.9+chuwi1_amd64.deb"
common="$build_dir/xserver-common_21.1.12-1ubuntu1.9+chuwi1_all.deb"
for file in "$core" "$common"; do
  [[ -f "$file" ]] || { printf 'Missing: %s\n' "$file" >&2; exit 1; }
  [[ $(dpkg-deb -f "$file" Version) == "$version" ]] || { echo 'Version mismatch' >&2; exit 1; }
done
source_dir="$build_dir/xorg-server-21.1.12"
[[ -d "$source_dir/debian/patches" ]] || { echo 'Exact source packaging missing' >&2; exit 1; }
mkdir -p "$output_dir"
output_dir=$(realpath "$output_dir")
cp "$core" "$common" "$output_dir/"
# Include all Debian packaging, original source archives, and source metadata.
# No signing keys, user configuration, or runtime logs are collected.
tar -C "$source_dir" -czf "$output_dir/chuwi-xorg-debian-packaging.tar.gz" debian
shopt -s nullglob
sources=("$build_dir"/xorg-server_21.1.12.orig.tar.* "$build_dir"/xorg-server_21.1.12-1ubuntu1.9.debian.tar.* "$build_dir"/xorg-server_21.1.12-1ubuntu1.9.dsc)
((${#sources[@]} > 0)) || { echo 'Original source archives missing; keep the output as incomplete' >&2; exit 1; }
cp "${sources[@]}" "$output_dir/"
metadata=("$build_dir"/xorg-server_21.1.12-1ubuntu1.9+chuwi1_amd64.buildinfo "$build_dir"/xorg-server_21.1.12-1ubuntu1.9+chuwi1_amd64.changes)
((${#metadata[@]} == 2)) || { echo 'Build metadata missing' >&2; exit 1; }
cp "${metadata[@]}" "$output_dir/"
cd "$output_dir"
sha256sum -- * > SHA256SUMS
printf 'Release assets collected in %s\nReview maintainer identity and build paths in metadata before publishing.\n' "$output_dir"
