#include "hos_00.h"
#include "model.h"
#include "port/Engine.h"

void N(setup_gfx_background_shade)(void) {
    s32 alpha = update_lerp(EASING_LINEAR, 0.0f, 216.0f, gPlayerStatus.pos.x - 200.0f, 500);
    Model* model;
    ModelBoundingBox* bb;
    f32 cx = 0.0f;
    f32 sx;
    Matrix4f tNeg, scl, tPos, tmp, m;
    Mtx* dispMtx;

    if (alpha < 0) {
        alpha = 0;
    }
    if (alpha > 216) {
        alpha = 216;
    }
    gDPSetCycleType(gMainGfxPos++, G_CYC_1CYCLE);
    gDPSetCombineMode(gMainGfxPos++, PM_CC_HOS_BG_SHADE, PM_CC_HOS_BG_SHADE);
    gDPSetPrimColor(gMainGfxPos++, 0, 0, 0, 0, 0, alpha);

    sx = GameEngine_GetAspectRatio() / (4.0f / 3.0f);
    if (sx < 1.0f) {
        sx = 1.0f;
    }
    sx *= 1.05f; // small overscan, harmless for a tint, avoids a seam at the edge

    model = get_model_from_list_index(get_model_list_index_from_tree_index(MODEL_g107));
    if (model != NULL) {
        bb = (ModelBoundingBox*) get_model_property(model->modelNode, MODEL_PROP_KEY_BOUNDING_BOX);
        if (bb != NULL) {
            cx = (bb->minX + bb->maxX) * 0.5f;
        }
    }

    guTranslateF(tNeg, -cx, 0.0f, 0.0f);
    guScaleF(scl, sx, 1.0f, 1.0f);
    guTranslateF(tPos, cx, 0.0f, 0.0f);
    guMtxCatF(tNeg, scl, tmp);
    guMtxCatF(tmp, tPos, m);

    dispMtx = &gDisplayContext->matrixStack[gMatrixListPos++];
    guMtxF2L(m, dispMtx);
    gSPMatrix(gMainGfxPos++, dispMtx, G_MTX_MODELVIEW | G_MTX_MUL | G_MTX_PUSH);
}

void N(restore_gfx_background_shade)(void) {
    // Pop the widening matrix pushed by the 'pre' builder so the stack stays balanced.
    gSPPopMatrix(gMainGfxPos++, G_MTX_MODELVIEW);
}

EvtScript N(EVS_SetupBackgroundShade) = {
    Call(SetModelCustomGfx, MODEL_g107, CUSTOM_GFX_1, ENV_TINT_UNCHANGED)
    Call(SetCustomGfxBuilders, CUSTOM_GFX_1, Ref(N(setup_gfx_background_shade)), Ref(N(restore_gfx_background_shade)))
    Return
    End
};
