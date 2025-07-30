#include <stdio.h>
#include <xgpio.h>
#include "xparameters.h"
#include "sleep.h"

// Define RGB LED output values

#define GREEN_LIGHT 0b010
#define YELLOW_LIGHT 0b110
#define RED_LIGHT 0b100

#define CHECK_BIT(var, pos) ((var) & (1 << (pos)))  // Get specific bit value

// Get the corresponding name of the light
const char* get_light_name(unsigned light) {
    switch(light) {
        case GREEN_LIGHT:  return "GREEN";
        case YELLOW_LIGHT: return "YELLOW";
        case RED_LIGHT:    return "RED";
        default:           return "UNKNOWN";
    }
}

int main()
{
   XGpio gpio0;
   unsigned switch_data = 0;
   unsigned light = GREEN_LIGHT;
   unsigned cnt = 15;

   // Initialize the GPIO device
   XGpio_Initialize(&gpio0, XPAR_AXI_GPIO_0_DEVICE_ID);
   XGpio_SetDataDirection(&gpio0, 2, 0xF);  // Set switches as input
   XGpio_SetDataDirection(&gpio0, 1, 0x0);  // Set RGB LED as output

   // Initial state: green light for 15 seconds
   light = GREEN_LIGHT;
   cnt = 15;

   while (1) {
      switch_data = XGpio_DiscreteRead(&gpio0, 2); // Read switch status

      // Display current light and countdown
      printf("Light: %s, Countdown: %d seconds\n", get_light_name(light), cnt);

      // Write RGB light value
      XGpio_DiscreteWrite(&gpio0, 1, light);

      sleep(1);  // Wait for 1 second
      cnt--;

      if (cnt == 0) {
         switch (light) {
            case GREEN_LIGHT:
               light = YELLOW_LIGHT;
               cnt = 1;  // Yellow light always lasts 1 second
               break;
            case YELLOW_LIGHT:
               light = RED_LIGHT;
               cnt = CHECK_BIT(switch_data, 0) ? 8 : 16;
               break;
            case RED_LIGHT:
               light = GREEN_LIGHT;
               cnt = CHECK_BIT(switch_data, 0) ? 7 : 15;
               break;
         }
      }
   }

   return 0;
}
