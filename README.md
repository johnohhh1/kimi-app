# Kimi Desktop for Ubuntu 26.04+

Native desktop app for [Kimi](https://kimi.moonshot.cn) (Moonshot AI), rebuilt for Ubuntu 26.04+ using [Pake](https://github.com/tw93/Pake) v3 with Tauri v2.

## Why this exists

The official Kimi desktop `.deb` (from [kimi-moonshot](https://github.com/kimi-moonshot/kimi-moonshot)) is built with Tauri v1, which hard-links `libwebkit2gtk-4.0.so.37`. That library was dropped from Ubuntu after 22.04 — so the official package fails to install on Ubuntu 24.04+ and 26.04 with missing dependency errors.

This rebuild uses Tauri v2, which links against `libwebkit2gtk-4.1` (the current version shipped in Ubuntu 24.04+ and 26.04).

## Install

```bash
sudo dpkg -i kimi_1.0.0_amd64.deb
```

Or rebuild from source (see below).

## What changed from upstream

- **Tauri v1 → v2**: Links against `libwebkit2gtk-4.1` instead of the removed `4.0`
- **OAuth/SSO support**: Built with `--new-window` so Google and other OAuth providers work in-app instead of being blocked
- **System tray**: Enabled for Linux

## Rebuild from source

Prerequisites:

```bash
# Rust (>= 1.85)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node.js (>= 22)
# Use your preferred method (nvm, brew, etc.)

# Linux build dependencies
sudo apt install libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# Pake CLI
npm install -g pake-cli
```

Then:

```bash
./build.sh
```

The built `.deb` will be in `dist/`.

## Configuration

The Pake build configuration is in `config/pake.json`. Key settings:

| Setting | Value | Why |
|---|---|---|
| `url` | `https://kimi.moonshot.cn` | Kimi web app |
| `new_window` | `true` | Enables OAuth popups (Google auth) |
| `width` / `height` | 1200 / 780 | Matches original Kimi desktop |
| `user_agent.linux` | Chrome 133 on Linux | Makes OAuth providers accept the webview |

## Uninstall

```bash
sudo dpkg -r kimi
```

## License

Kimi is a product of [Moonshot AI](https://moonshot.cn). This packaging uses the open-source [Pake](https://github.com/tw93/Pake) tool (MIT license) to wrap the Kimi web interface as a native desktop application.