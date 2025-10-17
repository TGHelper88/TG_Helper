; === Telegram MultiTool GUI ===
; 📌 Закрепление чатов (улучшенная версия)
; 🔗 Копирование ссылок
; ⛔ Горячие клавиши остановки
; Версия: AutoHotkey v1.1

#SingleInstance Force
; === Проверка обновлений TG Helper (с автообновлением) ===

iniFile := A_ScriptDir . "\config.ini"
if !FileExist(iniFile)
    FileAppend, currentVersion=1.2.62`n, %iniFile%

IniRead, currentVersion, %iniFile%, General, currentVersion, 1.1.36

updateURL := "https://raw.githubusercontent.com/TGHelper88/TG_Helper/main/version.txt"
exeURL := "https://github.com/TGHelper88/TG_Helper/raw/main/TG_Helper.exe"
newExe := A_ScriptDir . "\TG_Helper_new.exe"
batFile := A_ScriptDir . "\update_run.bat"

; --- Скачиваем номер версии ---
UrlDownloadToFile, %updateURL%, local_version.txt
FileRead, latestVersion, local_version.txt
latestVersion := Trim(latestVersion)

if (latestVersion = "")
{
    MsgBox, 48, Ошибка, ⚠️ Не удалось получить информацию об обновлении.
}
else if (latestVersion != currentVersion)
{
    MsgBox, 4, Обновление, 🚀 Доступна новая версия %latestVersion%!`n`nСкачать и установить сейчас?
    IfMsgBox, Yes
    {
        ToolTip, ⏬ Загрузка новой версии...
        UrlDownloadToFile, %exeURL%, %newExe%
        ToolTip

        if (FileExist(newExe))
        {
            ; === Создаём update_run.bat безопасно ===
batTxt := ""
batTxt .= "@echo off`r`n"
batTxt .= "cd /d ""%~dp0""`r`n"
batTxt .= "echo Обновление TG_Helper...`r`n"
batTxt .= "ping 127.0.0.1 -n 3 >nul`r`n"
batTxt .= "taskkill /im ""TG_Helper.exe"" /f >nul 2>&1`r`n"
batTxt .= "timeout /t 2 >nul`r`n"
batTxt .= "del /f /q ""TG_Helper.exe""`r`n"
batTxt .= "rename ""TG_Helper_new.exe"" ""TG_Helper.exe""`r`n"
batTxt .= "start """" ""TG_Helper.exe""`r`n"
batTxt .= "timeout /t 3 >nul`r`n"
batTxt .= "del ""%%~f0""`r`n"
batTxt .= "exit`r`n"

f := FileOpen(batFile, "w")
f.Write(batTxt)
f.Close()


            ; === Обновляем версию в config.ini ===
            IniWrite, %latestVersion%, %iniFile%, General, currentVersion

            MsgBox, 64, Обновление, ✅ Обновление загружено!`nСейчас программа перезапустится.
            Run, %batFile%, , Hide
            ExitApp
        }
        else
        {
            MsgBox, 48, Ошибка, ❌ Не удалось скачать обновление.
        }
    }
}
else
{
    ToolTip, ✅ Установлена последняя версия (%currentVersion%)
    Sleep, 1500
    ToolTip
}




#SingleInstance Force
#NoEnv
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Window
CoordMode, ToolTip, Screen
global stopFlag := false
global mainGuiTitle := "Telegram MultiTool"

; === Главное окно ===
Gui, Font, s10, Segoe UI
Gui, Add, Text,, Выберите действие:
Gui, Add, Button, gStartPinChats w220 h30, 📌 Закрепить чаты
Gui, Add, Button, gStartCopyLinks w220 h30, 🔗 Копировать ссылки
Gui, Add, Button, g_StopScript w220 h30, ⛔ Остановить
Gui, Add, Button, gExit w220 h30, ❌ Выход
Gui, +AlwaysOnTop +OwnDialogs
Gui, Show,, %mainGuiTitle%
return


; ========================================================
; 🧩 Вспомогательные функции
; ========================================================
ToggleTop(state := "on") {
    global mainGuiTitle
    if (state = "off")
        WinSet, AlwaysOnTop, Off, %mainGuiTitle%
    else
        WinSet, AlwaysOnTop, On, %mainGuiTitle%
}


; ========================================================
; 📌 УЛУЧШЕННОЕ ЗАКРЕПЛЕНИЕ ЧАТОВ
; ========================================================
StartPinChats:
if !WinExist("ahk_exe Telegram.exe") {
    ToggleTop("off")
    MsgBox, 48, Ошибка, Telegram не запущен!`nПожалуйста, открой Telegram и попробуй снова.
    ToggleTop("on")
    return
}

WinGetPos, X, Y, W, H, ahk_exe Telegram.exe

if (W > 410 or H > 520) {
    ToggleTop("off")
    MsgBox, 48, Важно!, 📏 Пожалуйста, уменьшите окно Telegram!`n`nРекомендуемый размер окна — примерно 410x520 пикселей.`nТекущее окно: %W%x%H%.
    ToggleTop("on")
    return
}

global stopFlag := false

; === Запрашиваем общее количество чатов ===
ToggleTop("off")
InputBox, totalChats, Всего чатов, Введите общее количество чатов в папке:, , 220, 130
ToggleTop("on")
if (ErrorLevel)
    return
if (totalChats = "" or totalChats <= 0)
    totalChats := 100

; === Запрашиваем, сколько закрепить ===
ToggleTop("off")
InputBox, cycles, Кол-во чатов, Введите количество чатов для закрепления:, , 220, 130
ToggleTop("on")
if (ErrorLevel)
    return
if (cycles = "" or cycles <= 0)
    cycles := 50

; === Расчёт скорости ===
GoBottomSteps := Ceil(totalChats * 0.2)
if (GoBottomSteps < 5)
    GoBottomSteps := 5
if (GoBottomSteps > 35)
    GoBottomSteps := 35

; === Подсказка пользователю ===
ToggleTop("off")
MsgBox, 64, Важно!,
(
📌 Нажми на Telegram, где нужно закрепить чаты.

Убедись, что окно уменьшено до минимума.

Чтобы запустить — просто нажми "Ок".
Мышь не трогай — я сам всё сделаю.

Остановить: Ctrl + Q или кнопка "⛔ Остановить".

Всего чатов: %totalChats%
Закрепляем: %cycles%
Скорость опускания: %GoBottomSteps% шагов
)
ToggleTop("on")
Sleep, 400

WinActivate, ahk_exe Telegram.exe
Sleep, 700

; === Наводим курсор на нижний чат ===
ToolTip, 🎯 Навожу курсор на нижний чат...
MouseMove, 150, 460
Sleep, 40
ToolTip

; === Быстро пролистываем вниз ===
ToolTip, ⬇️ Быстро опускаюсь в самый низ...
Loop, %GoBottomSteps%
{
    if (stopFlag)
        break
    Send, {WheelDown 5}
    Sleep, 10
}
ToolTip
Sleep, 80

ToolTip, 📌 Закрепление %cycles% чатов...
Sleep, 800
ToolTip

; --- перед стартом опустимся в самый низ ---
Loop, %GoBottomSteps%
{
    if (stopFlag)
        break
    Send, {WheelDown 5}
    Sleep, 10
}
Sleep, 500

; === Счётчик закреплённых чатов ===
pinnedCount := 0

Loop, %cycles%
{
    if (stopFlag)
        break

    ; === Проверка, активно ли окно Telegram ===
    if !WinActive("ahk_exe Telegram.exe") {
        ToolTip, ⚠️ Telegram неактивен — скрипт приостановлен.
        while !WinActive("ahk_exe Telegram.exe") {
            Sleep, 500
        }
        ToolTip, ▶️ Telegram активен — продолжаю работу.
        Sleep, 1000
        ToolTip
    }

    ; === ПКМ по нижнему чату ===
    Click, right
    Sleep, 130

    ; === Переход к "Закрепить вверху" ===
    Send, {Down 3}
    Sleep, 70
    Send, {Enter}
    Sleep, 220

    pinnedCount++

    ; --- снова вниз ---
    Loop, %GoBottomSteps%
    {
        if (stopFlag)
            break
        Send, {WheelDown 5}
        Sleep, 10
    }
    Sleep, 400
}

; ---------- Завершение ----------
ToggleTop("off")
if (stopFlag)
    MsgBox, 48, Остановлено, ⛔ Закрепление прервано.`nЗакреплено: %pinnedCount% чатов.
else
    MsgBox, 64, Готово!, ✅ Работа завершена.`nЗакреплено: %pinnedCount% чатов.
ToggleTop("on")
return


; ========================================================
; 🔗 КОПИРОВАНИЕ ССЫЛОК
; ========================================================
StartCopyLinks:
if !WinExist("ahk_exe Telegram.exe") {
    ToggleTop("off")
    MsgBox, 48, Ошибка, Telegram не запущен!`nПожалуйста, открой Telegram и попробуй снова.
    ToggleTop("on")
    return
}

WinGetPos, X, Y, W, H, ahk_exe Telegram.exe

if (W > 410 or H > 520) {
    ToggleTop("off")
    MsgBox, 48, Важно!, 📏 Пожалуйста, уменьшите окно Telegram!`n`nРекомендуемый размер — 410x520.`nТекущее: %W%x%H%.
    ToggleTop("on")
    return
}
global stopFlag := false

ToggleTop("off")
FileSelectFolder, saveBaseDir, , 3, Выберите папку для сохранения ссылок
ToggleTop("on")
if (saveBaseDir = "")
    return

ToggleTop("off")
InputBox, repeats, Кол-во чатов, Сколько чатов скопировать?, , 220, 120
ToggleTop("on")
if (ErrorLevel)
    return
if (repeats = "" or repeats <= 0)
    repeats := 50

FormatTime, nowDate, %A_Now%, yyyy-MM-dd_HH-mm
saveDir := saveBaseDir . "\" . nowDate
FileCreateDir, %saveDir%
File := saveDir . "\links_" . nowDate . ".txt"

ToggleTop("off")
MsgBox, 64, Важно!, 🔗 Открой первый чат для копирования ссылок.`n`nПосле "Ок" — не трогай мышку. Чтобы остановить — Ctrl + Q.
ToggleTop("on")
Sleep, 600

WinActivate, ahk_exe Telegram.exe
Sleep, 600

ToolTip, 📁 Сохраняю ссылки в:`n%File%
Sleep, 1000
ToolTip

Loop, %repeats%
{
    if (stopFlag)
        break

    if !WinActive("ahk_exe Telegram.exe") {
        ToolTip, ⚠️ Telegram неактивен — пауза.
        while !WinActive("ahk_exe Telegram.exe") {
            Sleep, 500
        }
        ToolTip, ▶️ Telegram активен.
        Sleep, 1000
        ToolTip
    }

    MouseMove, 200, 50
    Sleep, 80
    Click
    Sleep, 400

    ClipSaved := ClipboardAll
    Clipboard := ""
    MouseMove, 100, 219
    Sleep, 60
    Click
    Sleep, 250

    ClipWait, 1
    link := Clipboard

    if (link = "")
        FileAppend, NO_LINK`n, %File%
    else
        FileAppend, %link%`n, %File%

    Send, {Esc}
    Sleep, 200
    Send, ^{PgDn}
    Sleep, 500
}

ToggleTop("off")
if (stopFlag)
    MsgBox, 48, Остановлено, ⛔ Копирование прервано.`nСохранено: %A_Index% ссылок.
else
    MsgBox, 64, Готово!, ✅ Ссылки сохранены в:`n%File%
ToggleTop("on")
return


; ========================================================
; ⛔ ОСТАНОВКА
; ========================================================
_StopScript:
global stopFlag := true
ToolTip, ⛔ Скрипт остановлен
Sleep, 1000
ToolTip
return


; ========================================================
; ❌ ВЫХОД
; ========================================================
Exit:
GuiClose:
ExitApp
return


; ========================================================
; 🔥 ГОРЯЧИЕ КЛАВИШИ
; ========================================================
^q:: 
global stopFlag := true
ToolTip, ⛔ Скрипт остановлен (Ctrl+Q)
Sleep, 1000
ToolTip
return

^Esc:: 
ExitApp
return
