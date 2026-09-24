#ifdef __SWITCH__
#include "SwitchPlatform.h"

#include <switch.h>
#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>
#include <unistd.h>

// The game uses large stack-local display-list and audio buffers.
extern "C" {
u32 __stacksize__ = 8 * 1024 * 1024;
}

namespace {
constexpr const char* AppDirectory = "sdmc:/switch/paperboat";

void ShowError(const char* message) {
    consoleInit(nullptr);
    std::printf("PaperBoat - Nintendo Switch\n\n%s\n\nPress + to return.\n", message);
    padConfigureInput(1, HidNpadStyleSet_NpadStandard);
    PadState pad;
    padInitializeDefault(&pad);
    while (appletMainLoop()) {
        padUpdate(&pad);
        if (padGetButtonsDown(&pad) & HidNpadButton_Plus) {
            break;
        }
        consoleUpdate(nullptr);
    }
    consoleExit(nullptr);
}

bool HasFile(const char* path) {
    struct stat info {};
    return stat(path, &info) == 0 && S_ISREG(info.st_mode) && info.st_size > 0;
}
}

bool SwitchPlatform::Prepare() {
#ifdef PAPERBOAT_NXVK_ZINK
    // The custom SDL build also contains generic backends. Pin the native
    // driver before SDL initializes video so OpenGL uses Switch EGL/Zink and
    // Vulkan receives the Switch NWindow path.
    setenv("SDL_VIDEODRIVER", "Switch", 1);
    setenv("NVK_I_WANT_A_BROKEN_VULKAN_DRIVER", "1", 1);
    setenv("GALLIUM_DRIVER", "zink", 1);
#endif
    const auto type = appletGetAppletType();
    if (type != AppletType_Application && type != AppletType_SystemApplication) {
        ShowError("Launch hbmenu in application mode (hold R while starting a game).\n"
                  "Album/applet mode does not provide enough memory.");
        return false;
    }
    if (chdir(AppDirectory) != 0 || setenv("SHIP_HOME", AppDirectory, 1) != 0) {
        ShowError("Cannot open sdmc:/switch/paperboat.\nCopy the release folder to your SD card.");
        return false;
    }
    if (!HasFile("paperboat.o2r") || !HasFile("pm64.o2r")) {
        ShowError("Place paperboat.o2r and pm64.o2r in sdmc:/switch/paperboat.\n"
                  "Generate pm64.o2r using the matching desktop version and your own ROM.");
        return false;
    }
    return true;
}

bool SwitchPlatform::MainLoop() {
    return appletMainLoop();
}
#endif
