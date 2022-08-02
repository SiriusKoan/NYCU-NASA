# HW2 - One Liner Script & System Info
## HW2-1 One liner script
1. 因為只能用一個 `>`，所以可以用 `awk` 的 `for` 來跑三次，這三次分別是 `sudo`、`ip` 和 `user`
2. `last message repeated [0-9]* times` 也需要考慮，所以把上一行存在 `prev` 裡面，如果 repeat 的真的是 PAM error 的話就計入
3. 手建一個 array 來存英文月份和數字月份的對應表

## HW2-2 System Info Panel
1. Announcement
    1. 直接 `echo {message} > /dev/{user's tty}`
    2. `wall`, `write` 指令
2. 鎖定使用者: `pw lock/unlock`
3. group: `id -G {username}`
4. port: `sockstat`
5. 登入紀錄: `last`
6. sudo 紀錄: hw2-1
7. 特調 status code
    1. `trap` 抓 Ctrl-C
    2. `Esc` 預設 255，抓起來之後自己 `exit 1`
8. 登入失敗太多次就鎖定
    - 開一個 subprocess 起來跑，用 `/tmp/.admin_status` 控制開關
    - 用 hw2-1 的方法去看次數
    - 看到錯誤太多次就 `pw lock`，存到一個暫存檔 `/tmp/.admin_locked`
    - 關掉的時候把暫存檔的使用者都 `pw unlock`

