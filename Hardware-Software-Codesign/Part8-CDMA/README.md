# Part8-CDMA

本章將介紹如何在 PYNQ 上使用 AXI Central Direct Memory Access (CDMA) 模組實現高效能的 Memory-to-Memory 資料搬運，並比較硬體搬運與 CPU 軟體搬運 (memcpy) 的效能差異。

## CDMA Module

AXI CDMA (Central Direct Memory Access) 是一個專門用來在記憶體映射 (Memory-Mapped) 空間之間搬運資料的硬體模組。

不同於一般的 DMA (Part 7) 主要是處理 Stream 介面 (如 AXI-Stream to Memory)，CDMA 專注於 Memory-to-Memory 的傳輸。這裡的 Memory 是指系統中所有映射在實體位址上的儲存空間，包含：

1. 外部記憶體 (Off-chip DDR SDRAM)：容量最大，通常作為主記憶體。

2. FPGA 內部記憶體 (On-chip Block RAM, BRAM)：位於 PL 端，速度快但容量小。

3. 晶片上記憶體 (On-Chip Memory, OCM)：位於 PS 端，低延遲的快取與共享區。

CDMA 能夠透過 AXI 匯流排，高效地在上述這些不同的實體記憶體介質之間 (例如：DDR to BRAM, 或 DDR to DDR) 進行資料搬運，而不需要 CPU 介入。

CDMA 主要用於大量資料的傳輸，通常會發生在 DDR to DDR 。

### Port Description

![AXI_CDMA_block](./png/AXI_CDMA_block.png)

CDMA 的介面比一般 DMA 單純，主要分為「控制」與「數據」兩大類：
| 介面名稱 | 方向 | AXI 類型 | 功能描述 |
|---------|------|----------|---------|
| S_AXI_LITE | Slave | AXI4-Lite | 控制介面。連接至 ZYNQ PS 的 GP Port。CPU 透過這個介面讀寫 CDMA 的暫存器 (Registers)，例如設定來源地址、目的地址、搬運長度等。 |
| M_AXI | Master | AXI4 | 數據傳輸介面 (Data Interface)。連接至 ZYNQ PS 的 HP Port (High Performance)。CDMA 透過這個介面直接向 DDR 記憶體發出讀取 (Read) 與寫入 (Write) 請求，不需經過 CPU。 |
| M_AXI_SG | Master | AXI4 | 分散集合介面 (Scatter Gather)。CDMA 透過這個介面從記憶體中讀取「搬運清單」(Descriptors)。它讓 CDMA 能自動執行一連串不連續的搬運任務，而不需要 CPU 介入每一次傳輸。 | 
| cdma_introut | Output | Interrupt | 中斷訊號。當搬運完成或發生錯誤時，可發送中斷通知 CPU 。 |

### Settings

![AXI_CDMA](./png/AXI_CDMA.png)

- Enable Scatter Gather:

  - Unchecked: 使用 Simple Mode。這是最單純的模式，CPU 每次給一個來源、一個目的、一個長度，CDMA 就搬一次。適合大區塊資料搬運。

  - Checked: 使用 Scatter-Gather (SG) Mode。適合搬運分散在記憶體不同位置的破碎資料 (Linked List)，控制較複雜。

- Write/Read Data Width:

  - 設定資料匯流排的寬度 (例如 64-bit 或 32-bit)。

  - 建議配合 Zynq HP Port 的設定 (通常設為 64 或 32)，寬度越寬，單次 Clock 搬運的資料量越大，頻寬越高。

- Write/Read Burst Size:

  - 決定一次 AXI 傳輸突發 (Burst) 的長度。數值越大 (如 16, 32, 64)，匯流排利用率通常越高。

## Part 8.1 Block Design

1. Create a new Vivado Project and Create a new Block Design
   
2. 加入`ZYNQ7 Processing System`，點`Run Block Automation`
   
3. 設定`ZYNQ7 Processing System`，點`PS-PL Configuration`，打開`HP Slave AXI Interface`，勾選 `S AXI HP0 interface`
   
![ZYNQ7](./png/ZYNQ7.png)

4. 加入`AXI Central Direct Memory Access`，在設定中取消勾選`Enable Scatter Gather`
* `Scatter Gather`模式允許`CDMA`讀取位於記憶體中的`Descriptor Chain`，此次lab用不到
   
![AXI_CDMA](./png/AXI_CDMA.png)

5. 加入`AXI BRAM Controller`，將`Number of BRAM Interfaces`設為`1`
   
![AXI_BRAAM](./png/AXI_BRAM.png)

6. 加入`Block Memory Generator`
   
7. 加入2個`AXI SmartConnect`，把`Number of Master Interfaces`設為2

![AXI_SmartConnect](./png/AXI_SmartConnect.png)

8. 手動接線
    - Zynq M_AXI_GP0 -> AXI SmartConnect (1號) 的 S00_AXI
    - AXI SmartConnect (1號) 的 M00_AXI -> CDMA 的 S_AXI_LITE
    - AXI SmartConnect (1號) 的 M01_AXI -> AXI SmartConnect (2號)的S01_AXI
    - CDMA M_AXI -> AXI SmartConnect (2號) 的 S00_AXI
    - AXI SmartConnect (2號) 的 M00_AXI -> Zynq 的 S_AXI_HP0
    - AXI SmartConnect (2號) 的 M01_AXI -> BRAM Controller 的 S_AXI
    - BRAM Controller 的 BRAM_PORTA -> Block Memory Generator 的 BRAM_PORTA。

9. 接完後按`Run Connection Automation`，結果如下圖
   
![Block_Design](./png/Block_Design.jpg)

10. 在`Address Editor`按下`Assign All`後，記錄下`axi_bram_ctrl_0`的`Master Base Address`，並且將`Range`改成`64K`，如附圖所示。修改後記得回到`Block Design`做`Validate Design`

![Address_Editor](./png/Address_Editor.png)

* 此Address是`CPU`用來檢查搬運結果的地方。當`CDMA`說搬運完成後，`CPU`會讀取這個地址來驗證資料是否正確
* `Range`代表`IP`在系統記憶體地圖中所佔用的「地址空間大小」
* `BRAM Controller (axi_bram_ctrl_0)`同時連接著`Zynq CPU (processing_system7_0)`以及`CDMA (axi_cdma_0)`，因此兩邊的Range大小皆需要修改

11. 在Jupyter中建一個資料夾上傳`example.ipynb`, `.bit`檔, `.hwh`檔, `example1.txt`(範例文檔)，並執行`example.ipynb`。
記得要確認程式碼中的`.bit`檔名與自己的檔案吻合，`.hwh`檔名要與`.bit`檔相同，且`BRAM_PHYS_ADDR`要與上個步驟中`Address Editor`中的`Master Base Address`相同，`BRAM_SIZE_LIMIT`也要確認，如下圖所示

![Name_Check](./png/Name_Check.png)

12. 若執行後輸出包含`Transfer Complete!` 即代表結果正確

![Success](./png/Success.png)

13. `CDMA path` vs. `CPU path`

* CDMA 是為了「批次搬運」設計的。它使用 AXI4 協定中的 Burst 傳輸（一次Handshaking，傳輸多筆資料），效率高
    * 讀取路徑 (Source: DDR):
    `CDMA (M_AXI)` 發出讀取請求 -> `AXI SmartConnect 2` -> `ZYNQ HP0 Port` (High Performance) -> `DDR Controller`

    * 特點：HP Port 專為高頻寬設計，直通 DDR，不經過 CPU 的 L1/L2 Cache

    * 寫入路徑 (Dest: BRAM):
`CDMA (M_AXI)` 取得資料後 -> `AXI SmartConnect 2` -> `AXI BRAM Controller` -> `Block Memory Generator`

* CPU 資料路徑 (Low-Volume / Single Beat)
當你在 Python 寫 `bram.read()` 或 `input_buffer[i]` = ... 時，是 CPU 在做事。

    * 路徑:
`CPU Core` (ARM) -> `ZYNQ GP0 Port` (General Purpose) -> `AXI SmartConnect 1` -> `AXI SmartConnect 2` -> `AXI BRAM Controller` -> `BRAM`

    * 比較:

        * GP Port 是 32-bit Master，主要設計給「控制訊號」用（設定暫存器）。

        * CPU 搬運是 Linear execution：讀指令 -> 讀資料 -> 寫資料 -> 迴圈。每次存取都需要完整的 AXI 握手，無法像 CDMA 一樣使用長 Burst。
