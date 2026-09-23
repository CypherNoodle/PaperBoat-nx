#!/usr/bin/env bash
set -euo pipefail
python3 /paperboat/scripts/prepare-switch-vulkan.py
deps=/paperboat/switch-vulkan-deps
toolchain=/opt/devkitpro/cmake/Switch.cmake
cmake -S "$deps/SDL" -B "$deps/SDL-build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_INSTALL_PREFIX=/opt/devkitpro/portlibs/switch \
  -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST=OFF -DSDL_TESTS=OFF
cmake --build "$deps/SDL-build" --target install --parallel 2
cmake -S "$deps/shaderc" -B "$deps/shaderc-build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DSHADERC_SKIP_TESTS=ON -DSHADERC_SKIP_EXAMPLES=ON \
  -DSHADERC_SKIP_EXECUTABLES=ON -DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
  -DSPIRV_SKIP_TESTS=ON -DSPIRV_SKIP_EXECUTABLES=ON \
  -DENABLE_GLSLANG_BINARIES=OFF -DENABLE_OPT=ON
cmake --build "$deps/shaderc-build" --target shaderc_combined --parallel 2
