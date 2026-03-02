#include <stdio.h>
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "sleep.h"

/* GPIO Base Address */
#define BTN_BASEADDR XPAR_AXI_GPIO_BTN_BASEADDR
#define SW_BASEADDR XPAR_AXI_GPIO_SW_BASEADDR
#define LED_BASEADDR XPAR_AXI_GPIO_LED_BASEADDR
#define INTC_BASEADDR XPAR_XSCUGIC_0_BASEADDR

/* GPIO Interrupt ID */
#define BTN_INTR_ID 61 // Buttons  -> Concat In0
#define SW_INTR_ID 62  // Switches -> Concat In1

XScuGic IntcInst;
XGpio BtnGpio;
XGpio SwGpio;
XGpio LedGpio;

void Button_ISR()
{
    usleep(50000); // 50ms delay
    u32 btn;
    if ((XGpio_InterruptGetStatus(&BtnGpio) & XGPIO_IR_CH1_MASK) != XGPIO_IR_CH1_MASK)
        return;

    btn = XGpio_DiscreteRead(&BtnGpio, 1);
    XGpio_DiscreteWrite(&LedGpio, 1, btn);

    if (btn & 0x01)
        xil_printf("btn0 pressed\r\n");
    if (btn & 0x02)
        xil_printf("btn1 pressed\r\n");
    if (btn & 0x04)
        xil_printf("btn2 pressed\r\n");
    if (btn & 0x08)
        xil_printf("btn3 pressed\r\n");

    /* Clear interrupt */
    XGpio_InterruptClear(&BtnGpio, XGPIO_IR_CH1_MASK);
}

void Switch_ISR()
{
    u32 sw;

    if ((XGpio_InterruptGetStatus(&SwGpio) & XGPIO_IR_CH1_MASK) != XGPIO_IR_CH1_MASK)
        return;

    sw = XGpio_DiscreteRead(&SwGpio, 1);

    if (sw & 0x01)
        xil_printf("sw1 ON\r\n");
    if (sw & 0x02)
        xil_printf("sw2 ON\r\n");

    XGpio_InterruptClear(&SwGpio, XGPIO_IR_CH1_MASK);
}

int Gic_Init(void)
{
    XScuGic_Config *CfgPtr;
    int status;

    CfgPtr = XScuGic_LookupConfig(INTC_BASEADDR);
    if (!CfgPtr)
        return XST_FAILURE;

    status = XScuGic_CfgInitialize(
        &IntcInst,
        CfgPtr,
        CfgPtr->CpuBaseAddress);
    if (status != XST_SUCCESS)
        return XST_FAILURE;

    /* Set trigger type: Rising Edge */
    XScuGic_SetPriorityTriggerType(&IntcInst, BTN_INTR_ID, 0xA0, 0x3);
    XScuGic_SetPriorityTriggerType(&IntcInst, SW_INTR_ID, 0xA0, 0x3);

    /* Connect BOTH interrupts to ONE ISR */
    XScuGic_Connect(&IntcInst, BTN_INTR_ID,
                    (Xil_ExceptionHandler)Button_ISR, NULL);

    XScuGic_Connect(&IntcInst, SW_INTR_ID,
                    (Xil_ExceptionHandler)Switch_ISR, NULL);

    XScuGic_Enable(&IntcInst, BTN_INTR_ID);
    XScuGic_Enable(&IntcInst, SW_INTR_ID);

    /* Register GIC handler to CPU */
    Xil_ExceptionRegisterHandler(
        XIL_EXCEPTION_ID_INT,
        (Xil_ExceptionHandler)XScuGic_InterruptHandler,
        &IntcInst);

    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

void Gpio_Init(void)
{
    /* Buttons */
    XGpio_Initialize(&BtnGpio, BTN_BASEADDR);
    XGpio_SetDataDirection(&BtnGpio, 1, 0xFF);

    /* Switches */
    XGpio_Initialize(&SwGpio, SW_BASEADDR);
    XGpio_SetDataDirection(&SwGpio, 1, 0xFF);

    /* LEDs */
    XGpio_Initialize(&LedGpio, LED_BASEADDR);
    XGpio_SetDataDirection(&LedGpio, 1, 0x00);

    /* Enable GPIO interrupts */
    XGpio_InterruptClear(&BtnGpio, XGPIO_IR_CH1_MASK);
    XGpio_InterruptEnable(&BtnGpio, XGPIO_IR_CH1_MASK);
    XGpio_InterruptGlobalEnable(&BtnGpio);

    XGpio_InterruptClear(&SwGpio, XGPIO_IR_CH1_MASK);
    XGpio_InterruptEnable(&SwGpio, XGPIO_IR_CH1_MASK);
    XGpio_InterruptGlobalEnable(&SwGpio);
}

int main()
{
    xil_printf("Zynq Interrupt Demo Start\r\n");

    Gpio_Init();

    if (Gic_Init() != XST_SUCCESS)
    {
        xil_printf("GIC Init Failed\r\n");
        return -1;
    }

    xil_printf("System Ready\r\n");

    while (1)
        ;

    return 0;
}