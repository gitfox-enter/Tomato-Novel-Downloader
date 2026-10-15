# Release 下载与校验

## 下载

**Releases** 页面下载 `番茄小说下载器-Windows绿色版.zip`（约 5 MB）。

## 文件校验

| 文件 | 大小（字节） | SHA256 |
|---|---|---|
| `tomato-novel-downloader.exe`（官方 Win64 v2.4.15，未修改） | 12,105,728 | `4e3cdf7890005a9d26615ccfbb7c5daca30a16850fcb6ac48ca1ab209a4eb893` |
| `番茄小说下载器-Windows绿色版.zip`（本包） | 5,112,363 | `026b31c5c1526e3b1d5b833ed1788b7d7019ba76e9833414dd3803a059399b85` |

解压后可自行校验：

```powershell
Get-FileHash .\tomato-novel-downloader.exe -Algorithm SHA256
```

## zip 内容清单

```
番茄小说下载器-Windows绿色版/
├── README.md                        使用说明
├── tomato-novel-downloader.exe      官方程序本体（未修改）
├── 启动.vbs                         一键启动（GBK，后台静默，不开浏览器）
├── 关闭.vbs                         一键关闭
└── 账号密码.txt                     访问信息
```

运行时才会生成 `data\`（配置、日志）与 `downloads\`（下载的小说）。
**发布包内不含任何个人数据。**

## 端口速查

| 用途 | 地址 |
|---|---|
| 网页 | http://127.0.0.1:18423/ |

服务只监听 `127.0.0.1`，`localhost` 以外的地址无法访问。
若要局域网使用，把 `启动.vbs` 里的 `127.0.0.1` 改成 `0.0.0.0`，
并自行在 Windows 防火墙放行 18423 端口——**此时请务必设置密码**。
