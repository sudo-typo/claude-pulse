#!/usr/bin/env bash
# Build the Safari container app for Claude Pulse.
#
# Runs Apple's safari-web-extension-converter against the repository root and
# emits an Xcode project into safari/build/. Open the resulting .xcodeproj in
# Xcode to compile and run the extension.
#
# Requirements: macOS with Xcode Command Line Tools installed.
#   Full Xcode IDE is NOT required — Command Line Tools alone are enough:
#   $ xcode-select --install
#
# Alternatively, push to GitHub and download the ready-made .app from the
# Actions tab (no local Apple tooling needed at all).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "Error: safari-web-extension-converter only runs on macOS." >&2
	echo "Tip: push to GitHub and download the pre-built .app from the Actions tab instead." >&2
	exit 1
fi

if ! xcrun --find safari-web-extension-converter >/dev/null 2>&1; then
	echo "Error: safari-web-extension-converter not found." >&2
	echo ""
	echo "You do NOT need the full Xcode IDE (~14 GB). Install only the"
	echo "Command Line Tools (~200 MB) and retry:"
	echo ""
	echo "  xcode-select --install"
	echo ""
	echo "Or skip this step entirely and let GitHub Actions build the .app for you:"
	echo "  push your branch → Actions tab → ClaudePulse-Safari artifact." >&2
	exit 1
fi

mkdir -p "${BUILD_DIR}"

xcrun safari-web-extension-converter \
	--project-location "${BUILD_DIR}" \
	--app-name "Claude Pulse" \
	--bundle-identifier "com.claudepulse.safari" \
	--swift \
	--no-open \
	--force \
	"${REPO_ROOT}"

echo ""
echo "Done. To compile without opening Xcode IDE, run:"
echo ""
echo "  xcodebuild \\"
echo "    -project \"${BUILD_DIR}/Claude Pulse/Claude Pulse.xcodeproj\" \\"
echo "    -scheme \"Claude Pulse\" \\"
echo "    -configuration Release \\"
echo "    CODE_SIGN_IDENTITY=\"-\" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \\"
echo "    build"
echo ""
echo "Or simply open the .xcodeproj in Xcode and press ⌘R."
