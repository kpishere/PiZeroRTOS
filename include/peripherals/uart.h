#pragma once

#include "common.h"

#include "peripherals/base.h"

struct UartRegs {
    reg32 dr;
    reg32 rsrecr;
    reg32 fr;
    reg32 ilpr;
    reg32 ibrd;
    reg32 fbrd;
    reg32 lcrh;
    reg32 cr;
    reg32 ifls;
    reg32 imsc;
    reg32 ris;
    reg32 mis;
    reg32 icr;
    reg32 dmacr;
    reg32 itcr;
    reg32 itip;
    reg32 tiop;
    reg32 tdr;
};

#define REGS_UARTPL011 ((struct UartRegs *)(PBASE + 0x00201000))
