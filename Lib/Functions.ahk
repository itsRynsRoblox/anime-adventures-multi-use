#Include %A_ScriptDir%\Lib\GUI.ahk
global settingsFile := "" 
global confirmClicked := false


setupFilePath() {
    global settingsFile
    
    if !DirExist(A_ScriptDir "\Settings") {
        DirCreate(A_ScriptDir "\Settings")
    }

    settingsFile := A_ScriptDir "\Settings\Configuration.txt"
    return settingsFile
}

readInSettings() {
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global mode

    try {
        settingsFile := setupFilePath()
        if !FileExist(settingsFile) {
            return
        }

        content := FileRead(settingsFile)
        lines := StrSplit(content, "`n")
        
        for line in lines {
            if line = "" {
                continue
            }
            
            parts := StrSplit(line, "=")
            switch parts[1] {
                case "Mode": mode := parts[2]
                case "Enabled1": enabled1.Value := parts[2]
                case "Enabled2": enabled2.Value := parts[2]
                case "Enabled3": enabled3.Value := parts[2]
                case "Enabled4": enabled4.Value := parts[2]
                case "Enabled5": enabled5.Value := parts[2]
                case "Enabled6": enabled6.Value := parts[2]
                case "Placement1": placement1.Text := parts[2]
                case "Placement2": placement2.Text := parts[2]
                case "Placement3": placement3.Text := parts[2]
                case "Placement4": placement4.Text := parts[2]
                case "Placement5": placement5.Text := parts[2]
                case "Placement6": placement6.Text := parts[2]
                case "Priority1": priority1.Text := parts[2]
                case "Priority2": priority2.Text := parts[2]
                case "Priority3": priority3.Text := parts[2]
                case "Priority4": priority4.Text := parts[2]
                case "Priority5": priority5.Text := parts[2]
                case "Priority6": priority6.Text := parts[2]
            }
        }
        AddToLog("Configuration settings loaded successfully")
    }
}


SaveSettings(*) {
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global mode

    try {
        settingsFile := A_ScriptDir "\Settings\Configuration.txt"
        if FileExist(settingsFile) {
            FileDelete(settingsFile)
        }

        ; Save mode and map selection
        content := "Mode=" mode "`n"
        if (mode = "Story") {
            content .= "Map=" StoryDropdown.Text
        } else if (mode = "Raid") {
            content .= "Map=" RaidDropdown.Text
        }
        
        ; Save settings for each unit
        content .= "`n`nEnabled1=" enabled1.Value
        content .= "`nEnabled2=" enabled2.Value
        content .= "`nEnabled3=" enabled3.Value
        content .= "`nEnabled4=" enabled4.Value
        content .= "`nEnabled5=" enabled5.Value
        content .= "`nEnabled6=" enabled6.Value

        content .= "`n`nPlacement1=" placement1.Text
        content .= "`nPlacement2=" placement2.Text
        content .= "`nPlacement3=" placement3.Text
        content .= "`nPlacement4=" placement4.Text
        content .= "`nPlacement5=" placement5.Text
        content .= "`nPlacement6=" placement6.Text

        content .= "`nPriority1=" priority1.Text
        content .= "`nPriority2=" priority2.Text
        content .= "`nPriority3=" priority3.Text
        content .= "`nPriority4=" priority4.Text
        content .= "`nPriority5=" priority5.Text
        content .= "`nPriority6=" priority6.Text

        content .= "`n[CardPriority]"
        for index, dropDown in dropDowns
            {
                content .= (Format("`nCard{}={}", index+1, dropDown.Text))
            }
        
        FileAppend(content, settingsFile)
        AddToLog("Configuration settings saved successfully")
    }
}

LoadSettings() {
    global UnitData, mode
    try {
        settingsFile := A_ScriptDir "\Settings\Configuration.txt"
        if !FileExist(settingsFile) {
            return
        }

        content := FileRead(settingsFile)
        sections := StrSplit(content, "`n`n")
        
        for section in sections {
            if (InStr(section, "CardPriority")) {
                lines := StrSplit(section, "`n")
                
                for line in lines {
                    if line = "" {
                        continue
                    }
                    
                    if RegExMatch(line, "Card(\d+)=(\w+)", &match) {
                        slot := match.1
                        value := match.2
                        
                        priorityOrder[slot - 1] := value
                        
                        dropDown := dropDowns[slot - 1]
                        
                        if (dropDown) {
                            dropDown.Text := value
                        }
                    }
                }
            }
            else if (InStr(section, "Index=")) {
                lines := StrSplit(section, "`n")
                
                for line in lines {
                    if line = "" {
                        continue
                    }
                    
                    parts := StrSplit(line, "=")
                    if (parts[1] = "Index") {
                        index := parts[2]
                    } else if (index && UnitData.Has(Integer(index))) {
                        switch parts[1] {
                            case "Enabled": UnitData[index].Enabled.Value := parts[2]
                            case "Placement": UnitData[index].PlacementBox.Value := parts[2]
                        }
                    }
                }
            }
        }
        AddToLog("Auto settings loaded successfully")
    }
}

CheckBanner(unitName) {

    ; First check if Roblox window exists
    if !WinExist(rblxID) {
        AddToLog("Roblox window not found - skipping banner check")
        return false
    }

    ; Get Roblox window position
    WinGetPos(&robloxX, &robloxY, &rblxW, &rblxH, rblxID)
    
    detectionCount := 0
    AddToLog("Checking for: " unitName)

    ; Split unit name into individual words
    unitName := Trim(unitName)  ; Remove spaces
    unitWords := StrSplit(unitName, " ")

    Loop 5 {
        try {
            result := OCR.FromRect(robloxX + 280, robloxY + 293, 250, 55, "en",
                {   
                    grayscale: true,
                    scale: 2.0
                })
            
            ; Check if all words are found in the text
            allWordsFound := true
            for word in unitWords {
                if !InStr(result.Text, word) {
                    allWordsFound := false
                    break
                }
            }
            
            if (allWordsFound) {
                detectionCount++
                Sleep(100)
            }
        }
    }

    if (detectionCount >= 1) {
        AddToLog("Found " unitName " in banner")
        try {
            BannerFound()
        }
        return true
    }

    AddToLog("Did not find " unitName " in banner")
    return false
}

SaveBannerSettings(*) {
    AddToLog("Saving Banner Configuration")
    
    if FileExist("Settings\BannerUnit.txt")
        FileDelete("Settings\BannerUnit.txt")
    
    FileAppend(BannerUnitBox.Value, "Settings\BannerUnit.txt", "UTF-8")
}

SavePsSettings(*) {
    AddToLog("Saving Private Server")
    
    if FileExist("Settings\PrivateServer.txt")
        FileDelete("Settings\PrivateServer.txt")
    
    FileAppend(PsLinkBox.Value, "Settings\PrivateServer.txt", "UTF-8")
}

SaveUINavSettings(*) {
    AddToLog("Saving UI Navigation Key")
    
    if FileExist("Settings\UINavigation.txt")
        FileDelete("Settings\UINavigation.txt")
    
    FileAppend(UINavBox.Value, "Settings\UINavigation.txt", "UTF-8")
}

;Opens discord Link
OpenDiscordLink() {
    Run("https://discord.gg/mistdomain")
 }
 
 ;Minimizes the UI
 minimizeUI(*){
    aaMainUI.Minimize()
 }
 
 Destroy(*){
    aaMainUI.Destroy()
    ExitApp
 }
 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
 ;Gets the current time
 getCurrentTime() {
     currentHour := A_Hour
     currentMinute := A_Min
     currentSecond := A_Sec
 
     return Format("{:d}h.{:02}m.{:02}s", currentHour, currentMinute, currentSecond)
 }



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text
    
    ; Hide all dropdowns first
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    MatchMaking.Visible := false
    ReturnLobbyBox.Visible := false
    ContractPageDropdown.Visible := false  
    ContractJoinDropdown.Visible := false 
    
    if (selected = "Story") {
        StoryDropdown.Visible := true
        StoryActDropdown.Visible := true
        mode := "Story"
    } else if (selected = "Legend") {
        LegendDropDown.Visible := true
        LegendActDropdown.Visible := true
        mode := "Legend"
    } else if (selected = "Raid") {
        RaidDropdown.Visible := true
        RaidActDropdown.Visible := true
        mode := "Raid"
    } else if (selected = "Infinity Castle") {
        InfinityCastleDropdown.Visible := true
        mode := "Infinity Castle"
    } else if (selected = "Contract") {
        ContractPageDropdown.Visible := true
        ContractJoinDropdown.Visible := true
        mode := "Contract"
    } else if (selected = "Cursed Womb") {
        mode := "Cursed Womb"
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnLegendChange(*) {
    if (LegendDropDown.Text != "") {
        LegendActDropdown.Visible := true
    } else {
        LegendActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text " - " StoryActDropdown.Text)
        MatchMaking.Visible := (StoryActDropdown.Text = "Infinity")
        ReturnLobbyBox.Visible := (StoryActDropdown.Text = "Infinity")
        NextLevelBox.Visible := (StoryActDropdown.Text != "Infinity")
    }
    ; For Legend mode, check if both Legend and Act are selected
    else if (ModeDropdown.Text = "Legend") {
        if (LegendDropDown.Text = "" || LegendActDropdown.Text = "") {
            AddToLog("Please select both Legend Stage and Act before confirming")
            return
        }
        AddToLog("Selected " LegendDropDown.Text " - " LegendActDropdown.Text)
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
        ; For Cursed Womb, check if both Legend and Act are selected
    else if (ModeDropdown.Text = "Cursed Womb") {
        AddToLog("Selected " LegendDropDown.Text " - " LegendActDropdown.Text)
    }
    ; For Raid mode, check if both Raid and RaidAct are selected
    else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "" || RaidActDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        AddToLog("Selected " RaidDropdown.Text " - " RaidActDropdown.Text)
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
    ; For Infinity Castle, check if mode is selected
    else if (ModeDropdown.Text = "Infinity Castle") {
    if (InfinityCastleDropdown.Text = "") {
        AddToLog("Please select an Infinity Castle difficulty before confirming")
        return
    }
    AddToLog("Selected Infinity Castle - " InfinityCastleDropdown.Text)
    MatchMaking.Visible := false  
    ReturnLobbyBox.Visible := false
    }
    ; For Contract mode
    else if (ModeDropdown.Text = "Contract") {
        if (ContractPageDropdown.Text = "" || ContractJoinDropdown.Text = "") {
            AddToLog("Please select both Contract Page and Join Type before confirming")
            return
        }
        AddToLog("Selected Contract Page " ContractPageDropdown.Text " - " ContractJoinDropdown.Text)
        MatchMaking.Visible := false
        ReturnLobbyBox.Visible := true
    }
    ; Winter Event
    else if (ModeDropdown.Text = "Winter Event") {
        AddToLog("Selected Winter Event")
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
    else {
        AddToLog("Selected " ModeDropdown.Text " mode")
        MatchMaking.Visible := false
        ReturnLobbyBox.Visible := false
    }

    AddToLog("Don't forget to enable Click to Move! (I forget sometimes too!)")

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    ContractPageDropdown.Visible := false
    ContractJoinDropdown.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    Hotkeytext3.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}
 
CaptchaDetect(x, y, w, h, inputX, inputY) {
    detectionCount := 0
    AddToLog("Checking for numbers...")
    Loop 10 {
        try {
            result := OCR.FromRect(x, y, w, h, "FirstFromAvailableLanguages", 
                {   
                    grayscale: true,
                    scale: 2.0
                })
            
            if result {
                ; Get text before any linebreak
                number := StrSplit(result.Text, "`n")[1]
                
                ; Clean to just get numbers
                number := RegExReplace(number, "[^\d]")
                
                if (StrLen(number) >= 5 && StrLen(number) <= 7) {
                    detectionCount++
                    
                    if (detectionCount >= 1) {
                        ; Send exactly what we detected in the green text
                        FixClick(inputX, inputY)
                        Sleep(300)
                        
                        AddToLog("Sending number: " number)
                        for digit in StrSplit(number) {
                            Send(digit)
                            Sleep(120)
                        }
                        Sleep(200)
                        return true
                    }
                }
            }
        }
        Sleep(200)  
    }
    AddToLog("Could not detect valid captcha")
    return false
}

TogglePriorityDropdowns(*) {
    global PriorityUpgrade, priority1, priority2, priority3, priority4, priority5, priority6
    shouldShow := PriorityUpgrade.Value

    priority1.Visible := shouldShow
    priority2.Visible := shouldShow
    priority3.Visible := shouldShow
    priority4.Visible := shouldShow
    priority5.Visible := shouldShow
    priority6.Visible := shouldShow

    for unit in UnitData {
        unit.PriorityText.Visible := shouldShow
    }
}

FindAndClickColor(targetColor := (ModeDropdown.Text = "Winter Event" ? 0x006783 : 0xFAFF4D), searchArea := [0, 0, A_ScreenWidth, A_ScreenHeight]) { ;targetColor := Winter Event Color : 0x006783 / Contracts Color : 0xFAFF4D
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Color found and clicked at: X" foundX " Y" foundY)
        return true

    }
}

cardSelector() {
    AddToLog("Picking card in priority order")
    if (ok := FindText(&X, &Y, 200, 239, 276, 270, 0, 0, UnitExistence)) {
        FixClick(329, 184) ; close upg menu
        sleep 100
    }

    FixClick(59, 572) ; Untarget Mouse
    sleep 100

    for index, priority in priorityOrder {
        if (!textCards.Has(priority)) {
			;AddToLog(Format("Card {} not available in textCards", priority))																
            continue
        }
        if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, textCards.Get(priority))) {
			
			if (priority == "shield") {
                if (RadioHighest.Value == 1) {
                    AddToLog("Picking highest shield debuff")
                    if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield3)) {
                        AddToLog("Found shield 3")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield2)) {
                        AddToLog("Found shield 2")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield1)) {
                        AddToLog("Found shield 1")
                    }
                }

            }

            else if (priority == "speed") {
                if (RadioHighest.Value == 1) {
                    AddToLog("Picking highest speed debuff")
                    if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed3)) {
                        AddToLog("Found speed 3")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed2)) {
                        AddToLog("Found speed 2")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed1)) {
                        AddToLog("Found speed 1")
                    }
                }
            }

            else if (priority == "health") {
                if (RadioHighest.Value == 1) {
                    AddToLog("Picking highest health debuff")
                    if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health3)) {
                        AddToLog("Found health 3")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health2)) {
                        AddToLog("Found health 2")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health1)) {
                        AddToLog("Found health 1")
                    }
                }
            }

            else if (priority == "regen") {
                if (RadioHighest.Value == 1) {
                    AddToLog("Picking highest regen debuff")
                    if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen3)) {
                        AddToLog("Found regen 3")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen2)) {
                        AddToLog("Found regen 2")
                    }
                    else if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen1)) {
                        AddToLog("Found regen 1")
                    }
                }
            }
            
            else if (priority == "yen") {
				if (ok := FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, yen2)) {
					AddToLog("Found yen 2")
				}
				else {
					AddToLog("Found yen 1")
				}
			}

            FindText().Click(cardX, cardY, 0)
            MouseMove 0, 10, 2, "R"
            Click 2
            sleep 1000
            MouseMove 0, 120, 2, "R"
            Click 2
            AddToLog(Format("Picked card: {}", priority))
            sleep 5000
            return
        }
    }
    AddToLog("Failed to pick a card")
}

CheckForEmptyKeys() {
    AddToLog("Looking for key purchase prompt")
    if (ok:=FindText(&X, &Y, 434-150000, 383-150000, 434+150000, 383+150000, 0, 0, RobuxPurchaseKey)) {
        AddToLog("Found an attempt to purchase key for robux, closing macro.")
        return
    }
}
