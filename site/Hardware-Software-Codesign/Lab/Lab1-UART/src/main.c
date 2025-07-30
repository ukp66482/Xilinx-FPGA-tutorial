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

#include <stdlib.h>
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h" //u8 type
#include "xuartps.h" //UART device
#include "xparameters.h" //device ID
#include "sleep.h"

#define BAUDRATE 115200
#define IMAGESIZE 512 * 512
#define HEADERSIZE 1080
#define FILESIZE IMAGESIZE + HEADERSIZE

int main(){
	u8 *imageData;
	u32 recvBytes = 0;
	u32 totalRecvBytes = 0;
	u32 transmittedBytes = 0;
	u32 totaltransmittedBytes = 0;
	s32 status;
	imageData = malloc(sizeof(u8) * IMAGESIZE + HEADERSIZE);

    if (imageData == NULL) {
    printf("malloc failed!\n");
    return -1;
    }

	XUartPs_Config *myUartConfig;
	XUartPs myUart;
	myUartConfig = XUartPs_LookupConfig(0); // UART 0 device
	status = XUartPs_CfgInitialize(&myUart, myUartConfig, myUartConfig->BaseAddress);
	if(status != XST_SUCCESS){
		printf("UART Initialization FAIL!!");
	}

	status = XUartPs_SetBaudRate(&myUart, BAUDRATE);
	if(status != XST_SUCCESS){
			printf("Baud rate Initialization FAIL!!");
	}

	//Data transfer from Computer to DDR
	while(totalRecvBytes < FILESIZE){
		recvBytes = XUartPs_Recv(&myUart, (u8*)&imageData[totalRecvBytes], 100);
		totalRecvBytes += recvBytes;
	}

	//Read Data from DDR, process it, store back in DDR
    //Complete yourself



    //Complete yourself

	//Send Data to the Computer
	while(totaltransmittedBytes  < FILESIZE){
		transmittedBytes = XUartPs_Send(&myUart, (u8*)&imageData[totaltransmittedBytes], 1);
		totaltransmittedBytes += transmittedBytes;
	}
	return 0;
}