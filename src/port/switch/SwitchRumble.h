#pragma once

#ifdef __SWITCH__
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void SwitchRumble_Init(void);
void SwitchRumble_ForceStop(int paused);
int SwitchRumble_Check(uint32_t port);
void SwitchRumble_SetMode(uint32_t port, uint8_t mode);
void SwitchRumble_Start(uint32_t port, uint16_t frequency, uint16_t frames);
#ifdef __cplusplus
}
#endif
#endif
