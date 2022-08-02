# HW4 - Web Services
## HTTP Server
1. HSTS: 加個 `Strict-Transport-Security` 的 header
2. `server_tokens off;` 來關掉 version number
3. 做一下 virtual host

## Database
1. MySQL 建個 user 然後調整一下權限
2. 權限的部分在 MySQL 5.6 不會過，要到 8.0

## Kernel Module
1. 照著 TA 給的 code & instructions 去 build module
2. 用 JS 去戳 websocket，然後用 chartjs 去弄圖表
