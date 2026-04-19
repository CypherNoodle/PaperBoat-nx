#pragma once

#include "common.h"

// True if the value is a pointer to inline message bytes (or a function
// pointer to a tattle lookup) rather than a packed section/index msgID.
// MsgIDs fit in (section << 16) | index, well below 0x01000000.
#define MSG_ID_IS_PTR(id) ((uintptr_t)(id) > 0x01000000)

#ifdef _LANGUAGE_C_PLUS_PLUS
extern "C" {
#endif

s32 msg_get_print_char_width(s32 character, s32 charset, s32 variation, f32 msgScale, s32 overrideCharWidth, u8 flags);
void msg_get_glyph(s32 font, s32 variation, s32 charIndex, s32 palette, MesasgeFontGlyphData* out);
void dma_load_msg(u32 msgID, void* dest);

#ifdef _LANGUAGE_C_PLUS_PLUS
} // extern "C"
#endif
