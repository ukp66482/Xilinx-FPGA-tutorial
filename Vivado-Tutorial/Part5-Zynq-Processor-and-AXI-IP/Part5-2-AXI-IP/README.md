# Part 5-2 AXI-IP

## Introduce to AXI Interface
### 🔷 AXI 是什麼？
AXI（Advanced eXtensible Interface）是一種常見的資料傳輸協定，主要用在 SoC（像 Zynq 或 PYNQ-Z2 這種把 ARM 處理器和 FPGA 合在一起的晶片）裡面，讓不同的元件之間可以互相傳送資料或控制指令。

在 PYNQ-Z2 上，我們常用 AXI 來讓 ARM 處理器控制我們自己設計的 FPGA 模組，例如：

✅ 啟動某個功能

✅ 設定參數

✅ 傳送資料過去運算

### 🔷 AXI 在 Zynq / PYNQ-Z2 上是做什麼用的？
在 Zynq 裡面有兩大部分：

- PS（Processing System）：ARM 處理器
- PL（Programmable Logic）：FPGA（你寫的 Verilog / IP）

AXI 就是 PS 和 PL 溝通的橋樑，幫助他們「講話」和「搬資料」：
| 你想做的事             | AXI 的幫助                        |
| ----------------- | ------------------------------ |
| ARM 控制 FPGA 的模組運作 | 用 AXI-Lite 把設定值寫進去             |
| ARM 把資料交給 FPGA 運算 | 用 AXI-Full 或 AXI-Stream 搬資料    |
| ARM 告訴 DMA 去搬資料   | DMA 設定用 AXI-Lite，搬資料用 AXI-Full |

### 🔷 AXI 有哪些種類？
AXI 有幾種不同版本，根據用途分成下面幾類：
| 種類                 | 特點                       | 適合做什麼                        |
| ------------------ | ------------------------ | ---------------------------- |
| **AXI-Lite**       | 傳送方式簡單，一次只傳一筆資料。         | 拿來**控制** FPGA 模組，比如設定值、啟動運算。 |
| **AXI-Full（AXI4）** | 可以一次傳很多筆資料（支援 burst 傳輸）。 | 拿來**大量搬資料**，像是影像、音訊、記憶體資料等。  |
| **AXI-Stream**     | 資料像水流一樣連續傳送，沒有地址的概念。     | 拿來做連續處理，例如影像濾波、音訊處理、AI 推論等。  |

## Simple Implementation with AXI-IP (AXI GPIO IP)
### Step 1. Create a new project
加入 [Constraints](./xdc/pynq-z2_v1.0.xdc)
### Step 2. Create block design
加入三個 IP ```ZYNQ7 Processing System```、```AXI GPIO*2```

![Create_Block_design](./images/create_block_design_24.jpg)

Run Block Automation > OK (全部勾選)

Run Connection Automation > OK (全部勾選)

Vivado 會自動幫我們接上 AXI Interconnection 形成下圖。

![Block_design_done](./images/block_design_done_24.jpg)

點開 AXI GPIO IP 將 GPIO 改成 Custom (兩個 AXI GPIO IP 都要改)。
![gpio_custom](./images/gpio_custom_24.jpg)

切換到 IP Configuration，分別改成以下兩個設定，兩個 GPIO 一個是接到 LEDs 一個是接到 Switches。
![ip1_conf](./images/ip1_conf_24.jpg)

![ip2_conf](./images/ip2_conf_24.jpg)

設定完成後，在 External Interface Properties 更改連接出去的 port name，方便辨認。
![gpio_name](./images/gpio_name_24.jpg)

將完成的 block design 包成 HDL wrapper

### Step 3. Generate bitstream & Export Hardware
File > Export > Export Hardware。
📌 因為 AXI GPIO 是由 programmable logic 執行的所以需產生 bitstream 將 AXI GPIO 燒錄到 FPGA 上。

📌 由於有產生 bitstream 所以 include bitstream 的選項需打勾。
![include_bitstream](./images/include_bitstream_24.jpg)

### Step 4. Launch Vitis IDE & Write a LEDs control program
#### Vivado
Tools > Launch Vitis IDE

#### Vitis
Open workspace ，並且 Create Platform Component，選擇前面產生的 XSA 檔案。

利用 Example 建立完整的環境，並選擇前面完成的 platform。
![create_application](./images/create_application_24.jpg)

置換 application project 下的 Sources/src/helloworld.c 為 ./src/led.c。

硬體中所有資源都有他所屬的地址，地址要到 platform\export\platform\sw\standalone_ps7_cortexa9_0\include\xparameters.h 查詢。

最後一步，先 build platform 後，再 build application。

連上 PuTTY 後，執行 application 的 Run ，試著調整開關，觀察其結果。

