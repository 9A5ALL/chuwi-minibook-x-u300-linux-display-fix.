# Prepare and publish the update

Proposed tag: **v0.2.0**, subject to the current repository's existing tags.
Suggested commit: **Fix rotated-display tearing and document saved Cinnamon rotation**.

## Before uploading

This package was prepared from the original project ZIP because the live GitHub repository could not be accessed. Compare with the current repository first and retain any newer work. No remote commit, push, tag, or release has been created.

Review changes to README.md, and add CHANGELOG.md, docs/ROTATION.md, docs/TEARFREE.md, scripts/build-tearfree-noble.sh, scripts/collect-release-assets.sh, RELEASE_NOTES.md and this file. The original kernel patch, Secure Boot guide, MIT license and legacy scripts are retained.

The legacy watcher is no longer recommended. The build helper has not been executed on the target laptop; the manual build it describes was completed successfully there. The asset collector has fixture checks, not a test on the laptop's actual packages.

## Collect the actual tested binaries on the laptop

Copy this update's scripts folder into your local checkout, then run:

```bash
bash scripts/collect-release-assets.sh   "$HOME/tmp/chuwi-xorg-tearfree"   "$HOME/tmp/chuwi-v0.2.0-assets"
```

Use a new output directory. The archive delivered here does not contain the laptop's .deb packages. The collector copies both custom packages, original source archives, Debian packaging including adapted patches, build metadata, and generates SHA256SUMS. It never includes rollback binaries or private signing keys. Inspect maintainer identity/build paths in build metadata and the .changes file before public upload. The .changes file describes the complete build; only the two required binary packages are selected here.

If original source archives or metadata are missing, do not label the asset set complete. Retain the exact source and packaging needed to rebuild distributed binaries, and include the applicable upstream license notices. Have the author verify source availability and licensing before distributing Xorg binaries.

## GitHub web workflow

1. Open the existing repository and use **Add file → Upload files**. Upload the extracted update files into their corresponding paths, preserving any newer repository changes.
2. Review the diff and commit using the suggested subject.
3. Open **Releases → Draft a new release**, choose a free tag (suggested v0.2.0), target the reviewed commit, and paste RELEASE_NOTES.md as the description.
4. Attach all files from the completed asset directory, including SHA256SUMS and source/packaging archives. Optionally attach this documentation ZIP as a separate convenience download.
5. Review the release and publish it. If no binary assets are attached, explicitly say **source/documentation only; build locally**.

Do not upload the whole tmp directory or `.pc`, build trees, signing keys, personal monitor configuration, logs, or credentials. Do not replace a functioning kernel module with an unrelated prebuilt one.
