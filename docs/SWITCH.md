# Experimental Nintendo Switch port

This is an initial source integration, not a verified release. A successful
cross-build and tests on hardware are still required. No playable NRO is included
with the source patch. Start with the OpenGL backend (SDL2, glad, devkitPro Mesa).

## Dependency baseline

PaperBoat baseline: `2f7d38e07bcb85c216bf37e8a0a1a5cf8731ceef`.
libultraship baseline: `7aa03b6c830b059e3ddd6ad20d3f289c5f406161`
from JeodC's `lus-converge` history. The `main` branch of the CypherNoodle fork
has diverged from this API and must not replace it. Use the submodule commit
recorded in this branch; the submodule branch setting alone does not pin a build.

## Build

Use a devkitPro development environment with devkitA64, libnx, switch-tools,
switch-cmake, switch-sdl2, switch-mesa, switch-glad and switch-zlib installed,
plus CMake 3.24 or newer, Ninja, Git and pkg-config. The included GitHub Actions
workflow installs these dependencies in `devkitpro/devkita64`.

```sh
git submodule update --init --recursive
cmake -S . -B build-switch -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$DEVKITPRO/cmake/Switch.cmake" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build-switch --target switch-package --parallel 2
```

The target generates `build-switch/switch/paperboat/paperboat.nro` and
`paperboat.o2r`. Torch is excluded from the console executable; it is a desktop
extraction dependency. Runtime scripting and dynamic library loading are disabled.
Other platforms keep their existing extraction path.

## SD card and first boot

Copy the resulting `switch` directory to the SD card root. Generate `pm64.o2r`
using the matching PaperBoat desktop version and your own supported ROM, then put
it in `sdmc:/switch/paperboat/`. Do not redistribute the ROM or its extracted data.

```text
switch/paperboat/
  paperboat.nro
  paperboat.o2r
  pm64.o2r
```

Use hbmenu in application mode (hold R while launching a game). Album/applet mode
is rejected before engine startup. Config, logs, saves and mods use the same
`sdmc:/switch/paperboat` working directory. The initial surface is 1280x720.
Minus toggles the menu; the existing SDL controller mappings are used.

## Validation still needed

- The initial devkitA64 compile and link passed; startup on hardware is still under investigation.
- Verify startup errors for missing files and insufficient-memory applet mode.
- Test title screen, gameplay, saves and reloads on hardware.
- Test Joy-Con and Pro Controller, menu navigation, audio, HOME/resume and exit.
- Measure handheld/docked performance and memory use before setting expectations.

## Startup diagnostics

The Switch renderer requests OpenGL 4.1 core and uses matching core shaders and a
vertex array object, including the ImGui backend. SDL window/context failures and
missing GL entry points are checked before rendering.

After a failed launch, collect `switch/paperboat/switch-startup.log` and
`switch/paperboat/logs/Paperboat.log`. The startup file appends checkpoints and
closes after each write, independently of the engine logger. Each launch starts
with a banner. The engine logger is synchronous on Switch, so an immediate crash
does not leave messages queued on a logging thread. A C++ exception is recorded
in the startup file before returning to hbmenu; CPU/GPU faults may still cause the
system error screen. These logs identify the last completed stage, not a stack trace.

## NXVK follow-up

[NXVK](https://github.com/PalindromicBreadLoaf/nxvk/blob/switch/switch/README.md)
is a possible alternative driver. Its documentation advertises Vulkan 1.4 and
OpenGL through Zink. PaperBoat's Vulkan backend currently requests Vulkan 1.1 and
compiles GLSL through shaderc at runtime.

Vulkan integration is not just a linker change: the backend currently uses
SDL's Vulkan loader and surface creation. NXVK documents static ICD entry-point
loading via `vk_icdGetInstanceProcAddr` and a `VK_NN_vi_surface` surface backed by
libnx NWindow. shaderc/SPIR-V dependencies also need target builds. These changes
are not included in this initial port. Compare performance on hardware before
choosing between the two drivers.
