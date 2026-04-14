---
title: "Kimi Desktop on Ubuntu 26.04: Fixing the Broken .deb with Tauri v2"
published: false
description: "The official Kimi desktop app can't install on Ubuntu 24.04+ because it depends on a removed library. Here's how I rebuilt it with Tauri v2 and Pake v3 to fix it."
tags: linux, ubuntu, tauri, desktop
cover_image: https://raw.githubusercontent.com/johnohhh1/kimi-app/main/assets/KIMI-K2.jpg
---

You install the official Kimi desktop `.deb`, fire `sudo dpkg -i`, and boom:

```
dpkg: dependency problems prevent configuration of kimi:
 kimi depends on libwebkit2gtk-4.0-37; however:
  Package libwebkit2gtk-4.0-37 is not installed.
```

That library doesn't exist on Ubuntu 24.04, let alone 26.04. It was removed from the repos over a year ago. The official [Kimi desktop package](https://github.com/kimi-moonshot/kimi-moonshot) is built on Tauri v1, which hard-depends on `libwebkit2gtk-4.0.so.37` — a library that shipped with webkit2gtk 4.0, superseded by 4.1 and then dropped entirely.

So the app is just... broken on any modern Ubuntu. Here's how I fixed it.

## The problem in one sentence

Tauri v1 → `libwebkit2gtk-4.0` → removed from Ubuntu 24.04+ → `dpkg` fails.

## The fix: rebuild with Tauri v2

Tauri v2 links against `libwebkit2gtk-4.1`, which *is* the version shipped in Ubuntu 24.04 and 26.04. So the fix is straightforward: rebuild the app with Tauri v2 instead of v1.

I used [Pake](https://github.com/tw93/Pake) v3, which wraps any web app into a native desktop app using Tauri under the hood. One build script, one config file, and you get a `.deb` that actually installs.

## What you get

| Feature | Detail |
|---|---|
| **Tauri v2 runtime** | Links against `libwebkit2gtk-4.1` — the one Ubuntu actually ships |
| **OAuth / SSO** | `--new-window` flag means Google sign-in works in-app instead of being blocked |
| **System tray** | Desktop integration that works |
| **1200x780 window** | Matches the original Kimi desktop dimensions |

## Rebuild it yourself

Prerequisites — Rust, Node, and the usual GTK/webkit dev packages:

```bash
# Rust >= 1.85
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node.js >= 22 — use nvm, brew, whatever you prefer

# Build deps
sudo apt install libwebkit2gtk-4.1-dev libgtk-3-dev \
  libayatana-appindicator3-dev librsvg2-dev

# Pake CLI
npm install -g pake-cli
```

Then it's one command:

```bash
./build.sh
```

The `.deb` lands in `dist/`. Install it:

```bash
sudo dpkg -i dist/kimi_1.0.0_amd64.deb
```

Or grab the pre-built `.deb` from [GitHub Releases](https://github.com/johnohhh1/kimi-app/releases) if you don't want to build from source.

Done. Kimi runs natively on Ubuntu 26.04 with no missing libraries.

## The config that makes it work

Everything lives in `config/pake.json`. The important bits:

```json
{
  "windows": [{
    "url": "https://kimi.moonshot.cn",
    "new_window": true,
    "width": 1200,
    "height": 780
  }],
  "user_agent": {
    "linux": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36"
  }
}
```

The two things that matter:

- **`new_window: true`** — Without this, OAuth popups (Google sign-in, etc.) get blocked by the webview's navigation policy. This flag tells Pake/Tauri to open them in a new window instead.
- **`user_agent.linux`** — Spoofing a Chrome UA because some OAuth providers reject webview user agents.

## Why not just use the web app in a browser?

Fair question. A native desktop app gives you:

- **Alt-Tab separation** — Kimi isn't buried among 40 browser tabs
- **System tray** — Quick access, stays running in the background
- **Own window chrome** — Feels like an app, not a tab
- **Smaller memory footprint** — Tauri uses the system webview, not a bundled Electron instance

## The repo

[github.com/johnohhh1/kimi-app](https://github.com/johnohhh1/kimi-app)

Clone it, build it, install it. If you're on Ubuntu 24.04+ and want Kimi as a desktop app, this is currently the only way that works.

## Uninstall

If you need to remove it:

```bash
sudo dpkg -r kimi
```

---

*Kimi is a product of [Moonshot AI](https://moonshot.cn). This project uses the open-source [Pake](https://github.com/tw93/Pake) tool (MIT license) to wrap the Kimi web interface as a native desktop application.*