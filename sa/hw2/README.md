# HW2 - One Liner Script & System Info
## HW2-1 One liner script
### 題目
用 shell script 分析 `auth.log` (或 `secure`)，並輸出成三個檔案：
1. `audit_ip.txt`
    - 列出來源 IP 和登入失敗次數
    - `{source IP address} failed to log in {login failed times} times`
2. `audit_sudo.txt`
    - 列出 sudo 使用者和其執行的指令
    - ``{user} used sudo to do `{command}` on {date}``
    - 把日期轉成 `YYYY-MM-DD` 的格式
3. `audit_user.txt`
    - 列出使用者登入失敗次數
    - `{user} failed to log in {login failed times} times`
4. 其他需求
    - 只能用 `>` 來重導向輸出，且只能用一個
    - `awk` 裡面甚麼都能用
    - 只能單行
    - 不能多開 shell 或類似行為，如 `$(command)`, `tee`, `sh`, `&&`

### 解法
1. 因為只能用一個 `>`，所以可以用 `awk` 的 `for` 來跑三次，這三次分別是 `sudo`、`ip` 和 `user`
2. 手建一個 array 來存英文月份和數字月份的對應表

## HW2-2 System Info Panel
### 題目
寫一個 shell script (用 sh) 來做一些系統管理的相關事項：
1. Announcement
    - 可針對使用者推播，也可對全體推播
    - 可以指定訊息
2. User list
    - 列出使用者
    - 鎖定他
    - 看他的 group
    - 看他的 process 用甚麼 port
    - 看他的登入紀錄
    - 看他的 sudo 紀錄
3. 匯出資訊
4. 登入失敗太多次就鎖定，在這裡面可以打開/關掉這個功能
5. 特調 status code
6. 其他需求
    - 只能用 `sh`
    - 要寫成 TUI (`dialog`)

### 解法
1. Announcement
    1. 直接 `echo {message} > /dev/{user's tty}`
    2. `wall`, `write` 指令
2. 鎖定使用者: `pw`
3. group: `id -G {username}`
4. port: `sockstat`
5. 登入紀錄: `last`
6. sudo 紀錄: hw2-1
7. 特調 status code
    1. `trap` 抓 Ctrl-C
    2. `Esc` 預設 255，抓起來之後自己 `exit 1`
8. 登入失敗太多次就鎖定
    - 開一個 subprocess 起來跑
    - 看到錯誤太多次就 `pw lock`，存到一個暫存檔
    - 關掉的時候把暫存檔的使用者都 `pw unlock`

