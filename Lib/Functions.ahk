#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

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
    SaveChestsBox.Visible := false
    PortalDropdown.Visible := false 
    PortalJoinDropdown.Visible := false  
    ContractPageDropdown.Visible := false  
    ContractJoinDropdown.Visible := false 

    ;Dungeon
    SaveChestsBox.Visible := false
    QuitIfFailBox.Visible := false

    ;Shibuya Infinite
    ShibuyaSwap.Visible := false
    ShibuyaSwapText.Visible := false

    ;Contracts
    TeamSwap.Visible := false
    MagicTeamText.Visible := false
    MagicTeam.Visible := false
    PhysicalTeamText.Visible := false
    PhysicalTeam.Visible := false
    
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
        TeamSwap.Visible := true
        MagicTeamText.Visible := true
        MagicTeam.Visible := true
        PhysicalTeamText.Visible := true
        PhysicalTeam.Visible := true
    } else if (selected = "Portal") {
        PortalDropdown.Visible := true
        PortalJoinDropdown.Visible := true
        mode := "Portal"
    } else if (selected = "Dungeon") {
        AddToLog("⚠️ Dungeon is still under development! Stay tuned for updates.")
        SaveChestsBox.Visible := true
        QuitIfFailBox.Visible := true
        mode := "Dungeon"
    } else if (selected = "Cursed Womb") {
        mode := "Cursed Womb"
    } else if (selected = "Winter Event") {
        mode := "Winter Event"
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnStoryActChange(*) {
    if (StoryActDropdown.Text = "Infinity") {
        if (StoryDropdown.Text = "Shibuya District") {
            ShibuyaSwapText.Visible := true
            ShibuyaSwap.Visible := true
        } else {
            ShibuyaSwapText.Visible := false
            ShibuyaSwap.Visible := false
        }
    } else {
        ShibuyaSwapText.Visible := false
        ShibuyaSwap.Visible := false
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
    ; For Portal, check if both Portal and Join Type are selected
    else if (ModeDropdown.Text = "Portal") {
    if (PortalDropdown.Text = "" || PortalJoinDropdown.Text = "") {
        AddToLog("Please select both Portal and Join Type before confirming")
        return
    }
    AddToLog("Selected " PortalDropdown.Text " - " PortalJoinDropdown.Text)
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
    }
    else {
        AddToLog("Selected " ModeDropdown.Text " mode")
        MatchMaking.Visible := false
        ReturnLobbyBox.Visible := false
    }

    AddToLog("Don't forget to enable UI Navigation and Click to Move!")

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    PortalDropdown.Visible := false
    PortalJoinDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    ContractPageDropdown.Visible := false
    ContractJoinDropdown.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    global confirmClicked := true
}

ToggleSaveChestsForBoss(*) {
    global SaveChestsForBoss
    SaveChestsForBoss := !SaveChestsForBoss
    AddToLog("Save chests for boss room: " (SaveChestsForBoss ? "Enabled" : "Disabled"))
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
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    isChallenge := (mode = "Challenge")
    shouldShow := PriorityUpgrade.Value & !isChallenge
    shouldShowChallenge := PriorityUpgrade.Value & isChallenge

    priority1.Visible := shouldShow
    priority2.Visible := shouldShow
    priority3.Visible := shouldShow
    priority4.Visible := shouldShow
    priority5.Visible := shouldShow
    priority6.Visible := shouldShow

    ChallengePriority1.Visible := shouldShowChallenge
    ChallengePriority2.Visible := shouldShowChallenge
    ChallengePriority3.Visible := shouldShowChallenge
    ChallengePriority4.Visible := shouldShowChallenge
    ChallengePriority5.Visible := shouldShowChallenge
    ChallengePriority6.Visible := shouldShowChallenge

    for unit in UnitData {
        unit.PriorityText.Visible := shouldShow
    }
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

FindAndClickColor(targetColor := (ModeDropdown.Text = "Winter Event" ? 0x006783 : 0xFAFF4D), searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) { ;targetColor := Winter Event Color : 0x006783 / Contracts Color : 0xFAFF4D
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

FindAndClickHauntedPath(targetColor := (mode = "Story" ? 0x191622 : 0x1D1414), searchArea := (mode = "Story" ? [708, 332, 833, 365] : [558, 335, 694, 369])) {
    
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
        AddToLog("Color found at: X" foundX " Y" foundY)
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

OpenGithub() {
    ; Removed to prevent access to non testers / mists donators
}

OpenDiscord() {
    Run("https://discord.gg/mistdomain")
}

CheckBuffs() {
    contractPage := ContractPageDropdown.Text
        ; Handle 4-5 Page pattern selection
        if (contractPage = "Page 4-5") {
            contractPage := GetContractPage()
        }
    pages := [
        {name: "Page 1", coords: [131, 232, 286, 477]},
        {name: "Page 2", coords: [292, 232, 443, 477]},
        {name: "Page 3", coords: [450, 231, 605, 477]},
        {name: "Page 4", coords: [196, 229, 351, 477]},
        {name: "Page 5", coords: [358, 229, 510, 477]},
        {name: "Page 6", coords: [517, 232, 668, 476]},
    ]

    for index, page in pages {
        if (contractPage = page.name) {
            if (ok := FindText(&X, &Y, page.coords[1], page.coords[2], page.coords[3], page.coords[4], 0, 0, PhysicalBuff)) {
                AddToLog("Found Physical Buff")
                Sleep 1000
                SwapTeam(false)
            } else {
                if (ok := FindText(&X, &Y, page.coords[1], page.coords[2], page.coords[3], page.coords[4], 0, 0, MagicBuff)) {
                    AddToLog("Found Magic Buff")
                    Sleep 1000
                    SwapTeam(true)
                }
            }
        }
    }
}

SwapTeam(magic := false) {
    global physicalTeam, magicTeam
    teamNum := magic ? magicTeam.Text : physicalTeam.Text
    teamNum := Integer(RegExReplace(RegExReplace(teamNum, "", ""), "", ""))

    SendInput("K") ; Open Units
    Sleep 1000
    FixClick(398, 223) ; Click Teams
    Sleep 1000

    teams := [
        {name: "1", coords: [556, 230]},
        {name: "2", coords: [556, 320]},
        {name: "3", coords: [556, 410]},
        {name: "4", coords: [556, 256]},
        {name: "5", coords: [566, 340]},
        {name: "6", coords: [566, 427]},
    ]

    if (teamNum >= 3) {
        FixClick(390, 245)
        Sleep(200)
        Loop 5 {
            SendInput("{WheelDown}")
            Sleep(150)
        }
        Sleep(300)
    }
    for index, team in teams {
        if (magic) {
            if (magicTeam.Text = team.name) {
                AddToLog("Equipped Magic Team")
                FixClick(team.coords[1], team.coords[2])
                Sleep 300
            }
        } else {
            if (physicalTeam.Text = team.name) {
                AddToLog("Equipped Physical Team")
                FixClick(team.coords[1], team.coords[2])
                Sleep 300
            }
        }
    }
    FixClick(33, 400) ; Reopen Contracts
    Sleep 1000
}

UpgradeDetect(x, y, w, h, inputX, inputY, upgradeLimit) {
    detectionCount := 0
    AddToLog("Checking for upgrade level...")

    try {
        result := OCR.FromRect(x, y, w, h, "FirstFromAvailableLanguages", { grayscale: true, scale: 4.0 })

        if result {
            rawText := result.Text
            if (debugMessages) {
                AddToLog("Raw OCR Upgrade Text: " rawText)
            }

            ; Clean text to isolate "Upgrade" + number
            cleanedText := RegExReplace(rawText, ".*Upgrade\D*(\d+).*", "$1") ; Capture only the number after "Upgrade"
            cleanedText := StrReplace(cleanedText, "O", "0") ; Fix OCR mistaking 0 as O

            ; Explicitly replace "O" with "0" to ensure OCR doesn't misinterpret them
            if (cleanedText = "O") {
                cleanedText := "0"
                AddToLog(cleanedText)
            }

            if (debugMessages) {
                AddToLog("Cleaned Upgrade Number: " cleanedText)
            }

            ; Check if the cleaned text is a valid number
            if (cleanedText != "" && RegExMatch(cleanedText, "^\d+$")) {
                detectionCount++
                    
                if (detectionCount >= 1) {
                    if (cleanedText >= upgradeLimit) {
                        AddToLog("Found Upgrade Level: " cleanedText)
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
    }
    AddToLog("Could not detect valid upgrade level")
    return false
}