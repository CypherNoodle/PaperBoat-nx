#!/usr/bin/env bash
set -euo pipefail
python3 /paperboat/scripts/prepare-switch-vulkan.py
deps=/paperboat/switch-vulkan-deps
toolchain=/opt/devkitpro/cmake/Switch.cmake
build_jobs="${PAPERBOAT_BUILD_JOBS:-$(nproc)}"
# SDL's Switch branch still sets the old PTHREADS option names. Enable the
# current options explicitly so CheckPTHREAD actually runs on this platform.
# Disable generic video backends so SDL selects the native Switch driver before
# creating either the Zink/EGL or native Vulkan window.
cmake -S "$deps/SDL" -B "$deps/SDL-build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_INSTALL_PREFIX=/opt/devkitpro/portlibs/switch \
  -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST=OFF -DSDL_TESTS=OFF \
  -DSDL_OFFSCREEN=OFF -DSDL_DUMMYVIDEO=OFF \
  -DSDL_THREADS=ON -DSDL_PTHREADS=ON -DSDL_PTHREADS_SEM=ON \
  || { tail -n 180 "$deps/SDL-build/CMakeFiles/CMakeConfigureLog.yaml"; exit 1; }
grep -Eq '^HAVE_PTHREADS:INTERNAL=(1|TRUE)$' "$deps/SDL-build/CMakeCache.txt"
cmake --build "$deps/SDL-build" --target install --parallel "$build_jobs"
cmake -S "$deps/shaderc" -B "$deps/shaderc-build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DSHADERC_SKIP_INSTALL=ON \
  -DSHADERC_SKIP_TESTS=ON -DSHADERC_SKIP_EXAMPLES=ON \
  -DSHADERC_SKIP_EXECUTABLES=ON -DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
  -DSPIRV_SKIP_TESTS=ON -DSPIRV_SKIP_EXECUTABLES=ON \
  -DENABLE_GLSLANG_BINARIES=OFF -DENABLE_OPT=ON
cmake --build "$deps/shaderc-build" --target shaderc_combined --parallel "$build_jobs"
