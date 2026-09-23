# NXVK / Zink experiment

Branch: `switch-nxvk-zink`. The working `switch-port` branch is unchanged.
NXVK is pinned to `e028d428c3b1f2dabadd81645c53cddfc8d7ab51`.

This build uses PaperBoat's OpenGL renderer through Zink/NXVK. It does not enable
PaperBoat's direct Vulkan backend. Build and runtime validation are experimental.

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
or handheld mode. Check `logs/Paperboat.log` for the renderer string: the NXVK
build should identify Zink. Keep both logs when reporting problems. A faster
driver is not guaranteed, and audio underruns may have causes outside rendering.

Upstream build instructions and source:
https://github.com/PalindromicBreadLoaf/nxvk/tree/e028d428c3b1f2dabadd81645c53cddfc8d7ab51/switch
