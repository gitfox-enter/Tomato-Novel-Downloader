' ============================================================
'  番茄小说下载器  Windows 绿色版 —— 关闭脚本
' ============================================================
Option Explicit

Dim sh
Set sh = CreateObject("WScript.Shell")

sh.Run "cmd /c taskkill /IM tomato-novel-downloader.exe /F >nul 2>&1", 0, True
WScript.Sleep 500

sh.Popup "番茄小说下载器已关闭。" & vbCrLf & vbCrLf & _
          "已下载的书保留在 downloads\ 文件夹中。" & vbCrLf & _
          "配置与日志保存在 data\ 文件夹中。", _
          3, "番茄小说下载器", 64
