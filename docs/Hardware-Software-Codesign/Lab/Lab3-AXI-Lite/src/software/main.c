#include <stdio.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "Bitonic_sorter.h"
#include "platform.h"
#define XPAR_BITONIC_SORTER_0_BASEADDR 0x40000000
typedef enum {
    DESCENDING = 0,
    ASCENDING  = 1
} SortDirection;

int main(){
    init_platform();

    printf("Ascending:\r\n");
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x77743217, ASCENDING);
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x1fb4a219, ASCENDING);
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x123489af, ASCENDING);
    printf("Descending:\r\n");
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x77743217, DESCENDING);
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x1fb4a219, DESCENDING);
    bitonic_sort(XPAR_BITONIC_SORTER_0_BASEADDR, 0x123489af, DESCENDING);

    cleanup_platform();
    return 0;
}