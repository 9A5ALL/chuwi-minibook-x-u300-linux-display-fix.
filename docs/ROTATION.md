# Rotation: migrate away from the five-second watcher

## Tested configuration

Linux Mint 22.3, Cinnamon 6.6.9, X11, DSI-1. Native mode 1200×1920 at 50 Hz, XRandR rotation `right`.

Cinnamon uses `~/.config/cinnamon-monitors.xml`, not `monitors.xml`. The tested machine initially had only configurations paired with external monitors. A standalone DSI-1 configuration was copied from an existing logical monitor, retaining mode, refresh rate, scale, primary flag and `right` transform, with position reset to 0,0.

After adding that configuration and disabling the watcher, reboot and lid close/open retained correct rotation with no visible corrective flip. This does not establish that the panel orientation is correctly described by firmware or the kernel.

## Migration

Keep a terminal open. Disconnect external monitors. Back up the configuration and autostart file first:

```bash
cp -p ~/.config/cinnamon-monitors.xml ~/.config/cinnamon-monitors.xml.before-rotation-test
cp -p ~/.config/autostart/chuwi-display.desktop ~/.config/autostart/chuwi-display.desktop.backup
```

If Display Settings can save a correct standalone layout, use it. If its orientation control is disabled and only external-monitor configurations exist, use the following one-time edit with the display already working correctly:

```bash
python3 - <<'PYTHON'
from pathlib import Path
import copy
import xml.etree.ElementTree as ET
path = Path.home() / '.config/cinnamon-monitors.xml'
tree = ET.parse(path)
root = tree.getroot()
standalone = any(len(c.findall('.//monitor')) == 1 and c.findtext('.//connector') == 'DSI-1' for c in root.findall('configuration'))
if not standalone:
    panel = next(lm for lm in root.findall('.//logicalmonitor') if lm.findtext('monitor/monitorspec/connector') == 'DSI-1')
    panel = copy.deepcopy(panel)
    assert panel.findtext('transform/rotation') == 'right', 'Expected the tested right rotation'
    panel.find('x').text = '0'
    panel.find('y').text = '0'
    ET.SubElement(root, 'configuration').append(panel)
    tree.write(path, encoding='unicode')
    print('Added standalone panel configuration.')
else:
    print('Standalone configuration already exists; inspect its rotation if needed.')
PYTHON
```

Disable the watcher autostart entry, then stop its running process (an absent process is harmless):

```bash
mv ~/.config/autostart/chuwi-display.desktop ~/.config/autostart/chuwi-display.desktop.disabled
pgrep -af 'chuwi-display.sh'
pkill -f '^/bin/bash /home/[^/]+/.local/bin/chuwi-display.sh$'
```

The process pattern matches the tested Bash invocation. If a different invocation is listed, identify its PID and stop that specific process. Do not kill unrelated display/session processes.

Log out/in, reboot, and test lid close/open. Also test external monitor attach/detach. External monitor migration behavior has not been validated by this update.

## LightDM remains enabled

`/etc/lightdm/lightdm.conf.d/90-chuwi-display.conf` still contains:

```ini
[Seat:*]
display-setup-script=/usr/local/bin/chuwi-login-display.sh
```

Its script runs `xrandr --output DSI-1 --rotate right` once when LightDM sets up the display. Cinnamon handles saved configuration after login. Do not remove the LightDM configuration as part of this migration.

## Recovery

To correct the current display:

```bash
xrandr --output DSI-1 --rotate right
```

To restore legacy polling:

```bash
mv ~/.config/autostart/chuwi-display.desktop.disabled ~/.config/autostart/chuwi-display.desktop
```

Log out/in. To undo the XML edit, restore `cinnamon-monitors.xml.before-rotation-test` while logged out of Cinnamon, for example from a text console. Keep the backup until the tests pass.

## Remaining work

The Display Settings orientation selector is still unavailable on the tested system. Kernel `panel_orientation` metadata and removing the LightDM one-shot command are future work, not completed fixes.
