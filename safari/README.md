# Claude Pulse for Safari

Claude Pulse ships as a cross-browser Web Extension. The root `manifest.json`
already contains the Safari-specific settings, so the same source tree targets
Chrome, Firefox, and Safari — no code changes needed.

Because Safari extensions must be distributed inside a macOS app, producing a
Safari build means wrapping the extension in an Xcode project using Apple's
`safari-web-extension-converter` tool.

## Requirements

- Safari 16.4 or later on the target device

Depending on how you build:

| Path | What you need |
|------|--------------|
| GitHub Actions (recommended) | Nothing local — just push to GitHub |
| `build.sh` (local, no IDE) | macOS + Xcode Command Line Tools (`xcode-select --install`, ~200 MB) |
| Xcode IDE | macOS + full Xcode (~14 GB) |

---

## Option 1 — GitHub Actions (no local Apple tooling needed)

Push your branch (or fork the repo). The workflow at
`.github/workflows/safari.yml` runs automatically and produces a signed `.app`
under **Actions → ClaudePulse-Safari** as a downloadable artifact.

On tagged releases the `.app` is also attached to the GitHub Release.

---

## Option 2 — Command Line Tools only (no Xcode IDE)

1. Install the Command Line Tools (small download, no full IDE required):

   ```sh
   xcode-select --install
   ```

2. From the repository root, run the build script:

   ```sh
   ./safari/build.sh
   ```

   This calls `safari-web-extension-converter` and then prints the
   `xcodebuild` command to compile the `.app` without opening Xcode.

3. Run the printed `xcodebuild` command to compile the `.app`.

---

## Option 3 — Xcode IDE

1. Run `./safari/build.sh` (or the manual converter command below).
2. Open the generated `.xcodeproj` in Xcode.
3. Press **⌘R** to build and run.

### Manual converter command

```sh
xcrun safari-web-extension-converter \
  --project-location safari/build \
  --app-name "Claude Pulse" \
  --bundle-identifier com.claudepulse.safari \
  --swift \
  --no-open \
  --force \
  .
```

---

## Load the extension in Safari

1. In Safari, open **Settings → Advanced** and enable
   *"Show features for web developers"*.
2. Open **Settings → Developer** and enable
   *"Allow unsigned extensions"* (re-enable after each Safari restart for
   development builds).
3. Run the container app at least once.
4. Open **Settings → Extensions**, enable **Claude Pulse**, and grant access
   to `claude.ai`.

---

## Distributing via the Mac App Store

To ship through the App Store you will need:

- A paid Apple Developer account.
- A bundle identifier you own set in Xcode's *Signing & Capabilities* tab.
- Code-signing and notarization configured in Xcode.

---

## Why no code changes?

`bridge-client.js` already reads
`globalThis.browser?.runtime || globalThis.chrome?.runtime`, which resolves to
Safari's `browser` namespace automatically. All other APIs used
(`MutationObserver`, `fetch`, `crypto.subtle`, `CustomEvent`) are standard and
fully supported in Safari 16.4+.
