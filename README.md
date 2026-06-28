# navipad-xiao-ble

ZMK firmware for a 10-key navigation pad using Seeed XIAO BLE.
[ZMK Studio](https://zmk.dev/docs/features/studio) can be used to remap keys.

## Getting Started

### Setup
- Open this repository in VS Code
- **Reopen in Container** when prompted
- Wait for initial setup to complete (first launch only)

### Build
- Press **Ctrl+Shift+B**

### Flash
- Double-tap the reset button, then copy `build/zephyr/zmk.uf2` to the UF2 drive

## Updating ZMK

Edit the `revision:` line in [`config/west.yml`](config/west.yml), then run `west update` and rebuild.
