; === Telegram MultiTool GUI ===
; 📌 Закрепление чатов (улучшенная версия)
; 🔗 Копирование ссылок
; ⛔ Горячие клавиши остановки
; Версия: AutoHotkey v1.1

#SingleInstance Force
; === Проверка обновлений TG Helper ===
currentVersion := "1.0.0"  ; текущая версия твоей программы
updateURL := "https://raw.githubusercontent.com/TGHelper88/TG_Helper/main/version.txt"

UrlDownloadToFile, %updateURL%, local_version.txt
FileRead, latestVersion, local_version.txt

if (Trim(latestVersion) != currentVersion)
{
    MsgBox, 64, Обновление, 🚀 Доступна новая версия %latestVersion%!`nХотите открыть страницу загрузки?
    IfMsgBox, Yes
        Run, https://github.com/TGHelper88/TG_Helper/releases/latest
}

#NoEnv
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Window
CoordMode, ToolTip, Screen
global stopFlag := false

; === Главное окно ===
Gui, Font, s10, Segoe UI
Gui, Add, Text,, Выберите действие:
Gui, Add, Button, gStartPinChats w220 h30, 📌 Закрепить чаты
Gui, Add, Button, gStartCopyLinks w220 h30, 🔗 Копировать ссылки
Gui, Add, Button, g_StopScript w220 h30, ⛔ Остановить
Gui, Add, Button, gExit w220 h30, ❌ Выход
Gui, Show,, Telegram MultiTool
return


; ========================================================
; 📌 УЛУЧШЕННОЕ ЗАКРЕПЛЕНИЕ ЧАТОВ (всегда с низа списка)
; ========================================================
StartPinChats:
if !WinExist("ahk_exe Telegram.exe") {
    MsgBox, 48, Ошибка, Telegram не запущен!`nПожалуйста, открой Telegram и попробуй снова.
    return
}

WinGetPos, X, Y, W, H, ahk_exe Telegram.exe

if (W > 410 or H > 520) {
    MsgBox, 48, Важно!, 📏 Пожалуйста, уменьшите окно Telegram!`n`nРекомендуемый размер окна — примерно 410x520 пикселей.`nТекущее окно: %W%x%H%.
    return
}
    global stopFlag := false

    ; === Запрос количества чатов ===
    InputBox, cycles, Кол-во чатов, Введите количество чатов для закрепления:, , 200, 130
    if (ErrorLevel)
        return
    if (cycles = "" or cycles <= 0)
        cycles := 50  ; значение по умолчанию

    ; сколько «шагов колёсиком» делаем, чтобы гарантированно упасть в самый низ
    GoBottomSteps := 50   ; при необходимости увеличь/уменьши

    ; === Подсказка пользователю ===
    MsgBox, 64, Важно!,
    (
📌 Нажми на тг в котором нужно закрепить чаты.

Удостоверся что ты уменшил размер окна до минимума.

Чтобы запустить просто нажми на "Ок".

Дальше МЫШЬ НЕ ТРОГАЙ — я сам буду опускаться в самый низ перед каждым шагом.

Остановить: Ctrl + Q или кнопка "⛔ Остановить".
    )
    Sleep, 400

   WinActivate, ahk_exe Telegram.exe
Sleep, 700

; === Наводим курсор на нижний чат (примерно низ окна) ===
ToolTip, 🎯 Навожу курсор на нижний чат...
MouseMove, 150, 460   ; подстрой под свой размер окна Telegram
Sleep, 40
ToolTip

; === Пролистываем список до самого низа для выравнивания ===
ToolTip, ⬇️ Прокручиваю список чатов вниз...
Loop, 100   ; можно 200–300 шагов, под длину списка
{
    if (stopFlag)
        break
    Send, {WheelDown}
    Sleep, 3
}
ToolTip
Sleep, 100

    ToolTip, 📌 Закрепление %cycles% чатов...
    Sleep, 800
    ToolTip

    ; --- перед стартом опустимся в самый низ ---
    Loop, %GoBottomSteps%
    {
        if (stopFlag)
            break
        Send, {WheelDown}
        Sleep, 4
    }
    Sleep, 80

    Loop, %cycles%
    {
        if (stopFlag)
            break

 ; === Проверка, активно ли окно Telegram ===
    if !WinActive("ahk_exe Telegram.exe") {
        ToolTip, ⚠️ Telegram неактивен — скрипт приостановлен.
        while !WinActive("ahk_exe Telegram.exe") {
            Sleep, 500  ; ждём, пока Telegram снова станет активным
        }
        ToolTip, ▶️ Telegram активен — продолжаю работу.
        Sleep, 1000
        ToolTip
    }

        ; === ПКМ по чату под курсором (он должен быть нижним в списке) ===
        Click, right
        Sleep, 130

        ; === Переход к "Закрепить вверху" ===
        Send, {Down 3}     ; при необходимости подстрой 2/3/4
        Sleep, 70
        Send, {Enter}
        Sleep, 220

        ; --- снова опускаемся в самый низ, чтобы выбрать следующий незакреплённый чат ---
        Loop, %GoBottomSteps%
        {
            if (stopFlag)
                break
            Send, {WheelDown}
            Sleep, 4
        }
        Sleep, 100
    }

    if (stopFlag)
        MsgBox, 48, Остановлено, ⛔ Закрепление прервано.`nЗакреплено: %A_Index% чатов.
    else
    {
        ToolTip, ✅ Готово — закреплено %A_Index% чатов.
        Sleep, 1200
        ToolTip
    }
return


; ========================================================
; 🔗 МАССОВОЕ КОПИРОВАНИЕ ССЫЛОК (с переходом Ctrl + PageDown)
; ========================================================
StartCopyLinks:
if !WinExist("ahk_exe Telegram.exe") {
    MsgBox, 48, Ошибка, Telegram не запущен!`nПожалуйста, открой Telegram и попробуй снова.
    return
}

WinGetPos, X, Y, W, H, ahk_exe Telegram.exe

if (W > 410 or H > 520) {
    MsgBox, 48, Важно!, 📏 Пожалуйста, уменьшите окно Telegram!`n`nРекомендуемый размер окна — примерно 410x520 пикселей.`nТекущее окно: %W%x%H%.
    return
}
    global stopFlag := false

    FileSelectFolder, saveBaseDir, , 3, Выберите папку для сохранения ссылок
    if (saveBaseDir = "")
        return

    InputBox, repeats, Кол-во чатов, Сколько чатов скопировать?, , 220, 120
    if (ErrorLevel)
        return
    if (repeats = "" or repeats <= 0)
        repeats := 50

    FormatTime, nowDate, %A_Now%, yyyy-MM-dd_HH-mm
    saveDir := saveBaseDir . "\" . nowDate
    FileCreateDir, %saveDir%
    File := saveDir . "\links_" . nowDate . ".txt"

    MsgBox, 64, Важно!, 🔗 Открой первый чат с списка, с которого нужно начать копирование ссылок.`n`nПосле нажми на кнопку "Ок" и НЕ ТРОГАЙ МЫШКУ скрипт сам будет открывать чат, копировать ссылку и переходить к следующему.`n`nЧтобы остановить — нажми **Ctrl + Q**.
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


 ; === Проверка, активно ли окно Telegram ===
    if !WinActive("ahk_exe Telegram.exe") {
        ToolTip, ⚠️ Telegram неактивен — скрипт приостановлен.
        while !WinActive("ahk_exe Telegram.exe") {
            Sleep, 500  ; ждём, пока Telegram снова станет активным
        }
        ToolTip, ▶️ Telegram активен — продолжаю работу.
        Sleep, 1000
        ToolTip
    }

        ; === Открыть профиль ===
        MouseMove, 200, 50
        Sleep, 80
        Click
        Sleep, 400

        ; === Очистить буфер и клик по ссылке ===
        ClipSaved := ClipboardAll
        Clipboard := ""
        MouseMove, 100, 219
        Sleep, 60
        Click
        Sleep, 250

        ; === Ждём копирование ===
        ClipWait, 1
        link := Clipboard

        if (link = "")
            FileAppend, NO_LINK`n, %File%
        else
            FileAppend, %link%`n, %File%

        ; === Закрыть профиль ===
        Send, {Esc}
        Sleep, 200

        ; === Перейти к следующему чату ===
        Send, ^{PgDn}
        Sleep, 500
    }

    if (stopFlag)
        MsgBox, 48, Остановлено, ⛔ Копирование прервано пользователем.`nСохранено: %A_Index% ссылок.
    else
        MsgBox, 64, Готово, ✅ Ссылки сохранены в:`n%File%
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
^q:: ; Ctrl + Q — остановить текущий процесс
    global stopFlag := true
    ToolTip, ⛔ Скрипт остановлен (Ctrl+Q)
    Sleep, 1000
    ToolTip
return

^Esc:: ; Ctrl + Esc — аварийный выход
    ExitApp
return
