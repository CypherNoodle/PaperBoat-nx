#include "SwitchRumble.h"

#ifdef __SWITCH__
#include <algorithm>
#include <array>
#include <SDL2/SDL.h>
#include "ship/Context.h"
#include "ship/controller/controldeck/ControlDeck.h"
#include "ship/controller/controldevice/controller/Controller.h"
#include "ship/controller/controldevice/controller/ControllerRumble.h"
#include "ship/controller/physicaldevice/ConnectedPhysicalDeviceManager.h"

namespace {
std::array<uint8_t, 4> modes {};
bool forceStopped = false;

void Stop(uint32_t port) {
    auto deck = Ship::Context::GetRawInstance()->GetControlDeck();
    if (!deck || port >= modes.size()) return;
    for (const auto& [id, pad] : deck->GetConnectedPhysicalDeviceManager()->GetConnectedSDLGamepadsForPort(port)) {
        SDL_GameControllerRumble(pad, 0, 0, 0);
    }
}
}

void SwitchRumble_Init(void) {
    for (uint32_t port = 0; port < modes.size(); ++port) Stop(port);
    modes.fill(0);
    forceStopped = false;
}

void SwitchRumble_ForceStop(int paused) {
    forceStopped = paused != 0;
    if (forceStopped) {
        for (uint32_t port = 0; port < modes.size(); ++port) Stop(port);
    }
}

int SwitchRumble_Check(uint32_t port) {
    auto deck = Ship::Context::GetRawInstance()->GetControlDeck();
    if (!deck || port >= modes.size()) return -1;
    for (const auto& [id, pad] : deck->GetConnectedPhysicalDeviceManager()->GetConnectedSDLGamepadsForPort(port)) {
        if (SDL_GameControllerHasRumble(pad)) return 0;
    }
    return -1;
}

void SwitchRumble_SetMode(uint32_t port, uint8_t mode) {
    if (port >= modes.size()) return;
    modes[port] = mode;
    if (mode == 0 || (mode & 0x80)) Stop(port);
}

void SwitchRumble_Start(uint32_t port, uint16_t frequency, uint16_t frames) {
    if (port >= modes.size() || forceStopped || modes[port] == 0 || (modes[port] & 0x80)) return;
    auto deck = Ship::Context::GetRawInstance()->GetControlDeck();
    if (!deck) return;
    auto controller = deck->GetControllerByPort(port);
    if (!controller) return;
    if (!frequency || !frames) {
        Stop(port);
        return;
    }
    // NuSystem expresses strength as a 0..256 motor duty cycle and duration
    // in 60 Hz retraces. Switch supports analog amplitude and timed rumble.
    const uint32_t strength = std::min<uint32_t>(frequency, 256);
    const uint32_t duration = (uint32_t(frames) * 1000 + 59) / 60;
    uint16_t low = 0, high = 0;
    for (const auto& [id, mapping] : controller->GetRumble()->GetAllRumbleMappings()) {
        if (mapping->GetPhysicalDeviceType() != Ship::PhysicalDeviceType::SDLGamepad) continue;
        low = std::max(low, uint16_t(65535u * strength * mapping->GetLowFrequencyIntensityPercentage() / 256 / 100));
        high = std::max(high, uint16_t(65535u * strength * mapping->GetHighFrequencyIntensityPercentage() / 256 / 100));
    }
    for (const auto& [id, pad] : deck->GetConnectedPhysicalDeviceManager()->GetConnectedSDLGamepadsForPort(port)) {
        SDL_GameControllerRumble(pad, low, high, duration);
    }
}
#endif
