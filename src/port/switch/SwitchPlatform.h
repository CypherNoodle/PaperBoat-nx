#pragma once

namespace SwitchPlatform {
#ifdef __SWITCH__
void Trace(const char* message);
#else
inline void Trace(const char*) {}
#endif
bool Prepare();
bool MainLoop();
}
