# HW3 - File Server & Backup
## HW3-1 File Server
### 題目
用 pure-ftpd 建一台 file server，裡面有三個目錄：
1. `/home/ftp/public`
    - 每個人都可以上傳和下載檔案
    - 除了匿名使用者之外，每個人都可以 `mkdir`、`rmdir`、`rm`
2. `/home/ftp/upload`
    - 每個人都可以上傳或下載檔案
    - 除了匿名使用者之外，每個人都可以 `mkdir`
    - 每個人都可以刪除自己建的檔案或目錄 (匿名使用者都不可)，而 `sysadm` 可以任意刪除
3. `/home/ftp/hidden`
    - 裡面有一個目錄 `hidden`，在裡面又有一個目錄 `treasure`，裡面又有一個檔案 `secret`，匿名使用者不能 `ls hidden`，但可以 `cd` 進 `treasure`，也可以看到 `secret` 的內容

### 解法
