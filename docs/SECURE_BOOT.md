# Secure Boot and locally built i915 module

**Do not distribute private signing keys.** Each machine should create and enroll its own Machine Owner Key (MOK). This document is a reference workflow, not a turnkey installer.

1. Check Secure Boot state with `mokutil --sb-state` and verify `uname -r`.
2. Build the module against the **exact running kernel build**. Ensure `modinfo -F vermagic i915.ko` matches that kernel.
3. Create a local signing key and certificate, for example:

   ```bash
   openssl req -new -x509 -newkey rsa:3072 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 3650 -subj '/CN=Local i915 module signing/'
   chmod 600 MOK.priv
   ```

4. Sign the built module using the matching kernel build's `scripts/sign-file`:

   ```bash
   /path/to/kernel-source/scripts/sign-file sha256 MOK.priv MOK.der /path/to/i915.ko
   ```

5. Import the public certificate with `sudo mokutil --import MOK.der`, reboot, and complete MOK enrollment in firmware's MOK manager. Verify with `mokutil --test-key MOK.der`.
6. Keep a backup of the stock module and initramfs. Install the signed module for **the matching kernel only** (on the tested system, `/lib/modules/7.0.0-38-generic/updates/i915.ko`), run `sudo depmod -a 7.0.0-38-generic`, ensure the initramfs includes the module, then run `sudo update-initramfs -u -k 7.0.0-38-generic`.
7. Reboot and check `modinfo -n i915`, `journalctl -k -b | grep -iE 'DSI|i915'`, and display operation.

**Important:** The command `modinfo -n i915` shows the module selected on disk, not necessarily the file loaded at boot. Verify the initramfs content and loaded module/signature separately when troubleshooting. Kernel updates require a fresh compatible build/sign/install. If the screen goes blank, recover using a known-good kernel or external console/SSH, restore the stock module and initramfs, and reboot.
