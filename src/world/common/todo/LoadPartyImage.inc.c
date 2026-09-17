#include "common.h"
#include "npc.h"
#include "port/Engine.h"
#include "port/patches/Patches.h"

#ifndef PARTY_IMAGE
#error "Define PARTY_IMAGE to the asset name to use LoadPartyImage."
#endif

#define PARTY_IMAGE_WIDTH 150
#define PARTY_IMAGE_HEIGHT 105

#define PARTY_IMAGE_PATH "__OTR__party/" PARTY_IMAGE
#define PARTY_IMAGE_PAL_PATH PARTY_IMAGE_PATH "_pal"

API_CALLABLE(N(LoadPartyImage)) {
    static MessageImageData image;

    // Drawn by name where the archive has the portrait as a texture
    image.palette = (PAL_BIN*)port_named_image(PARTY_IMAGE_PATH, "_img_tlut", LOAD_ASSET(PARTY_IMAGE_PAL_PATH));
    image.raster = (IMG_BIN*)port_named_image(PARTY_IMAGE_PATH, "_img", LOAD_ASSET(PARTY_IMAGE_PATH));
    image.width = PARTY_IMAGE_WIDTH;
    image.height = PARTY_IMAGE_HEIGHT;
    image.format = G_IM_FMT_CI;
    image.bitDepth = G_IM_SIZ_8b;
    set_message_images(&image);
    return ApiStatus_DONE2;
}

#undef PARTY_IMAGE_PAL_PATH
#undef PARTY_IMAGE_PATH
#undef PARTY_IMAGE
