#ifndef _AUDIO_PUBLIC_H_
#define _AUDIO_PUBLIC_H_

#include "common_structs.h"

typedef struct {
    /* 0x0 */ s16 flags;
    /* 0x2 */ s16 fadeState;
    /* 0x4 */ s32 fadeTime;
    /* 0x8 */ s32 soundID;
    /* 0xC */ s32 unkC;
} AmbientSoundSettings;

typedef enum AmbientSoundState {
    AMBIENCE_STATE_IDLE         = 0,
    AMBIENCE_STATE_FADE_OUT     = 1,  // fade out old sounds
    AMBIENCE_STATE_FADE_IN      = 2   // fade in new sounds
} AmbientSoundState;

typedef enum AmbientSoundFlag {
    AMBIENCE_FLAG_PLAYING       = 1,
} AmbientSoundFlag;

#endif
