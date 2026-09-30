# gdctl-sdr-native

Keeps the **`sdr-native`** color mode enabled on a GNOME (Mutter) display after every monitor reconfiguration.

On some laptops Mutter falls back to the default color mode whenever the display is reconfigured: rotating a 2-in-1 into tablet mode, plugging in an external monitor, resuming from suspend. This small user service listens for Mutter's `MonitorsChanged` D-Bus signal and, when the target panel has lost `sdr-native`, reapplies the **current** layout with only the color mode changed. Resolution, refresh rate, scale, rotation, position and any external monitors are preserved. The new layout is checked with `gdctl set --verify` before it is applied.

Written for the Lenovo Yoga 9i 2-in-1 (see [linux-yoga9i-gen11-aura](https://github.com/laspinacristian/linux-yoga9i-gen11-aura)), but it works on any panel that offers `sdr-native`.

## Requirements

- GNOME on Wayland with `/usr/bin/gdctl` (shipped with Mutter). Tested on Fedora 44, GNOME 50 / Mutter 50.4.
- `python3` with PyGObject (`python3-gobject` on Fedora, preinstalled on Workstation).

Check that your panel supports the mode:

```bash
gdctl show --properties | grep -i color
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash
```

No root needed. It installs:

- `~/.local/bin/gdctl-sdr-native-watch`: the watcher
- `~/.config/systemd/user/gdctl-sdr-native.service`: starts it with your graphical session

and enables the service.

## Configuration

The target connector defaults to `eDP-1`, the usual internal laptop panel. To use another one, add an override:

```bash
systemctl --user edit gdctl-sdr-native.service
```

```ini
[Service]
Environment=GDCTL_SDR_CONNECTOR=eDP-2
```

## Logs

```bash
systemctl --user status gdctl-sdr-native.service
journalctl --user -u gdctl-sdr-native.service -f
```

## Update / uninstall

Run the install command again to update. To uninstall:

```bash
curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash -s -- --uninstall
```

## License

[MIT](LICENSE)
