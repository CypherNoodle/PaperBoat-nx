# NXVK / Zink and native Vulkan experiment

Branch: `switch-nxvk-zink`. The working `switch-port` branch is unchanged.
NXVK is pinned to `e028d428c3b1f2dabadd81645c53cddfc8d7ab51`.

This build includes PaperBoat's OpenGL renderer through Zink/NXVK and its direct
Vulkan renderer through NXVK. Both backends are experimental on Switch.

The dedicated Switch workflow builds the upstream NXVK toolchain and driver,
then the game. No Linux or Windows game build is requested. The first build can
take substantially longer because it builds Mesa and Rust dependencies.

Copy `paperboat-nxvk.nro` beside the existing NRO in `switch/paperboat/`, keeping
`paperboat.o2r` and your own `pm64.o2r` there. Both NROs share configuration and
saves; back these up before comparing. Launch in application mode.

Enable **Settings > Graphics > Show FPS** to display measured presentation FPS
and average frame time. These include interpolated frames, not just game logic
updates. **Target FPS** controls the requested rate and is not a measurement.

Compare the same scene with identical resolution, MSAA, target FPS, and docked
or handheld mode. Select **OpenGL** (Zink) or **Vulkan** in the Graphics renderer
setting, then restart. Check `logs/Paperboat.log` for the selected renderer:
Zink for OpenGL, or `Switch native Vulkan` for Vulkan. Keep both logs when reporting problems. A faster
driver is not guaranteed, and audio underruns may have causes outside rendering.

The game artifact contains only the NRO and O2R. Source references and license
information are provided in a separate documentation artifact; they do not need
to be copied to the SD card. Artifacts are only uploaded after the native Vulkan
build and the checks for both linked renderers succeed.

Rumble follows the game's events, pause and map transitions. Its strength uses
the rumble mappings in the controller settings. Gyro is not added by this port.
The original FPS and interpolation logic is retained without a Switch-only cap.

Upstream build instructions and source:
https://github.com/PalindromicBreadLoaf/nxvk/tree/e028d428c3b1f2dabadd81645c53cddfc8d7ab51/switch
