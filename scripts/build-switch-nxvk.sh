#!/usr/bin/env bash
set -euo pipefail

# Run in the upstream NXVK toolchain image: NXVK at /work, game at /paperboat.
export PATH="$DEVKITPRO/devkitA64/bin:$DEVKITPRO/tools/bin:$PATH"
build_jobs="${PAPERBOAT_BUILD_JOBS:-$(nproc)}"
mkdir -p /tmp/paperboat-build-tools
real_ninja="$(command -v ninja)"
printf '#!/bin/sh\nexec %s -j%s "$@"\n' "$real_ninja" "$build_jobs" > /tmp/paperboat-build-tools/ninja
chmod +x /tmp/paperboat-build-tools/ninja
export PATH="/tmp/paperboat-build-tools:$PATH"
export CARGO_BUILD_JOBS="$build_jobs"
if [ ! -f switch/build/pkg/lib/libnvk_gl.a ]; then
  make CONTAINER= gl
fi
make CONTAINER= install-gl

bash /paperboat/scripts/build-switch-vulkan-deps.sh

git config --global --add safe.directory /paperboat
cmake -S /paperboat -B /paperboat/build-switch-nxvk -G Ninja \
  -DCMAKE_MAKE_PROGRAM="$real_ninja" \
  -DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake \
  -DCMAKE_BUILD_TYPE=Release -DSWITCH_NXVK_ZINK=ON -DNXVK_SOURCE_DIR=/work \
  -DSWITCH_VULKAN_DEPS=/paperboat/switch-vulkan-deps
cmake --build /paperboat/build-switch-nxvk --target switch-package --parallel "$build_jobs"
# Require both renderers in the linked executable before allowing publication.
aarch64-none-elf-nm -C /paperboat/build-switch-nxvk/paperboat.elf > /tmp/paperboat-symbols.txt
grep -q 'Fast::GfxRenderingAPIVK::VulkanInit' /tmp/paperboat-symbols.txt
grep -q 'Fast::GfxRenderingAPIOGL::Init' /tmp/paperboat-symbols.txt
package=/paperboat/build-switch-nxvk/switch/paperboat
documentation=/paperboat/build-switch-nxvk/documentation
mkdir -p "$documentation/licenses/nxvk"
cp /paperboat/docs/SWITCH-NXVK.md "$documentation/README-NXVK.md"
cp /work/licenses/GPL-2.0-or-later "$documentation/licenses/nxvk/"
printf 'PaperBoat source: https://github.com/CypherNoodle/PaperBoat-nx/tree/%s\nNXVK source: https://github.com/PalindromicBreadLoaf/nxvk/tree/e028d428c3b1f2dabadd81645c53cddfc8d7ab51\n' \
  "$(git -C /paperboat rev-parse HEAD)" > "$documentation/SOURCES.txt"
touch /paperboat/build-switch-nxvk/native-vulkan-ready
