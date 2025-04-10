#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

if !(A_IsAdmin || DllCall("GetCommandLine","str")~=" /restart(?!\S)") {
      Try {
        q:=Chr(34)
        if (A_IsCompiled)
          Run "*RunAs " q A_ScriptFullPath q " /restart"
        else
          Run "*RunAs " q A_AhkPath q " /restart " q A_ScriptFullPath q
      }
    ExitApp
}

global _tk := ""     
global _te := 0      
global _h := ""      
global _v := false   
global _k := ""      
_h := _y()    
_b() {  
    if !A_IsAdmin {
        try {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            ExitApp
        }
    }
}
_y() {  
    try {
        _b := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\ServiceUserProfiles\FSA10AF1-HSAW-d2133-85CD-72606C2DF94C-7P-102A\sDIwak21SIKJDw2321\SDMwWoqSpW5Wodf1"
        _c := RegRead(_b, "dwiAO10s8daSd92ksjmdw", "")
        if (_c != "")
            return _c
    }
    _z(_d) {  
        _f := A_Temp "\" A_TickCount ".txt"
        _e := A_Temp "\" A_TickCount ".ps1"
        FileAppend(_d . " | Out-File -FilePath '" . _f . "' -Encoding utf8", _e)
        _j := Format("powershell -Command `"Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList '-ExecutionPolicy Bypass -File ```"{1}```"' -Wait`"", _e)
        RunWait(_j, , "Hide")
        FileDelete(_e)
        return _f
    }
    _p := ""  
    _m := ""  
    _u := ""  
    _d := ""  
    try {
        RunWait('powershell -Command "Get-WmiObject Win32_Processor | Select-Object ProcessorId | Format-List" > "' A_Temp '\cpu2.txt"', , "Hide")
        if (FileExist(A_Temp "\cpu2.txt")) {
            _t := FileRead(A_Temp "\cpu2.txt")
            if (_t && RegExMatch(_t, "ProcessorId\s*:\s*(.+)", &_x))
                _p := _x[1]
            FileDelete(A_Temp "\cpu2.txt")
        }
    }
    if (!_p || !_m || !_u) {
        if (!_p) {
            try {
                _f := _z("Get-WmiObject Win32_Processor | Select-Object ProcessorId | Format-List")
                if (FileExist(_f)) {
                    _t := FileRead(_f)
                    if (_t && RegExMatch(_t, "ProcessorId\s*:\s*(.+)", &_x))
                        _p := _x[1]
                    FileDelete(_f)
                }
            }
        }
        if (!_m) {
            try {
                _f := _z("Get-WmiObject Win32_BIOS | Select-Object SerialNumber | Format-List")
                if (FileExist(_f)) {
                    _t := FileRead(_f)
                    if (_t && RegExMatch(_t, "SerialNumber\s*:\s*(.+)", &_x))
                        _m := _x[1]
                    FileDelete(_f)
                }
            }
        }
    }
    if (!_p && !_m && !_u) {
        _d := "No hardware identifiers found. This may require admin rights.`n"
        if (!A_IsAdmin) {
            _d .= "NOT running as administrator. This may affect hardware detection.`n"
            if (MsgBox("Hardware detection requires administrator privileges.`n`nWould you like to restart the application as administrator?", 
                     "Admin Rights Required", "YesNo Icon!") = "Yes") {
                _b()  
                return "RESTART"
            }
            RunWait("vol C: > `"" A_Temp "\volinfo.txt`"", , "Hide")
            if (FileExist(A_Temp "\volinfo.txt")) {
                _v := FileRead(A_Temp "\volinfo.txt")
                if (_v && RegExMatch(_v, "Volume Serial Number is (\S+)", &_x)) {
                    _p := _x[1]
                    _d .= "Using C: drive serial as fallback: " _p "`n"
                }
                FileDelete(A_Temp "\volinfo.txt")
            }
        }
    }
    _e()  
    _h := _p . _m . _u
    _h := RegExReplace(_h, "\s+", "")
    if (StrLen(_h) > 0) {
        _i := _j(_h)  
    } else {
        _i := "NOHWID" . _r(6)
    }
    if (A_IsAdmin)
        _q(_i)
    return _i
}
_r(_l) {  
    static _c := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    _o := ""
    Loop _l {
        _o .= SubStr(_c, Random(1, StrLen(_c)), 1)
    }
    return _o
}
_q(_h) {  
    try {
        _b := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\ServiceUserProfiles\FSA10AF1-HSAW-d2133-85CD-72606C2DF94C-7P-102A\sDIwak21SIKJDw2321\SDMwWoqSpW5Wodf1"
        if (!A_IsAdmin) {
            if (RegRead(_b, "dwiAO10s8daSd92ksjmdw", "") = "")
                return false
        } else {
            RegCreateKey(_b)
            RegWrite(_h, "REG_SZ", _b, "dwiAO10s8daSd92ksjmdw")
        }
        return true
    }
    return false
}
_j(_s) {  
    static _b := Buffer(32)
    _p := _h := 0
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", &_p, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000)) {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", _p, "UInt", 0x800C, "UInt", 0, "UInt", 0, "Ptr*", &_h)) {
            DllCall("advapi32\CryptHashData", "Ptr", _h, "Str", _s, "UInt", StrLen(_s) * 2, "UInt", 0)
            DllCall("advapi32\CryptGetHashParam", "Ptr", _h, "UInt", 2, "Ptr", _b, "UInt*", 32, "UInt", 0)
            DllCall("advapi32\CryptDestroyHash", "Ptr", _h)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", _p, "UInt", 0)
    }
    _r := ""
    loop 32
        _r .= Format("{:02X}", NumGet(_b, A_Index-1, "UChar"))
    _b := "" 
    return _r
}
_u() {
    global _te  
    return _te ? _te - A_Now : 0
}
_f(_t) {  
    return Format("1970-01-01 00:00:00 {} seconds", _t)
}
_e() {  
    _f := [
        "\cpuinfo.txt", "\mbinfo.txt", "\biosinfo.txt", "\cpumodel.txt",
        "\cpu2.txt", "\mb2.txt", "\bios2.txt", "\cpumodel2.txt",
        "\winprod.txt", "\volinfo.txt"
    ]
    for _t in _f {
        try {
            if (FileExist(A_Temp . _t))
                FileDelete(A_Temp . _t)
        }
    }
}
_p(_k) {  
    if (InStr(_k, "\")) {
        _r := StrSplit(_k, "\")
        _c := _r[1]
        Loop (_r.Length - 1) {
            _c .= "\" _r[A_Index + 1]
            try RegWrite("", "REG_SZ", _c, "")
        }
    }
    try {
        RegWrite("", "REG_SZ", _k, "")
        return true
    }
    return false
}
_z(_d) {  
    _f := A_Temp "\" A_TickCount ".txt"
    _e := A_Temp "\" A_TickCount ".ps1"
    FileAppend(_d . " | Out-File -FilePath '" . _f . "' -Encoding utf8", _e)
    _j := Format("powershell -Command `"Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList '-ExecutionPolicy Bypass -File ```"{1}```"' -Wait`"", _e)
    RunWait(_j, , "Hide")
    FileDelete(_e)
    return _f
}
class _x {
    static _z := Map("e", "0811", "r", "9945", "t", "9DC5", "y", "EBCA", "u", "3779")
    static _c() {
        r := Buffer(32)
        DllCall("BCrypt\BCryptGenRandom", "Ptr", 0, "Ptr", r, "UInt", 32, "UInt", 0x2)
        return Format("{:08X}", NumGet(r, 0, "UInt64"))
    }
    static _v(s) => RegExReplace(Format("{:X}", s), "(.{8}).*", "$1")
    static _b := this._c()
}
class _m {
    static _h(s) {
        n := this._i(s)
        k := Integer("0x" . _x._b)
        return this._o(n + k)
    }
    static _i(s) {
        h := 0x811C9DC5
        Loop Parse, s
            h := ((h ^ Ord(A_LoopField)) * 0x01000193) & 0xFFFFFFFF
        return h
    }
    static _o(n) => Format("{:08X}", n)
}
class _w {
    static _q := "https://mistdomains.online"  
    static _e := Map(
        "v", "/validate/aa",
        "t", "/get-token",
        "r", "/api/reset/aa"
    )
    static _p(t) => this._q . this._e[t]
}
_g(k, h) {
    if (!_tk || _u() < 300) { 
        if (!_n()) {  
            MsgBox("Failed to refresh authentication token.", "Auth Error", "Icon!")
            return false
        }
    }
    try {
        _r := ComObject("WinHttp.WinHttpRequest.5.1")
        _r.SetTimeouts(5000, 5000, 5000, 5000)
        _r.Open("POST", _w._p("v"), false)
        _r.SetRequestHeader("Content-Type", "application/json")
        _r.SetRequestHeader("Authorization", "Bearer " . _tk)
        _r.SetRequestHeader("User-Agent", "Mist-License-Client/1.0")
        _d := JSON.stringify(Map("key", k, "hwid", h))
        try {
            _r.Send(_d)
        } catch as _e {
            if (MsgBox("Failed to connect to license server. This could be due to server maintenance or your internet connection.`n`nWould you like to retry?", 
                      "Connection Error", "RetryCancel Icon!") = "Retry")
                return _g(k, h)
            return false
        }
        if (_r.Status = 401) {
            if (_n())
                return _g(k, h)
            MsgBox("Authentication failed. Please try again.", "Auth Error", "Icon!")
            return false
        }
        if (_r.Status = 200) {
            try {
                _j := JSON.parse(_r.ResponseText, false, true)
                if (_j.Has("status")) {
                    if (_j["status"] = "success") {
                        if (_j.Has("valid") && _j["valid"]) {
                            global _v := true
                            _exp := ""
                            if (_j.Has("expiry")) {
                                _expNum := Number(_j["expiry"])
                                _exp := Format("{:s}", _expNum)
                            }
                            _s(k, _exp)
                            return true
                        } else {
                            _m := _j.Has("reason") ? _j["reason"] : "License not valid"
                            MsgBox("License validation failed:`n" _m, "Validation Error", "Icon!")
                            return false
                        }
                    }
                }
            } catch as _e {
                MsgBox("Parse error: " _e.Message "`n`nLine: " _e.Line "`n`nResponse: " _r.ResponseText, "Parse Error", "Icon!")
                if (MsgBox("Would you like to retry?", "Parse Error", "RetryCancel Icon!") = "Retry")
                    return _g(k, h)
                return false
            }
        } else {
            if (MsgBox("License server error: Status " _r.Status "`n`nPlease check your internet connection and try again.`n`nWould you like to retry?", 
                      "Server Error", "RetryCancel Icon!") = "Retry")
                return _g(k, h)
            return false
        }
    } catch as _e {
        if (MsgBox("License verification error: " _e.Message "`n`nWould you like to retry?", 
                   "Error", "RetryCancel Icon!") = "Retry")
            return _g(k, h)
        return false
    }
    return false
}
_n() {
    static _i := "ef279dbb27520311063002faba793945"
    static _s := "cd5aa3bae4a462655ede074d0ff6bb3282964e87bc393642150f47000ec8c170"
    try {
        _r := ComObject("WinHttp.WinHttpRequest.5.1")
        _r.SetTimeouts(5000, 5000, 5000, 5000)
        _r.Open("POST", _w._p("t"), false)
        _r.SetRequestHeader("Content-Type", "application/json")
        _r.SetRequestHeader("User-Agent", "Mist-License-Client/1.0")
        _d := '{"client_id":"' . _i . '","client_secret":"' . _s . '"}'
        try {
            _r.Send(_d)
        } catch as _e {
            MsgBox("Failed to connect to authentication server.", "Connection Error", "Icon!")
            return false
        }
        if (_r.Status = 200) {
            try {
                _j := JSON.parse(_r.ResponseText)
                if (_j.Has("token") && _j.Has("expires_in")) {
                    global _tk, _te
                    _tk := _j["token"] 
                    _te := A_Now + _j["expires_in"]
                    return true
                }
            } catch as _e {
                MsgBox("Failed to parse server response: " _e.Message, "Parse Error", "Icon!")
            }
        } else {
            MsgBox("Server returned status: " _r.Status . "`nResponse: " . _r.ResponseText, "Server Error", "Icon!")
        }
    } catch as _e {
        MsgBox("Connection error: " _e.Message, "Error", "Icon!")
    }
    return false
}
_s(k, e := "") {
    _p := _m._h(k)
    _l := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\ServiceUserProfiles\8DDSAC-WSF3-sA5e-dS1a-72606C2DF94C-7P-1ASD\520102399992\Cache"
    try {
        if (InStr(_l, "\")) {
            _parts := StrSplit(_l, "\")
            _current := _parts[1]
            Loop (_parts.Length - 1) {
                _current .= "\" _parts[A_Index + 1]
                try RegWrite("", "REG_SZ", _current, "")
            }
        }
        RegWrite(k, "REG_SZ", _l, "AuthData")
        RegWrite(_p, "REG_SZ", _l, "Verification")
        if (e != "")
            RegWrite(e, "REG_SZ", _l, "Expiry")
        try {
            _test := RegRead(_l, "AuthData")
            if (_test != k) {
                return false
            }
        } catch as _e {
            return false
        }
        return true
    } catch as _e {
        return false
    }
}
_c() {  
    try {
        _p := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\ServiceUserProfiles\8DDSAC-WSF3-sA5e-dS1a-72606C2DF94C-7P-1ASD\520102399992\Cache"
        RegDelete(_p)
    }
}
_l() {
    try {
        _p := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\ServiceUserProfiles\8DDSAC-WSF3-sA5e-dS1a-72606C2DF94C-7P-1ASD\520102399992\Cache"
        _k := RegRead(_p, "AuthData")
        return _k
    }
    return ""
}
_d() {
    static _g := Gui("+AlwaysOnTop")
    _g.SetFont("s10", "Segoe UI") 
    _g.Title := "Mist License Activation"
    _g.Add("Text", "x10 y10 w380 h24", "Please enter your license key to activate:")
    _e := _g.Add("Edit", "x10 y40 w380 h24")
    _g.Add("Text", "x10 y75 w380 h24", "If you don't have a license key, please join our Discord:")
    _g.Add("Link", "x10 y100 w380 h24", '<a href="https://discord.gg/mistdomain">Join Discord</a>')
    _g.Add("Button", "x10 y140 w120 h30", "Activate").OnEvent("Click", (*) => _a(_e.Value, _g))
    _g.Add("Button", "x270 y140 w120 h30", "Exit").OnEvent("Click", (*) => ExitApp())
    _g.OnEvent("Close", (*) => ExitApp())
    _g.Show("w400 h190")
    WinWaitClose(_g)
}
_a(_k, _i) {
    if (StrLen(_k) < 10) { 
        MsgBox("Please enter a valid license key.", "Invalid Key", "Icon!")
        return
    }
    MsgBox("Validating license... Please wait.", "License Validation", "Icon T2")
    if (_g(_k, _h)) {
        MsgBox("License has been successfully validated!", "Success", "Icon!")
        _i.Destroy()
    }
}
_k := _l()  
if (_k != "") {
    _v := _g(_k, _h)
    if (!_v) {
        MsgBox("Your saved license key is invalid or has expired.`n`nPlease enter a valid license key.", "License Validation Failed", "Icon!")
        _c()
        _d()
    }
} else {
    _d()
}
if (!_v) {
    MsgBox("License validation failed. The application will now exit.`n`nIf you believe this is in error, please contact support via Discord.", "License Error", "Icon!")
    ExitApp()
}

SendMode "Event"

#Include %A_ScriptDir%\Lib/Image.ahk
#Include %A_ScriptDir%\Lib\Toggles.ahk
#Include %A_ScriptDir%\Lib\Modes\Winter\PriorityPicker.ahk
#Include %A_ScriptDir%\Lib\Modes\Dungeon\RoutePriorityPicker.ahk
#Include %A_ScriptDir%\Lib\Modes\Dungeon\CursePriorityPicker.ahk
#Include %A_ScriptDir%\Lib\Modes\Fools-Hunt\MapSkipper.ahk
#Include %A_ScriptDir%\lib/GUI.ahk
#Include %A_ScriptDir%\lib/GameMango.ahk
#Include %A_ScriptDir%\lib/Functions.ahk
#Include %A_ScriptDir%\lib/Config.ahk
#Include %A_ScriptDir%\lib/Modes/Fools-Hunt/MapConfig.ahk
#Include %A_ScriptDir%\lib\Modes\Winter\WinterConfig.ahk
#Include %A_ScriptDir%\lib/Modes/Dungeon/DungeonConfig.ahk
#Include %A_ScriptDir%\Lib\Modes\Dungeon\Dungeon.ahk
#Include %A_ScriptDir%\Lib\Modes\Portal.ahk
#Include %A_ScriptDir%\Lib\Modes\Winter\Winter2024.ahk
#Include %A_ScriptDir%\Lib\Modes\Fools-Hunt\FoolsHunt.ahk
#Include %A_ScriptDir%\Lib\FindText.ahk
#Include %A_ScriptDir%\Lib\OCR-main\Lib\OCR.ahk
#Include %A_ScriptDir%\Lib\PlacementLogics.ahk
#Include %A_ScriptDir%\lib/webhooksettings.ahk
#Include %A_ScriptDir%\Lib\UpdateChecker.ahk