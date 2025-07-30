# Extra3-Constraint

本章將介紹 PYNQ-Z2 開發板對應的 `.xdc`（constraints file）使用方式。  

`XDC`（Xilinx Design Constraints）檔案用來告訴 Vivado： **哪些HDL內的 signal 要連接到 FPGA 的實體 pin 腳**，以及這些腳位的 **I/O 標準**、**時脈條件**等。

---

## Extra3.1   為什麼需要 constraint？

在實體 FPGA 上，`module` 中的 I/O port 並不會自動對應到開發板上的引腳位置。  
必須透過 `.xdc` 限制檔，將 RTL 中的 port 連接到具體的 **pin 編號（e.g. H17）**。

---

## Extra3.2  PYNQ-Z2 的 constraint 來源

[PYNQ-Z2 的 constraint下載連結](https://dpoauwgwqsy2x.cloudfront.net/Download/pynq-z2_v1.0.xdc.zip)  

使用時請記得：

- **取消註解**（移除 `#`）你需要使用的腳位設定
- **修改 port 名稱**（`get_ports { XXX }`）以符合你 RTL 裡的 top-level signal 名稱

### 1. Clock 來源

    Clock signal 125 MHz

    set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }];
    create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} 

純硬體 Design 時，PYNQ-Z2 的主要 Clock 輸入為 125 MHz，腳位為 H16，
你可以將 **sysclk** 改成 RTL 中的 port 名稱（e.g. clk）。

軟硬體 Codesign 時， Clock 通常都會使用到 Zynq Processing System (PS) 匯出的 FCLK，此時則不需要再使用 **set_property** ，來指定Clock腳位，create_clock 約束 Vivado 也會自動幫你生成。

### 2. Switches

    ##Switches
    #set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];
    #set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];

板上的兩個實體切換開關（SW0, SW1），對應腳位為 M20 與 M19，
RTL 中若有 input [1:0] sw 可直接取消註解並使用。

### 3. 其餘則以上述即可類推使用
  