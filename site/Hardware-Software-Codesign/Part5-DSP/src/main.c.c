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

#include <stdio.h>
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"

int main(){

	#define addr_gpio_A 0x41200000
	#define addr_gpio_B 0x41210000

    #define addr_gpio_P 0x41230000

	int32_t A, B;
	int32_t P;

	printf("Program starts.\r\n");

	while(getchar() != EOF)
	{
		printf("Input A (16-bit) :");
		scanf("%d", &A);
		printf("%d\r\n", A);

		printf("Input B (16-bit) :");
		scanf("%d", &B);
		printf("%d\r\n", B);


		Xil_Out32(addr_gpio_A, A);
        Xil_Out32(addr_gpio_B, B);

		P = Xil_In32(addr_gpio_P);

		printf("A * B = %d\r\n", P);


	}

	return 0;

}