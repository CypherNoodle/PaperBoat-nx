#include "common.h"

#ifdef SHIFT
BSS u8 WorldEntityHeapBottom[WORLD_ENTITY_HEAP_SIZE];
#endif
BSS u8 WorldEntityHeapBase[0x10];
BSS u8 heap_collisionHead[COLLISION_HEAP_SIZE];
// heap_battleHead must be large enough for BATTLE_HEAP_SIZE bytes — _heap_create writes into it
BSS u8 heap_battleHead[BATTLE_HEAP_SIZE];
