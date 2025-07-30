/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

// #include <stdio.h>
// #include "platform.h"
// #include "xil_printf.h"


#include <stdio.h>

int main() {
    int numbers[5];
    int i, j, temp;

    // Enter five integers
    printf("Please enter five integers:\n");
    for(i = 0; i < 5; i++) {
        printf("Number %d: ", i + 1);
        scanf("%d", &numbers[i]);
    }

    // Sorting algorithm (to be implemented by yourself)



    // Sorting algorithm (to be implemented by yourself)
    
    // Output the sorted result
    printf("\nSorted result:\n");
    for(i = 0; i < 5; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");

    return 0;
}

