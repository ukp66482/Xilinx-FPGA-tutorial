# Part6-PYNQ-Jupyter-Notebook

本章將介紹如何使用 PYNQ 的 Jupyter Notebook 開發環境，透過 Python 與 Overlay ，實現軟硬體協同運作的應用開發流程。使用者可以在網頁介面中，以 Python 程式碼輕鬆控制 PL（Programmable Logic）上的硬體模組，如 GPIO、加減器、影像處理電路等。

## Part 6.1 Flashing PYNQ Image to SD Card

1. 在使用 `PYNQ` 板子前，首先需要將官方提供的映像檔（基於 Ubuntu 的 Linux 系統）燒錄到 microSD 卡中作為作業系統。

2. 下載 PYNQ 所提供的 Ubuntu 系統  

    [PYNQ Ubuntu IMG 下載連結](https://www.pynq.io/boards.html)  

    ![ISO_Download](./png/ISO_Download.png)

3. 下載燒入工具，這邊我們借用 `BalenaEtcher`，當作燒入工具  

    [BalenaEtcher 下載連結](https://etcher.balena.io/)  

    ![ISO_Flasher](./png/ISO_Flasher.png)

4. 將下載的 IMG 檔，燒入進 SD 卡當中  

    ![Flasher_UI](./png/Flasher_UI.png)

    最後按下 Flash 就可以開始燒錄了

## Part 6.2 Booting Up the PYNQ-Z2 Board

1. 將 PYNQ-Z2 的硬體配置依據下圖設置

    ![pynqz2_setup](./png/pynqz2_setup.png)

    1. 將開機模式調整至 SD 的位置。

    2. 調整電源供應模式 (使用電源供應器就接 REG；使用 USB 供電就接 USB)。

    3. 插入 micro SD。

    4. 接上電源。

    5. 插上乙太網路線，另一端與筆電連接。

    6. 開機  
    開啟電源後先不要動作，等待板子的 RGB LED 閃彩燈後四顆 LED 全亮紅燈/綠燈才代表完全開機完成。

    7. 打開 `MobaXterm` 透過 `Serial`，baud rate 設定 `115200` 連結 FPGA 即可看到 Linux 系統的 terminal 的畫面。

        ![Boot_Up](./png/Boot_Up.png)

2. 查看 PYNQ 的 IP 位置  

    ![ifconfig](./png/ifconfig.png)

3. 開啟自己電腦的網路介面卡設定，找到連接到 `PYNQ` 的 `Adapter`

    ![Network_Adapter](./png/Network_Adapter.png)

4. 將連接到 `PYNQ` 的 `Adapter`，修改 `IPv4` 設定
    - IP 設定成 192.168.2.x 可以設 192.168.2.1 ( 不要跟FPGA板本身的IP位置重複，不要設99 )
    - Subnet mask : 255.255.255.0  

    ![IPv4](./png/IPv4.png)

5. 如果沒有第2點圖中的 `inet` 可以試試看將該 `Adapter` 的共用選項打勾  

    ![Sharing](./png/Sharing.png)

6. 設定好後自己電腦的網路介面卡設定後，在 Browser 中輸入  
    - 192.168.2.99 ( FPGA 的 IP ) or pynq:9090

7. 密碼 : xilinx  

    ![Jupyter](./png/Jupyter.png)

8. 出現以下畫面就代表成功進入 PYNQ 的 Jupyter Notebook 了

    ![Final](./png/Final.png)

## Part6.3 PYNQ Overlay

1. Create Block Design，並建立如下的 Block Design，GPIO 選擇 `LED`

    ![Led_4bits](./png/Led_4bits.png)

    ![Block_Design](./png/Block_Design.png)

2. Create HDL Wrapper & Generate Bitstream

3. Export Bitstream File

    ![Export](./png/Export.png)

    > Vivado 2021.2 之後的版本，將電路燒入進去 PYNQ 裡面只需要 `*bit`、`*.hwh`，若你使用的是之前的版本還需要透過 `Export Block Design` 生成出 `*.tcl` 檔案才可以燒入

4. 連線進入 jupyter notebook，創建一個新資料夾，並上傳 `*bit`、`*.hwh`，這兩個檔案必須在相同的位置

    > 📌 `*bit`、`*.hwh` 兩者檔名需相同

    ![Upload](./png/upload.png)

    >`*hwh` 檔範例位置
    >
    >![hwh_path](./png/hwh_path.png)

5. 執行程式就可以看到輸入跟 FPGA 板上 LED 燈的關係，PYNQ 程式的部分自行理解，官方網站有提供很多library 讓我們使用  

    [PYNQ_Library_Website](https://pynq.readthedocs.io/en/v2.3/pynq_libraries.html)

    ![Run](./png/Run.png)

    > 📌 overlay = Overlay("example.bit") 是什麼意思？  
    >
    > 這行會載入名為 example.bit 的 bitstream 檔案，將你的硬體電路設計燒錄到 FPGA 上，並同時讀入對應的 .hwh 檔案來建立 IP 區塊的對應資訊（像是記憶體地址、Port連接等）。

## Additional  

[Extra4-ILA-with-PYNQ](../Extra4-ILA-with-PYNQ/)
