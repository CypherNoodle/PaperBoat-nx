#!/usr/bin/env bash
set -euo pipefail

# Run in the upstream NXVK toolchain image: NXVK at /work, game at /paperboat.
export PATH="$DEVKITPRO/devkitA64/bin:$DEVKITPRO/tools/bin:$PATH"
mkdir -p /tmp/paperboat-build-tools
real_ninja="$(command -v ninja)"
printf '#!/bin/sh\nexec %s -j2 "$@"\n' "$real_ninja" > /tmp/paperboat-build-tools/ninja
chmod +x /tmp/paperboat-build-tools/ninja
export PATH="/tmp/paperboat-build-tools:$PATH"
export CARGO_BUILD_JOBS=2
if [ ! -f switch/build/pkg/lib/libnvk_gl.a ]; then
  make CONTAINER= gl
fi
make CONTAINER= install-gl

git config --global --add safe.directory /paperboat
cmake -S /paperboat -B /paperboat/build-switch-nxvk -G Ninja \
  -DCMAKE_MAKE_PROGRAM="$real_ninja" \
  -DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake \
  -DCMAKE_BUILD_TYPE=Release -DSWITCH_NXVK_ZINK=ON -DNXVK_SOURCE_DIR=/work
cmake --build /paperboat/build-switch-nxvk --target switch-package --parallel 2
package=/paperboat/build-switch-nxvk/switch/paperboat
mv "$package/paperboat.nro" "$package/paperboat-nxvk.nro"
cp /paperboat/docs/SWITCH-NXVK.md "$package/README-NXVK.md"
mkdir -p "$package/licenses/nxvk"
cp /work/licenses/GPL-2.0-or-later "$package/licenses/nxvk/"
printf 'PaperBoat source: https://github.com/CypherNoodle/PaperBoat-nx/tree/%s\nNXVK source: https://github.com/PalindromicBreadLoaf/nxvk/tree/e028d428c3b1f2dabadd81645c53cddfc8d7ab51\n' \
  "$(git -C /paperboat rev-parse HEAD)" > "$package/SOURCES.txt"
