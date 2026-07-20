# navipad-xiao-ble

ZMK firmware for a 10-key navigation pad using Seeed XIAO BLE.
[ZMK Studio](https://zmk.dev/docs/features/studio) can be used to remap keys.

## Getting Started

### Setup

- Windows native: Run `scripts\setup.bat`
- devcontainer: **Reopen in Container** when prompted and wait for initial setup to complete (first launch only)

### Apply patches
- Run the **Apply patches** task after cloning and updating ZMK

### Build
- Press <kbd>Ctrl+Shift+B</kbd> and select **Build**

### Flash
- Windows: Press <kbd>Ctrl+Shift+B</kbd> and select **Flash**, then double-tap the reset button
- devcontainer: double-tap the reset button, then copy `build/zephyr/zmk.uf2` to the UF2 drive

## Updating ZMK

Edit the `revision:` line in [`firmware/config/west.yml`](firmware/config/west.yml), then run **Update ZMK**, **Apply patches**, and rebuild.
