#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"

#define BRAM_ADDR 0x40000000

static const u32 preset_offset[2] = {0x0, 0x4};
static const u32 pattern [2] = { 60, 20};
u32 addr, d;

int main(void){
    
    xil_printf("Set BRAM data:\r\n");

    for (int i = 0; i < 2; i++) {
        addr = BRAM_ADDR + preset_offset[i];
        Xil_Out32(addr, pattern[i]);
        xil_printf("Wrote %d to address 0x%08X\r\n", pattern[i], addr);
    }
    xil_printf("\r\n");
    xil_printf("Read the Result:\r\n");
    d = Xil_In32(BRAM_ADDR + 0xC);
    xil_printf("Read %d @ +0x%08X\r\n", d, BRAM_ADDR + 0xC);
    return 0;
}