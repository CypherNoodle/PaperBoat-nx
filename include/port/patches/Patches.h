#ifndef PORT_PATCHES_H
#define PORT_PATCHES_H

#include "common.h"

#ifdef __cplusplus
extern "C" {
#endif

// Framebuffer (FramebufferPatches.c)
u16* port_getPrevFrameSentinel(void);
void port_requestPrevFrameCapture(void);
void port_emitCaptureCurrentFrameIfRequested(Gfx** gfxP);

// Static Gfx[] with VTXs
void port_patch_dl(Gfx* dl);
struct StaticAnimatorNode;
void port_patch_animator_tree(struct StaticAnimatorNode** tree);

// Sprite shading (SpritePatches.c)
void port_appendGfx_shading_palette(
    Matrix4f mtx, s32 uls, s32 ult, s32 lrs, s32 lrt, s32 alpha,
    f32 shadowX, f32 shadowY, f32 shadowZ,
    s32 shadowR, s32 shadowG, s32 shadowB,
    s32 highlightR, s32 highlightG, s32 highlightB,
    s32 ambientPower, s32 renderMode);

// Flame effect (FlamePatches.c)
void port_flame_appendGfx(void* effect);

// Bulb glow effect (BulbGlowPatches.c)
void port_bulb_glow_appendGfx(void* effect);

// Energy in/out effect (EnergyInOutPatches.c)
void port_energy_in_out_appendGfx(void* effect);

// Flashing box shockwave effect (FlashingBoxShockwavePatches.c)
void port_flashing_box_shockwave_appendGfx(void* effect);

// Darkness stencil (DarknessStencilPatches.c)
void port_appendGfx_darkness_stencil(b32 isWorld, s32 posX, s32 posY, f32 alpha, f32 progress);

// EVT (EvtPatches.c) — pointer-safe replacement for `UseBuf(Ref(T*[])) +
// BufRead1`.
ApiStatus LoadPtrFromArray(Evt* script, bool isInitialCall);


#ifdef __cplusplus
}
#endif

#endif  // PORT_PATCHES_H
