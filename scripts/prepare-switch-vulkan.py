"""Fetch pinned shader compiler/loader and allow SDL windows without EGL ownership."""
from pathlib import Path
import subprocess

root = Path('/paperboat/switch-vulkan-deps')
root.mkdir(exist_ok=True)
def checkout(name, repo, revision):
    dest = root / name
    if not (dest / '.git').exists():
        dest.mkdir(parents=True, exist_ok=True)
        subprocess.run(['git', 'init', str(dest)], check=True)
        subprocess.run(['git', '-C', str(dest), 'remote', 'add', 'origin', repo], check=True)
        subprocess.run(['git', '-C', str(dest), 'fetch', '--depth=1', 'origin', revision], check=True)
        subprocess.run(['git', '-C', str(dest), 'checkout', '--detach', 'FETCH_HEAD'], check=True)
    return dest

shaderc = checkout('shaderc', 'https://github.com/google/shaderc.git', 'v2025.3')
# Shaderc 2025.3 passes a generator expression to glslang's configure-time
# installation option. CMake treats that nonempty string as true even when
# SHADERC_SKIP_INSTALL is ON, producing an invalid dependency export set.
p = shaderc / 'third_party/CMakeLists.txt'
s = p.read_text()
old = 'set(GLSLANG_ENABLE_INSTALL $<NOT:${SKIP_GLSLANG_INSTALL}>)'
new = '''if(SKIP_GLSLANG_INSTALL)
      set(GLSLANG_ENABLE_INSTALL OFF)
    else()
      set(GLSLANG_ENABLE_INSTALL ON)
    endif()'''
if new not in s:
    if s.count(old) != 1:
        raise RuntimeError('Pinned shaderc install configuration no longer matches the Switch patch')
    s = s.replace(old, new)
p.write_text(s)
for name, repo, rev in [
    ('glslang','KhronosGroup/glslang','efd24d75bcbc55620e759f6bf42c45a32abac5f8'),
    ('spirv-tools','KhronosGroup/SPIRV-Tools','33e02568181e3312f49a3cf33df470bf96ef293a'),
    ('spirv-headers','KhronosGroup/SPIRV-Headers','2a611a970fdbc41ac2e3e328802aed9985352dca'),
]:
    checkout('shaderc/third_party/' + name, 'https://github.com/' + repo + '.git', rev)

volk = checkout('volk', 'https://github.com/zeux/volk.git', 'f30088b3f4160810b53e19258dd2f7395e5f0ba3')
p = volk / 'volk.c'
s = p.read_text()
s = s.replace('#else\n#\tinclude <dlfcn.h>', '#elif !defined(__SWITCH__)\n#\tinclude <dlfcn.h>')
s = s.replace('VkResult volkInitialize(void)\n{\n#if defined(_WIN32)',
              'VkResult volkInitialize(void)\n{\n#if defined(__SWITCH__)\n\tvoid* module = NULL;\n\treturn VK_ERROR_INITIALIZATION_FAILED;\n#elif defined(_WIN32)')
s = s.replace('#else\n\t\tdlclose(loadedModule);', '#elif !defined(__SWITCH__)\n\t\tdlclose(loadedModule);')
p.write_text(s)

sdl = checkout('SDL', 'https://github.com/devkitPro/SDL.git', '0738d3c9f6993875e2f3dd0e8cc0bb4ae4440b4e')
# Horizon exposes pthread-compatible symbols from libc.  SDL's generic
# fallback adds -lpthread, which does not exist in the devkitPro sysroot and
# makes its configure-time thread probe fail.
p = sdl / 'cmake/sdlchecks.cmake'
s = p.read_text()
old = 'elseif(QNX)\n      # pthread support is baked in'
new = 'elseif(QNX OR NINTENDO_SWITCH)\n      # pthread support is provided by the platform libc'
if new not in s:
    if s.count(old) != 1:
        raise RuntimeError('Pinned SDL pthread configuration no longer matches the Switch patch')
    s = s.replace(old, new)
p.write_text(s)
p = sdl / 'src/video/switch/SDL_switchvideo.c'
s = p.read_text()
if '#include <stdlib.h>' not in s:
    s = s.replace('#include "../../SDL_internal.h"', '#include "../../SDL_internal.h"\n#include <stdlib.h>')
needle = '    if (!_this->egl_data) {'
replacement = '''    /* PaperBoat native Vulkan owns NWindow; do not create an EGL surface. */
    if (!(window->flags & SDL_WINDOW_OPENGL) || getenv("PAPERBOAT_NXVK_VULKAN")) {
        window_data = (SDL_WindowData *) SDL_calloc(1, sizeof(SDL_WindowData));
        if (!window_data) return SDL_OutOfMemory();
        window->driverdata = window_data;
        switch_window = window;
        operationMode = appletGetOperationMode();
        SDL_SetMouseFocus(window);
        SDL_SetKeyboardFocus(window);
        return 0;
    }

''' + needle
if 'PaperBoat native Vulkan owns NWindow' not in s:
    assert s.count(needle) == 1
    s = s.replace(needle, replacement)
if 'PAPERBOAT_NXVK_VULKAN' not in s:
    raise RuntimeError('SDL Vulkan escape hatch was not applied')
p.write_text(s)
