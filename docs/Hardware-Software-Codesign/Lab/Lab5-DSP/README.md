# FPGA Design Lab5

本次 lab 請使用 DSP 模組來實做 Convolution sysem。

  >   📌 為什麼 DSP 適合做 Convolution？
  > 
  > 因為 convolution 的本質是大量的乘法與加法（MAC）運算，而 DSP 模組剛好內建乘加結構，能在一個時鐘週期內完成這種運算。相較用邏輯電路實作，DSP 不但運算更快、資源更省，還能支援固定點計算與並行處理，非常適合用來加速影像處理、濾波器等 convolution 應用。


## Problem1

在 `Problem1` 中，使用 `DSP` 模組去完成 `Convolution sysem`。

本系統實作一個以硬體加速為核心的 `2D Convolution` 運算模組，應用於處理固定大小（28×28）的影像輸入資料，並配合 `3×3` 的捲積核 `Kernel` 進行特徵萃取。

> 📌 系統架構與功能
> 輸入資料格式： 使用 .hex 檔案儲存 28×28 大小的影像資料，每筆為 32-bit，僅使用後 16 bits 作為實際像素值。
>
> 1. Convolution Kernel： 固定為 3×3 窗口，使用一組預定義的 16-bit 權重參數進行加權累加運算。
> 2. 邊界處理： 不使用 Zero Padding，因此輸出影像尺寸為 26×26。
> 3. 輸出資料格式： 計算結果以 32-bit 格式儲存，並輸出為 golden_32bit.hex，供後續比對與驗證。
>
> 驗證流程： 使用 Python 測試腳本比對記憶體中讀出的計算結果與 Golden Model，支援錯誤比對提示及結果輸出。
>
> 🧠 設計目的與應用
>此系統模擬典型的影像處理硬體加速應用，常見於邊緣偵測、特徵濾波與前處理等場景。透過硬體實現，可加速資料吞吐、降低延遲，並具備高度可擴展性，適合導入更複雜的 CNN 架構中作為基礎模組。


## Step 1 
加入 `CONV16.v` 到 project 後，使用 `CONV16.tcl` 去還原出 convolution system 的 project。

![](png/tcl.png)

詳細 project 介紹請看 [Extra-Lab-Convolution-system](../Extra-Lab-Convolution-system/) 。


## Step 2 
將 IP 中的 MAC 運算改成使用 `DSP48E1` 來完成。

![](png/MAC.png)

## 參考 block design
![](png/DSP.png)

<!-- ![](png/MAC.png) -->

## Problem2 - 進階題

與 Problem1 相似 ，但每筆資料與 Kernel 皆為 `32-bit`。

`.tcl `可使用 [Extra-Lab-Convolution-system](../Extra-Lab-Convolution-system/) 中的範例。



### 怎麼用 DSP48E 的 Cascade 方式完成「大位數乘法」?

> 📌 Xilinx DSP48E 基本規格回顧
>
> | Port    | 寬度限制   | 支援 signed? |
> |---------|------------|:------------:|
> | A       | 25 bits    | ✅ Yes       |
> | B       | 18 bits    | ✅ Yes       |
> | C       | 48 bits    | ✅ Yes       |
> | P (輸出)| 48 bits    | ✅ Yes       |


### 方法一：手動拆解 + 多顆 DSP 相乘再加總

將兩個 32-bit signed 數拆成 高 16-bit 和 低 16-bit。

![](png/AB.png)

依序使用 4 個 DSP48 實作乘法。

---

### 方法二：使用 Vivado HLS（High-Level Synthesis）
可以用 `C/C++` 撰寫程式，然後讓 `HLS` 自動產生 RTL（Verilog/VHDL）和對應的 `DSP48E1` 實現。

### ✅ 一、準備工具

安裝並開啟使用 `Vitis HLS`（Vivado 2021.1 之後）

### ✅ 二、基本流程
1. 打開 Vitis HLS
![](png/HLS_2023.png)
2. 新建一個 project

3. 撰寫 `C/C++ code`（如 32×32 乘法）
![](png/HLS_source.png)

4. 寫 `Testbench`（用來驗證功能）

5. 執行 `C simulation` 測試
![](png/HLS_simulation.png)

6. 設定 `Top function` : 左上方 `Project` > `Project settins` > `Synthesis` 選擇 top function。
![](png/HLS_top.png)


6. 按下 `C Synthesis` 產生 `RTL`
![](png/HLS_synthesis.png)

7. 查看報告確認 `DSP` 有被使用
![](png/HLS_report.png)

8. 匯出 `RTL` 到 `Vivado block design`
![](png/HLS_RTL.png)
