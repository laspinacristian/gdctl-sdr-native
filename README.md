# gdctl-sdr-native

A user service that keeps the `sdr-native` color mode of a GNOME (Mutter) display enabled after every monitor change: rotation, external monitor, resume from suspend.

## Requirements

- GNOME on Wayland with `gdctl` (it ships with Mutter)
- python3 with PyGObject
- A panel that supports `sdr-native`: check with `gdctl show --properties | grep -i color`

```bash
sudo dnf install python3-gobject   # Fedora (preinstalled on Workstation)
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash
```

It acts on the internal panel `eDP-1`. For another one, run `systemctl --user edit gdctl-sdr-native.service` and add:

```ini
[Service]
Environment=GDCTL_SDR_CONNECTOR=eDP-2
```

Run the same command again to update.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash -s -- --uninstall
```

## License

[MIT](LICENSE)
