#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"
#define XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR 0x40000000
#define XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR 0x42000000

static const u32 preset_offset[4] = {0, 4, 28, 64};
static const u32 offsets[5] = { 8, 12, 36, 72 , 4092};
static const u32 pattern [5] = { 0x2597U, 0x6425U,
                                 0x5071U, 0x8CF5U, 
                                 0xffffU};

int main(void){
    xil_printf("Preset data read:\r\n");
    for (int i = 0; i < 4; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + preset_offset[i]);
        xil_printf("Read  0x%08lx @ +%d\r\n", d, preset_offset[i]);
    }

    xil_printf("\r\nPort A read after write:\r\n");
    for (int i = 0; i < 5; ++i) {
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offsets[i], pattern[i]);
        xil_printf("Port A Write 0x%08lx @ +%d\r\n", pattern[i], offsets[i]);
    }

    xil_printf("\r\nPort A Read back\r\n");
    for (int i = 0; i < 5; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offsets[i]);
        xil_printf("Port A Read 0x%08lx @ +%d\r\n", d, offsets[i]);
    }

    xil_printf("\r\nPort B read after write:\r\n");
    for (int i = 0; i < 5; ++i) {
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offsets[i], pattern[4 - i]);
        xil_printf("Port B Write 0x%08lx @ +%d\r\n", pattern[4 - i], offsets[i]);
    }

    xil_printf("\r\nPort B Read back\r\n");
    for (int i = 0; i < 5; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offsets[i]);
        xil_printf("Port B Read 0x%08lx @ +%d\r\n", d, offsets[i]);
    }

      xil_printf("\r\n--- Start March C (Port A) ---\r\n");
    // ↑ (w0)
    for (int i = 0; i < 1024; ++i) {
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4, 0x00000000);
    }

    // ↑ (r0, w1)
    for (int i = 0; i < 1024; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4);
        if (d != 0x00000000) {
            xil_printf("Port A MarchC ERROR ↑r0 @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4, 0xFFFFFFFF);
    }

    // ↓ (r1, w0)
    for (int i = 1023; i >= 0; --i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4);
        if (d != 0xFFFFFFFF) {
            xil_printf("Port A MarchC ERROR ↓r1 @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4, 0x00000000);
    }

    // ↑ (r0)
    for (int i = 0; i < 1024; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i * 4);
        if (d != 0x00000000) {
            xil_printf("Port A MarchC ERROR ↑r0 final @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
    }
    xil_printf("--- Port A March C Done ---\r\n");

    xil_printf("\r\n--- Start March C (Port B) ---\r\n");
    // ↑ (w0)
    for (int i = 0; i < 1024; ++i) {
        Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4, 0x00000000);
    }

    // ↑ (r0, w1)
    for (int i = 0; i < 1024; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4);
        if (d != 0x00000000) {
            xil_printf("MarchC ERROR ↑r0 fail @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
        Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4, 0xFFFFFFFF);
    }

    // ↓ (r1, w0)
    for (int i = 1023; i >= 0; --i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4);
        if (d != 0xFFFFFFFF) {
            xil_printf("MarchC ERROR ↓r1 fail @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
        Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4, 0x00000000);
    }

    // ↑ (r0)
    for (int i = 0; i < 1024; ++i) {
        u32 d = Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i * 4);
        if (d != 0x00000000) {
            xil_printf("MarchC ERROR ↑r0 final fail @ +%d: read 0x%08lx\r\n", i * 4, d);
        }
    }
    xil_printf("--- Port B March C Done ---\r\n");

    return 0;
}

