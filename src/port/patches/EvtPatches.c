#include "common.h"
#include "evt.h"
#include "port/patches/Patches.h"

// Read a pointer-sized element from a host-pointer array into an EVT variable.
//
// EVT's BufRead1 reads s32 (4 bytes) per entry, which truncates host pointers
// on 64-bit builds. Scripts that walk a `T*[]` table with
// `UseBuf(Ref(arr)) / Loop / BufRead1(LVarX) / UseBuf(LVarX)` end up using a
// half-pointer as the next buffer base and crash on the first read.
//
// Bytecode is intptr_t, so storing the resolved pointer through
// evt_set_variable preserves the full address. Subsequent UseBuf(LVarX) reads
// it back as a real pointer.
//
// args: arrayPtr (Ref to T*[]), index, count (ARRAY_COUNT), outVar.
// index is wrapped into [0, count) so callers don't have to. Count is required
// because EVT can't compute ARRAY_COUNT itself.
API_CALLABLE(LoadPtrFromArray) {
    Bytecode* args = script->ptrReadPos;

    void** array = (void**) evt_get_variable(script, *args++);
    s32 index = evt_get_variable(script, *args++);
    s32 count = evt_get_variable(script, *args++);
    Bytecode outVar = *args++;

    if (count <= 0) {
        count = 1;
    }
    s32 i = index % count;
    if (i < 0) {
        i += count;
    }

    evt_set_variable(script, outVar, (Bytecode)(intptr_t) array[i]);

    return ApiStatus_DONE2;
}
