# 番茄小说下载器 — Windows 绿色版脚本

> **非官方整合包**。`tomato-novel-downloader.exe` 为上游官方 Release 原版文件
> （SHA256 见 [RELEASE.md](RELEASE.md)），本目录**只提供** Windows 一键启动/关闭脚本
> 与中文说明，不修改上游任何一行代码。
>
> 上游项目：https://github.com/zhongbai2333/Tomato-Novel-Downloader

## 为什么需要这一份

上游只发布官方 Release，没有 Windows 侧的启动脚本。手动跑
`tomato-novel-downloader.exe --server` 会弹一个黑窗口，关掉窗口进程就死。

这份脚本解决两件事：

1. **后台静默启动** —— 双击即跑，不弹黑框
2. **不自动打开浏览器** —— 启动后你自己决定什么时候开

## 快速开始

1. 从本 fork 的 **Releases** 下载 `番茄小说下载器-Windows绿色版.zip`
2. 解压到任意文件夹
3. 双击 **`启动.vbs`**，弹出"启动成功"即表示服务已在后台运行
4. **手动**打开浏览器访问 http://127.0.0.1:18423/
5. **无需登录**，直接用
6. 用完双击 **`关闭.vbs`**

## 访问信息

| 项 | 值 |
|---|---|
| 网页地址 | http://127.0.0.1:18423/ |
| 账号 | 无 |
| 密码 | 无 |
| 下载目录 | `downloads\` |
| 配置与日志 | `data\` |

服务只监听 `127.0.0.1`，局域网内其他设备无法访问，因此**默认不加密码是安全的**。

### 想开密码？

用记事本打开 `启动.vbs`，在 `sh.Run` 那一行**之前**加一行：

```vbscript
processEnv("TOMATO_WEB_PASSWORD") = "你的密码"
```

保存 → 双击 `关闭.vbs` → 再双击 `启动.vbs` 生效。

> ⚠️ `启动.vbs` 是 **GBK 编码**，用记事本编辑时务必选「ANSI」保存，
> 选 UTF-8 会导致中文乱码。

## 脚本做了什么

### `启动.vbs`

```
1. GET http://127.0.0.1:18423/
   ├─ 200 → 提示"已在运行"，直接退出（不会重复起进程）
   └─ 失败 ↓
2. 设置 TOMATO_WEB_ADDR=127.0.0.1:18423（只监听本机）
3. 后台启动 --server --data-dir data（窗口样式 0 = 完全隐藏）
4. 轮询首页最多 20 秒
   ├─ 通了 → 弹"启动成功"，告知地址
   └─ 没通 → 弹"启动失败"，并给出手动执行的排查命令
```

路径全部从 `WScript.ScriptFullName` 推导，**不含任何硬编码盘符**，
绿色包可搬到任意位置。

### `关闭.vbs`

`taskkill /IM tomato-novel-downloader.exe /F`，已下载的书保留在 `downloads\`。

## 常见问题

**Q：双击没反应？**
脚本是隐藏窗口运行的，属正常。弹出的提示框会告知是否成功。

**Q：提示"启动失败"？**
多半是端口被占。本目录按住 Shift 右键 →「在此处打开 PowerShell 窗口」，
手动执行 `.\tomato-novel-downloader.exe --server --data-dir data`。

**Q：端口能改吗？**
可以。改 `启动.vbs` 里的 `Const PORT = 18423` 即可。

**Q：怎么开机自启？**
`Win+R` → `shell:startup` → 把 `启动.vbs` 的快捷方式放进去。

## 编码说明

`.vbs` 文件是 **GBK（代码页 936）+ CRLF**。这是必须的：

- Windows Script Host 按 ANSI 代码页读取 `.vbs`，UTF-8 会导致中文全部乱码
- 换行符必须是 CRLF，否则 WScript 可能解析异常

## 许可

上游项目遵循其自身的开源许可。本目录不含任何个人数据，不修改上游代码，
仅附带启动/关闭脚本与说明文档。
