#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

; ╔══════════════════════════════════════════════╗
; ║        6ftFish ·  FH6 Macro           ║
; ║        Cherry Blossom Edition               ║
; ╚══════════════════════════════════════════════╝

global Toggle        := false
global DarkMode      := true
global MyGui         := ""
global StatusText    := ""
global W_UI          := ""
global X_UI          := ""
global Enter_UI      := ""
global StartDelay_In := ""
global WHold_In      := ""
global PostW_In      := ""
global LoopWait_In   := ""
global cActive       := "FF8FAB"
global cHighlight    := "39FF14"
global cIdle         := "7A4A60"
global cTextDim      := "7A4A60"
global RaceCount     := 0
global RunSeconds    := 0
global RaceCount_UI  := ""
global RunTime_UI    := ""


; ══════════════════════════════════════════════
;  PALETTE HELPER
; ══════════════════════════════════════════════
GetPalette() {
    global DarkMode
    p := Map()

    if DarkMode {
        ; ── Night Garden (Dark) ──
        p["bg"]       := "0F0810"   ; near-black plum
        p["panel"]    := "1E0F1A"   ; deep berry panel
        p["accent"]   := "FF8FAB"   ; sakura petal pink
        p["accent2"]  := "FFAEC8"   ; lighter blossom
        p["text"]     := "FFE8F0"   ; soft petal white
        p["textDim"]  := "7A5068"   ; muted mauve
        p["editBg"]   := "261220"   ; dark edit bg
        p["btnBg"]    := "1E0F1A"   ; button bg
        p["btnText"]  := "FF8FAB"   ; button fg
        p["btnBg2"]   := "180D16"   ; theme btn bg
        p["btnText2"] := "7A5068"   ; theme btn fg
        p["divider"]  := "3D1E30"   ; subtle divider
        p["cActive"]    := "FF8FAB"
        p["cHighlight"] := "39FF14"   ; neon green for active telemetry
        p["cIdle"]      := "7A5068"
        p["cTextDim"]   := "7A5068"
        p["footer"]     := "3D1E30"
    } else {
        ; ── Daylight Blossom (Light) ──
        p["bg"]       := "FEF0F4"   ; warm blossom white
        p["panel"]    := "FAE0EA"   ; soft petal bg
        p["accent"]   := "B8315A"   ; deep rose
        p["accent2"]  := "8A1A3E"   ; darker rose
        p["text"]     := "2E0F1E"   ; dark plum
        p["textDim"]  := "905070"   ; muted rose
        p["editBg"]   := "FFFFFF"   ; white
        p["btnBg"]    := "F5C8D8"   ; blush button
        p["btnText"]  := "6A1030"   ; deep crimson text
        p["btnBg2"]   := "EDB8CC"   ; softer btn
        p["btnText2"] := "8A4060"   ; muted rose text
        p["divider"]  := "E8A8BC"   ; light petal divider
        p["cActive"]    := "B8315A"
        p["cHighlight"] := "1A8C2A"   ; vivid green for active telemetry
        p["cIdle"]      := "905070"
        p["cTextDim"]   := "905070"
        p["footer"]     := "E8A8BC"
    }

    return p
}


; ══════════════════════════════════════════════
;  BUILD GUI
; ══════════════════════════════════════════════
BuildGui(savedVals := "") {
    global MyGui, StatusText, W_UI, X_UI, Enter_UI, RaceCount_UI, RunTime_UI
    global StartDelay_In, WHold_In, PostW_In, LoopWait_In
    global Toggle, DarkMode, cActive, cHighlight, cIdle, cTextDim, RaceCount, RunSeconds

    p := GetPalette()
    cActive    := p["cActive"]
    cHighlight := p["cHighlight"]
    cIdle      := p["cIdle"]
    cTextDim   := p["cTextDim"]

    cStat  := Toggle ? p["accent"] : p["textDim"]
    sLabel := Toggle ? "⬤  Running..." : "⬤  Stopped"

    MyGui := Gui("+AlwaysOnTop -MaximizeBox", "🌸 6ftFish · FH6")
    MyGui.BackColor := p["bg"]

    ; ── Blossom Crown ──────────────────────────
    MyGui.SetFont("s15", "Segoe UI Emoji")
    MyGui.Add("Text", "x0 y8 w270 Center BackgroundTrans c" p["accent"], "✿  🌸  ✿  🌸  ✿")

    MyGui.SetFont("s14 bold", "Segoe UI Light")
    MyGui.Add("Text", "x0 y+3 w270 Center BackgroundTrans c" p["accent"], "6ftFish AFK")

    MyGui.SetFont("s7 norm", "Segoe UI")
    MyGui.Add("Text", "x0 y+1 w270 Center BackgroundTrans c" p["textDim"], "FORZA HORIZON 6   ✦   AFK MACRO")

    ; ── Status ────────────────────────────────
    MyGui.SetFont("s10 bold", "Segoe UI Semibold")
    StatusText := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" cStat, sLabel)

    ; ── Race Timers ───────────────────────────
    MyGui.SetFont("s7 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+13 w242 BackgroundTrans c" p["textDim"], "RACE TIMERS  ·  SECONDS")
    MyGui.Add("Text", "x14 y+3  w242 BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    TimerRows := [
        ["🌸  Grid Wait",      savedVals ? savedVals[1] : "5" ],
        ["🌸  Throttle (W)",   savedVals ? savedVals[2] : "28"],
        ["🌸  Coast",          savedVals ? savedVals[3] : "5" ],
        ["🌸  Reset Wait",     savedVals ? savedVals[4] : "10"]
    ]

    Edits := []
    for row in TimerRows {
        MyGui.SetFont("s9 norm", "Segoe UI Light")
        MyGui.Add("Text", "x20 y+9 w155 BackgroundTrans c" p["text"], row[1])
        Ed := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], row[2])
        Edits.Push(Ed)
    }

    StartDelay_In := Edits[1]
    WHold_In      := Edits[2]
    PostW_In      := Edits[3]
    LoopWait_In   := Edits[4]

    ; ── Live Telemetry ────────────────────────
    MyGui.SetFont("s7 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+14 w242 BackgroundTrans c" p["textDim"], "LIVE TELEMETRY")
    MyGui.Add("Text", "x14 y+3  w242 BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 norm", "Segoe UI Light")
    W_UI     := MyGui.Add("Text", "x20 y+9  w236 BackgroundTrans c" p["cIdle"], "❀   W Key        —   Idle")
    X_UI     := MyGui.Add("Text", "x20 y+7  w236 BackgroundTrans c" p["cIdle"], "❀   X Key        —   Idle")
    Enter_UI := MyGui.Add("Text", "x20 y+7  w236 BackgroundTrans c" p["cIdle"], "❀   Enter Key    —   Idle")

    ; ── Session Stats ─────────────────────────
    MyGui.SetFont("s7 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+13 w242 BackgroundTrans c" p["textDim"], "SESSION STATS")
    MyGui.Add("Text", "x14 y+3  w242 BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 norm", "Segoe UI Light")
    RunTime_UI   := MyGui.Add("Text", "x20 y+9 w236 BackgroundTrans c" p["cIdle"], "⏱   Time Running     —   00:00")
    RaceCount_UI := MyGui.Add("Text", "x20 y+7 w236 BackgroundTrans c" p["cIdle"], "🏁   Races Complete   —   0")

    ; ── Buttons ───────────────────────────────
    MyGui.Add("Text", "x14 y+13 w242 BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 bold", "Segoe UI Semibold")
    BtnGo := MyGui.Add("Text",
        "x14 y+6 w242 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"],
        "🌸   START / STOP   —   press  ]")
    BtnGo.OnEvent("Click", (*) => ToggleAction())

    themeLabel := DarkMode ? "☀   Switch to Light Mode" : "🌙   Switch to Dark Mode"
    MyGui.SetFont("s8 norm", "Segoe UI")
    ThemeBtn := MyGui.Add("Text",
        "x14 y+7 w242 h26 Center 0x200 Background" p["btnBg2"] " c" p["btnText2"],
        themeLabel)
    ThemeBtn.OnEvent("Click", (*) => ToggleTheme())

    ; ── Ko-fi Tip Link ────────────────────────
    MyGui.SetFont("s8 bold", "Segoe UI Semibold")
    KofiBtn := MyGui.Add("Text",
        "x14 y+10 w242 h28 Center 0x200 BackgroundFF8C00 cFFFFFF",
        "☕   Buy me a coffee!   ko-fi.com/6ftfish")
    KofiBtn.OnEvent("Click", (*) => Run("https://ko-fi.com/6ftfish"))

    ; ── Footer Petals ─────────────────────────
    MyGui.SetFont("s9", "Segoe UI Emoji")
    MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["footer"], "✿  ·  ❀  ·  🌸  ·  ❀  ·  ✿")
    MyGui.Add("Text", "x0 y+5  w270 h1  BackgroundTrans c" p["footer"], "")

    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.Show("w270")
}


; ══════════════════════════════════════════════
;  THEME TOGGLE
; ══════════════════════════════════════════════
ToggleTheme() {
    global DarkMode, MyGui, StartDelay_In, WHold_In, PostW_In, LoopWait_In, Toggle

    ; Capture current timer values before destroy
    saved := [
        StartDelay_In.Value,
        WHold_In.Value,
        PostW_In.Value,
        LoopWait_In.Value
    ]

    ; Safely stop macro if running
    if Toggle {
        Toggle := false
        Sleep(1250)
    }

    DarkMode := !DarkMode
    MyGui.Destroy()
    BuildGui(saved)
}


; ══════════════════════════════════════════════
;  HOTKEYS
; ══════════════════════════════════════════════
$]::ToggleAction()
F12::Reload()


; ══════════════════════════════════════════════
;  TOGGLE ACTION
; ══════════════════════════════════════════════
ToggleAction() {
    global Toggle, StatusText, cActive, RaceCount, RunSeconds, RaceCount_UI, RunTime_UI
    Toggle := !Toggle

    if Toggle {
        RaceCount  := 0
        RunSeconds := 0
        RaceCount_UI.Value := "🏁   Races Complete   —   0"
        RunTime_UI.Value   := "⏱   Time Running     —   00:00"
        StatusText.Value := "⬤  Running..."
        StatusText.SetFont("c" cActive)
        SetTimer(TimerTick, 1000)
        RunLoop()
    } else {
        SetTimer(TimerTick, 0)
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }
}


; ══════════════════════════════════════════════
;  MAIN LOOP
; ══════════════════════════════════════════════
RunLoop() {
    global Toggle, StartDelay_In, WHold_In, PostW_In, LoopWait_In
    global W_UI, X_UI, Enter_UI, cActive, cHighlight, cIdle
    global RaceCount, RaceCount_UI

    StartWait     := StartDelay_In.Value != "" ? Integer(StartDelay_In.Value) : 0
    DriveTime     := WHold_In.Value      != "" ? Integer(WHold_In.Value)      : 0
    PostDriveWait := PostW_In.Value      != "" ? Integer(PostW_In.Value)      : 0
    ResetWait     := LoopWait_In.Value   != "" ? Integer(LoopWait_In.Value)   : 0

    While Toggle {

        ; ── Initial buffer ──────────────────
        Sleep(2000)
        if (!Toggle) {
            break
        }

        ; ── Enter: start race ───────────────
        Enter_UI.Value := "❀   Enter Key    —   [ PRESSED ]"
        Enter_UI.SetFont("c" cHighlight)
        Send("{Enter down}")
        Sleep(50)
        Send("{Enter up}")
        Sleep(300)
        Enter_UI.Value := "❀   Enter Key    —   Idle"
        Enter_UI.SetFont("c" cIdle)

        if (!Toggle) {
            break
        }

        ; ── 1. Grid wait ────────────────────
        W_UI.SetFont("c" cHighlight)
        if (!SmartCountdown(StartWait, W_UI, "❀   W Key        —   On grid...")) {
            break
        }
        W_UI.SetFont("c" cIdle)

        ; ── 2. Full throttle ────────────────
        W_UI.SetFont("c" cHighlight)
        Send("{w down}")

        if (!SmartCountdown(DriveTime, W_UI, "❀   W Key        —   [ THROTTLE ]")) {
            Send("{w up}")
            break
        }

        Send("{w up}")
        W_UI.Value := "❀   W Key        —   Idle"
        W_UI.SetFont("c" cIdle)

        if (!Toggle) {
            break
        }

        ; ── 3. Coast ────────────────────────
        W_UI.SetFont("c" cHighlight)
        if (!SmartCountdown(PostDriveWait, W_UI, "❀   W Key        —   Coasting...")) {
            break
        }

        W_UI.Value := "❀   W Key        —   Idle"
        W_UI.SetFont("c" cIdle)

        if (!Toggle) {
            break
        }

        ; ── 4. X key (retry/skip) ───────────
        X_UI.Value := "❀   X Key        —   [ PRESSED ]"
        X_UI.SetFont("c" cHighlight)
        Send("{x down}")
        Sleep(50)
        Send("{x up}")
        Sleep(300)
        X_UI.Value := "❀   X Key        —   Idle"
        X_UI.SetFont("c" cIdle)

        if (!Toggle) {
            break
        }

        ; ── 5. Enter (confirm/restart) ──────
        Enter_UI.Value := "❀   Enter Key    —   [ PRESSED ]"
        Enter_UI.SetFont("c" cHighlight)
        Send("{Enter down}")
        Sleep(50)
        Send("{Enter up}")
        Sleep(300)
        Enter_UI.Value := "❀   Enter Key    —   Idle"
        Enter_UI.SetFont("c" cIdle)

        if (!Toggle) {
            break
        }

        ; ── 6. Loop cooldown ────────────────
        Enter_UI.SetFont("c" cHighlight)
        if (!SmartCountdown(ResetWait, Enter_UI, "❀   Enter Key    —   Looping...")) {
            break
        }

        Enter_UI.Value := "❀   Enter Key    —   Idle"
        Enter_UI.SetFont("c" cIdle)

        ; ── Increment race counter ───────────
        RaceCount++
        try {
            RaceCount_UI.Value := "🏁   Races Complete   —   " RaceCount
        }
    }

    ResetIndicators()
}


; ══════════════════════════════════════════════
;  COUNTDOWN ENGINE
; ══════════════════════════════════════════════
SmartCountdown(TotalSec, UIEl, ActiveText) {
    global Toggle
    Loop TotalSec {
        if (!Toggle)
            return false
        UIEl.Value := ActiveText " (" (TotalSec - A_Index + 1) "s)"
        Sleep(1000)
    }
    return true
}


; ══════════════════════════════════════════════
;  RESET
; ══════════════════════════════════════════════
ResetIndicators() {
    global W_UI, X_UI, Enter_UI, StatusText, cIdle, cTextDim
    global RaceCount_UI, RunTime_UI, RunSeconds, RaceCount
    SetTimer(TimerTick, 0)
    Send("{w up}")
    try {
        W_UI.Value := "❀   W Key        —   Idle"
        W_UI.SetFont("c" cIdle)
        X_UI.Value := "❀   X Key        —   Idle"
        X_UI.SetFont("c" cIdle)
        Enter_UI.Value := "❀   Enter Key    —   Idle"
        Enter_UI.SetFont("c" cIdle)
        RaceCount_UI.Value := "🏁   Races Complete   —   " RaceCount
        RunTime_UI.SetFont("c" cIdle)
        RaceCount_UI.SetFont("c" cIdle)
        StatusText.Value := "⬤  Stopped"
        StatusText.SetFont("c" cTextDim)
    }
}


; ══════════════════════════════════════════════
;  TIMER TICK  (fires every second while running)
; ══════════════════════════════════════════════
TimerTick() {
    global RunSeconds, RunTime_UI, cHighlight
    RunSeconds++
    mins := RunSeconds // 60
    secs := Mod(RunSeconds, 60)
    try {
        RunTime_UI.Value := "⏱   Time Running     —   " Format("{:02d}:{:02d}", mins, secs)
        RunTime_UI.SetFont("c" cHighlight)
    }
}


; ══════════════════════════════════════════════
BuildGui()
