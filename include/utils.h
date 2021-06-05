#pragma once

#include "common.h"

void delay(u32 ticks);
void put32(u32 address, u32 value);
u32 get32(u32 address);

#ifndef __ASSEMBLER__

u32 get_el();

#endif
