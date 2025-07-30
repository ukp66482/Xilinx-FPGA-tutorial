# FPGA Design Lab3

與 Lab1-UART Problem 1 相似，但請改用 Verilog 設計一個 Sorting 電路，打包成 AXI IP 後，使用 block design 的方式來完成此 Lab 。 

## Problem
設計一個排序電路，由 processor 輸入一串正整數將其排序後傳回。

1. 數字位元數自訂。(最少4bit)
2. 數列長度自訂且固定。(最少8筆數字)
3. 排序：大 → 小 、 小 → 大，二選一即可。
4. 演算法不限。


## 參考 block design
![](png/block_design.png)


## 預設結果呈現:(大到小)

```
77743217 -> 77774321

1fb4a219 -> fba94211

123489af -> fa984321
```

![](png/answer.png)
