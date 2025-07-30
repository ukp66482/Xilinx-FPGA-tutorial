/***************************** Include Files *******************************/
#include "Bitonic_sorter.h"
#include <stdio.h>
/************************** Function Definitions ***************************/
void bitonic_sort(UINTPTR baseAddr, u32 data, u8 direction){
    u32 result = 0;
    u8 done = 0;
	BITONIC_SORTER_mWriteReg(baseAddr, 4, data);
    BITONIC_SORTER_mWriteReg(baseAddr, 8, direction); //direction
    BITONIC_SORTER_mWriteReg(baseAddr, 0, 0x1); //start -> 1
	
    do {
        done = BITONIC_SORTER_mReadReg(baseAddr, 0);
    } while (done == 0);

    result = BITONIC_SORTER_mReadReg(baseAddr, 4);

    BITONIC_SORTER_mWriteReg(baseAddr, 0, 0x0); //start -> 0
    printf("%x -> %x\r\n",data, result);

    return; 
}