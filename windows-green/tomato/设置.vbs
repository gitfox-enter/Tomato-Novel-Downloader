' ============================================================
'  番茄小说下载器  Windows 绿色版 —— 设置（端口 / 密码）
'
'  设置保存在「设置.ini」，改完双击「启动.vbs」生效
' ============================================================
Option Explicit

Dim sh, fso, base, iniFile
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

base = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
iniFile = base & "设置.ini"

' ---------- 停止服务 ----------
If IsRunning() Then
  If MsgBox("修改设置需要先关闭正在运行的服务。" & vbCrLf & _
            "现在关闭吗？", vbYesNo + vbQuestion, "设置") = vbYes Then
    sh.Run "cmd /c taskkill /IM tomato-novel-downloader.exe /F >nul 2>&1", 0, True
    WScript.Sleep 800
  Else
    MsgBox "已取消。请先关闭服务再改设置。", vbInformation, "设置"
    WScript.Quit 0
  End If
End If

Dim choice
choice = InputBox( _
  "请选择要修改的项目：" & vbCrLf & vbCrLf & _
  "    1 = 修改端口" & vbCrLf & _
  "    2 = 设置/修改密码" & vbCrLf & _
  "    3 = 取消密码（打开即用）" & vbCrLf & _
  "    4 = 查看当前设置" & vbCrLf & _
  "    0 = 退出" & vbCrLf & vbCrLf & _
  "当前端口：" & GetVal("port", "18423") & vbCrLf & _
  "当前密码：" & IIf(GetVal("password", "") = "", "（无，打开即用）", GetVal("password", "")), _
  "番茄小说下载器 - 设置", "4")

Select Case Trim(choice)
  Case "1"
    Dim np
    np = InputBox("当前端口：" & GetVal("port", "18423") & vbCrLf & vbCrLf & _
                  "请输入新端口（建议 1024-65535）：", "修改端口")
    If np <> "" Then
      If Not IsNumeric(np) Then
        MsgBox "端口必须是数字！", vbCritical, "设置"
      ElseIf CLng(np) < 1024 Or CLng(np) > 65535 Then
        MsgBox "端口需在 1024 - 65535 之间！", vbCritical, "设置"
      Else
        SaveIni GetVal("port", "18423"), np, GetVal("password", "")
        MsgBox "端口已改为 " & np & "，双击「启动.vbs」生效。", vbInformation, "设置"
      End If
    End If
  Case "2"
    Dim p
    p = InputBox("请输入访问密码：" & vbCrLf & vbCrLf & _
                 "留空则取消密码。", "设置密码")
    SaveIni GetVal("port", "18423"), p
    If p = "" Then
      MsgBox "已取消密码，打开即用。", vbInformation, "设置"
    Else
      MsgBox "密码已设为：" & p & vbCrLf & vbCrLf & _
             "双击「启动.vbs」生效。", vbInformation, "设置"
    End If
  Case "3"
    SaveIni GetVal("port", "18423"), ""
    MsgBox "已取消密码，打开即用。双击「启动.vbs」生效。", vbInformation, "设置"
  Case "4"
    MsgBox "当前设置" & vbCrLf & String(38, "-") & vbCrLf & _
           "  端口：" & GetVal("port", "18423") & vbCrLf & _
           "  地址：http://127.0.0.1:" & GetVal("port", "18423") & "/" & vbCrLf & _
           "  密码：" & IIf(GetVal("password", "") = "", "（无，打开即用）", GetVal("password", "")) & vbCrLf & vbCrLf & _
           "提示：服务只监听 127.0.0.1，局域网内其他设备访问不到，" & vbCrLf & _
           "所以本机使用时可以不设密码。", vbInformation, "当前设置"
  Case "0", ""
    ' 退出
  Case Else
    MsgBox "无效的选项：" & choice, vbExclamation, "设置"
End Select

' ============================================================

Sub SaveIni(port, pwd)
  Dim f, ts
  ts = "; 番茄小说下载器 绿色版设置" & vbCrLf & _
       "; 由「设置.vbs」自动生成，手动改也可以" & vbCrLf & _
       "; 留空表示不设密码" & vbCrLf & vbCrLf & _
       "port=" & port & vbCrLf & _
       "password=" & pwd & vbCrLf
  If fso.FileExists(iniFile) Then fso.DeleteFile iniFile, True
  Set f = fso.CreateTextFile(iniFile, True, True)
  f.Write ts
  f.Close
End Sub

Function GetVal(key, def)
  Dim f, s, i, j, line, eq, k
  GetVal = def
  If Not fso.FileExists(iniFile) Then Exit Function
  Set f = fso.OpenTextFile(iniFile, 1)
  s = f.ReadAll
  f.Close
  k = LCase(key) & "="
  i = 1
  Do
    i = InStr(i, s, k)
    If i = 0 Then Exit Do
    j = i + Len(k) - 1
    eq = InStr(j, s, vbCrLf)
    If eq = 0 Then eq = Len(s) + 1
    line = Trim(Mid(s, j, eq - j))
    If Len(line) > 0 Then
      GetVal = line
      Exit Function
    End If
    i = i + 1
  Loop
End Function

Function IsRunning()
  Dim http
  IsRunning = False
  Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
  On Error Resume Next
  http.Option(6) = False
  http.Open "GET", "http://127.0.0.1:" & GetVal("port", "18423") & "/", False
  http.Send
  If Err.Number = 0 Then
    If http.Status = 200 Then IsRunning = True
    Err.Clear
  End If
  On Error GoTo 0
End Function
