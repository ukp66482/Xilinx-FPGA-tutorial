# Part 5-1 Zynq Processor

## What is Zynq?
Zynq SoC 是結合了 PS(Processor System) 端和 PL(programmable Logic) 端的裝置
- PS (Processor System) : 硬體內建 ARM Cortex-A9 雙核心處理器 (Zynq-7000系列) 加上 caches、on-chip memory、還有其他peripherals (UART, I2C, etc.) 。
- PL (Programmable Logic) : 可自定義邏輯的 FPGA 區塊，也就是使用者可以自己設計特定功能的 IP，像是加解密模組、影像處理器、DMA模組等，並藉由AXI接口(控制/資料搬移/中斷)與 PS 搭配運作。

![zynq_intro](./png/zynq_intro.png)

## What is PYNQ?
PYNQ = Python + ZYNQ，就是將 Xilinx ZYNQ 的部分功能 Python 化，直接使用 Python 資料庫與 FPGA 硬體進行功能的開發。
![pynq1](./png/pynq1.png)
![pynq2](./png/pynq2.png)

## Zynq Development
Zynq 分為兩大部分，如上面提到的，分別為 PS(Processing System) 端跟 PL(Programmable Logic) 端。以下實例使用PYNQ-Z2 上現有的 Zynq Processor 實作一個簡單的 C/C++ Project。

### Step 1. Download PuTTY
Here's [PuTTY](https://www.putty.org/)

### Step 2. Create a new project
由於本次是使用 FPGA 上固有的 Processor，所以不需加入任何 HDL code 及 Constraints。

### Create block design
加入 ZYNQ7 Processing System IP
![ZYNQ_IP_24](./png/ZYNQ_IP_24.jpg)

按下 Run Block Automation
![ZYNQ_run_24](./png/ZYNQ_run_24.jpg)

執行完畢 ZYNQ processor 會連出兩個 ports。
點開 ZYNQ processor 更改設定。本次實驗只需用到 ZYNQ processor 本身，所以要把沒用到的 I/O 取消。
![ZYNQ_set_24](./png/ZYNQ_set_24.jpg)

PS-PL Configurations > General > Enable Clock Resets > FCLK_RESET0_N 取消勾選。 PS-PL Configurations > AXI Non Secure Enablement > GP Master AXI Interface > M AXI GP0 Interface 取消勾選。
![PS-PL_conf_24](./png/PS-PL_conf_24.jpg)

Peripheral I/O Pins 僅留下 UART0 其餘取消勾選。
![IO_pins_24](./png/IO_pins_24.jpg)

Clock Configuration > PL Fabric Clocks > FCLK_CLK0 取消勾選。
![CLK_conf_24](./png/CLK_conf_24.jpg)

OK 後 Diagram 的 ZYNQ7 processor 會變成如下圖所示。
![ZYNQ_done_24](./png/ZYNQ_done_24.jpg)

將完成的 block design 包成 HDL wrapper。

## Step 4. Run Implementation
按下 PROJECT MANAGER > Run Implementation。
>📌 由於本次實驗僅使用 ZYNQ 現有的 ARM processor，無需產生 bitstream 所以只需執行到 Run Implementation 即可。

## Step 5. Launch Vitis IDE 
File > Export > Export Hardware。
![export_hw_24](./png/export_hw_24.jpg)

Tools > Launch Vitis IDE
![launch_Vitis_IDE_24](./png/launch_Vitis_IDE_24.jpg)

進入 Vitis 頁面
![Vitis_GUI_24](./png/Vitis_GUI_24.jpg)

選擇open workspace，並新增資料夾作為 workspace
![open_workspace_24](./png/open_workspace_24.jpg)

建立新的 platform
![create_platform_24](./png/create_platform_24.jpg)

選擇剛剛 export hardware 位置的 XSA 檔案
![select_xsa_24](./png/select_xsa_24.jpg)

Operating System: standlone(預設); Processor: ps7_cortexa9_0
![select_os_24](./png/select_os_24.jpg)

platform 完成後，圖如下
![platform_done_24](./png/platform_done_24.jpg)

## Step 6. Write a hello world program
左側欄 Examples >> Embedded Software Examples >> Hello World
![add_hello_world_24](./png/add_hello_world_24.jpg)

按下 Next 後，選擇剛剛完成的 platform
![select_platform_24](./png/select_platform_24.jpg)

按下 finish 後，頁面如下
![hello_world_done_24](./png/hello_world_done_24.jpg)

先 build platform 後再 build application，才不會發生 header file not found 的問題
![build_platform_24](./png/build_platform_24.jpg)
> 📌 要注意如果資料路徑過長會有build fail的問題

![build_application_24](./png/build_application_24.jpg)

開啟 PuTTY，選擇 Serial，輸入連接 FPGA 的 COM，設定 Baud rate 為 115200。
> 📌 接上板子並開啟電源後 -> 在 開始 右鍵 -> 裝置管理員 -> 連接埠(COM和LPT) 即可看 FPGA 是連接至哪一個 COM

![serial_port_24](./png/serial_port_24.jpg)
![putty_set_24](./png/putty_set_24.jpg)

回到 Vitis，選擇 application，並執行下方的 Run，即可在 PuTTY 看到 "Hello World!" 的結果
![application_run_24](./png/application_run_24.jpg)

