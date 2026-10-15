' ============================================================
'  番茄小说下载器  Windows 绿色版 —— 启动脚本
'  双击运行：后台静默启动，不会自动打开浏览器
'  启动成功后请手动访问 http://127.0.0.1:18423/
'  本包不设访问密码，打开网页即可直接使用
' ============================================================
Option Explicit

Const PORT = 18423
Const URL = "http://127.0.0.1:18423/"

Dim sh, http, fso, base, exe, running, i, processEnv
Set sh = CreateObject("WScript.Shell")
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
Set fso = CreateObject("Scripting.FileSystemObject")

base = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
exe = base & "tomato-novel-downloader.exe"

running = False
On Error Resume Next
http.Option(6) = False
http.Open "GET", URL, False
http.Send
If Err.Number = 0 Then
  If http.Status = 200 Then running = True
  Err.Clear
End If
On Error GoTo 0

If running Then
  sh.Popup "番茄小说下载器已在运行。" & vbCrLf & vbCrLf & _
            "请直接用浏览器访问：" & vbCrLf & URL, _
            3, "番茄小说下载器", 64
  WScript.Quit 0
End If

sh.CurrentDirectory = base
Set processEnv = sh.Environment("PROCESS")
processEnv("TOMATO_WEB_ADDR") = "127.0.0.1:" & PORT
sh.Run """" & exe & """ --server --data-dir data", 0, False

For i = 1 To 40
  WScript.Sleep 500
  running = False
  On Error Resume Next
  http.Open "GET", URL, False
  http.Send
  If Err.Number = 0 Then
    If http.Status = 200 Then running = True
    Err.Clear
  End If
  On Error GoTo 0
  If running Then Exit For
Next

If running Then
  sh.Popup "启动成功（后台静默运行，未打开浏览器）。" & vbCrLf & vbCrLf & _
            "网页地址： " & URL & vbCrLf & _
            "无账号、无密码，打开即用。" & vbCrLf & vbCrLf & _
            "下载的书保存在本目录 downloads\ 文件夹。", _
            8, "番茄小说下载器", 64
Else
  sh.Popup "启动失败：tomato-novel-downloader.exe 未能在 20 秒内就绪。" & vbCrLf & vbCrLf & _
            "排查方法：在本目录按住 Shift 右键 →" & vbCrLf & _
            "「在此处打开 PowerShell 窗口」，手动执行：" & vbCrLf & vbCrLf & _
            "    .\tomato-novel-downloader.exe --server --data-dir data" & vbCrLf & vbCrLf & _
            "查看屏幕上的报错信息。", 10, "番茄小说下载器 - 启动失败", 16
End If
