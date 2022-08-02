# HW3 - File Server & Backup
## HW3-1 File Server
1. `sysadm` 直接在系統開一個使用者
2. `ftp-vip1` 和 `ftp-vip2` 則用 `pure-pw` 來開使用者。他們的名義是一個系統使用者 `ftpuser`，他的 group 是 `virtualgroup`
3. 匿名登入要打開，但 `AnonymousCanCreateDir` 要關掉、`AnonymousCantUpload` 也要關掉
4. 在 ftp 的目錄裡面，將全部檔案 owner 都設成 `sysadm`，group 為 `virtualgroup`
5. `upload` 需要加上 sticky bit
6. `hidden` 要 `chmod o-r`，但裡面的 `treasure` 要把 `r` 加回來
7. syslog 調好 log 目的地

## HW3-2 pure-ftpd uploadscript With Adv. Logs
1. config 的 `CallUploadScript` 要打開
2. 寫一個 daemon 放在 `/usr/local/etc/rc.d`
3. pure-ftpd 有提供一些變數給 uploadscript，可以直接拿來用
4. syslog 調好 log 目的地

## HW3-3 ZFS & Backup
1. 用 `zpool` 去建 mirror
2. 用 `zfs` 指令去把 spec 的功能幹出來，要放進 path 裡面
