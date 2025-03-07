#Include %A_ScriptDir%\Lib\GUI.ahk
global settingsFile := "" 


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
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global mode
    global ChallengeBox, PriorityUpgrade
    global PlacementPatternDropdown, PlaceSpeed, MatchMaking, UpgradeDuringPlacementBox
    global PhysicalTeam, MagicTeam, TeamSwap

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
                case "UpgradeEnabled1": upgradeEnabled1.Value := parts[2]
                case "UpgradeEnabled2": upgradeEnabled2.Value := parts[2]
                case "UpgradeEnabled3": upgradeEnabled3.Value := parts[2]
                case "UpgradeEnabled4": upgradeEnabled4.Value := parts[2]
                case "UpgradeEnabled5": upgradeEnabled5.Value := parts[2]
                case "UpgradeEnabled6": upgradeEnabled6.Value := parts[2]
                case "ChallengePlacement1": ChallengePlacement1.Text := parts[2]
                case "ChallengePlacement2": ChallengePlacement2.Text := parts[2]
                case "ChallengePlacement3": ChallengePlacement3.Text := parts[2]
                case "ChallengePlacement4": ChallengePlacement4.Text := parts[2]
                case "ChallengePlacement5": ChallengePlacement5.Text := parts[2]
                case "ChallengePlacement6": ChallengePlacement6.Text := parts[2]
                case "ChallengePriority1": ChallengePriority1.Text := parts[2]
                case "ChallengePriority2": ChallengePriority2.Text := parts[2]
                case "ChallengePriority3": ChallengePriority3.Text := parts[2]
                case "ChallengePriority4": ChallengePriority4.Text := parts[2]
                case "ChallengePriority5": ChallengePriority5.Text := parts[2]
                case "ChallengePriority6": ChallengePriority6.Text := parts[2]
                case "Speed": PlaceSpeed.Value := parts[2] ; Set the dropdown value
                case "Logic": PlacementPatternDropdown.Value := parts[2] ; Set the dropdown value
                case "Upgrade": PriorityUpgrade.Value := parts[2] ; Set the checkbox value
                case "Matchmake": MatchMaking.Value := parts[2] ; Set the checkbox value
                case "Challenge": ChallengeBox.Value := parts[2] ; Set the checkbox value
                case "Swap": TeamSwap.Value := parts[2] ; Set the checkbox value
                case "PhyTeam": physicalTeam.Text := parts[2]
                case "MagTeam": magicTeam.Text := parts[2]
                case "AttemptUpgrade": UpgradeDuringPlacementBox.Value := parts[2] ; Set the checkbox value
            }
        }
        AddToLog("Configuration settings loaded successfully")
        LoadWinterLocal()
    } 
}


SaveSettings(*) {
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global mode
    global ChallengeBox, PriorityUpgrade
    global PlacementPatternDropdown, PlaceSpeed, MatchMaking, UpgradeDuringPlacementBox
    global PhysicalTeam, MagicTeam, TeamSwap

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

        content .= "`n`nPriority1=" priority1.Text
        content .= "`nPriority2=" priority2.Text
        content .= "`nPriority3=" priority3.Text
        content .= "`nPriority4=" priority4.Text
        content .= "`nPriority5=" priority5.Text
        content .= "`nPriority6=" priority6.Text

        content .= "`n`nUpgradeEnabled1=" upgradeEnabled1.Value
        content .= "`nUpgradeEnabled2=" upgradeEnabled2.Value
        content .= "`nUpgradeEnabled3=" upgradeEnabled3.Value
        content .= "`nUpgradeEnabled4=" upgradeEnabled4.Value
        content .= "`nUpgradeEnabled5=" upgradeEnabled5.Value
        content .= "`nUpgradeEnabled6=" upgradeEnabled6.Value

        content .= "`n`n[ChallengePlacement]"
        content .= "`nChallengePlacement1=" ChallengePlacement1.Text
        content .= "`nChallengePlacement2=" ChallengePlacement2.Text
        content .= "`nChallengePlacement3=" ChallengePlacement3.Text
        content .= "`nChallengePlacement4=" ChallengePlacement4.Text
        content .= "`nChallengePlacement5=" ChallengePlacement5.Text
        content .= "`nChallengePlacement6=" ChallengePlacement6.Text

        content .= "`n`n[ChallengePriority]"
        content .= "`nChallengePriority1=" ChallengePriority1.Text
        content .= "`nChallengePriority2=" ChallengePriority2.Text
        content .= "`nChallengePriority3=" ChallengePriority3.Text
        content .= "`nChallengePriority4=" ChallengePriority4.Text
        content .= "`nChallengePriority5=" ChallengePriority5.Text
        content .= "`nChallengePriority6=" ChallengePriority6.Text

        content .= "`n`n[PlacementLogic]"
        content .= "`nLogic=" PlacementPatternDropdown.Value "`n"

        content .= "`n`n[PlaceSpeed]"
        content .= "`nSpeed=" PlaceSpeed.Value "`n"

        content .= "`n[Matchmaking]"
        content .= "`nMatchmake=" MatchMaking.Value "`n"

        content .= "`n[PriorityUpgrade]"
        content .= "`nUpgrade=" PriorityUpgrade.Value "`n"

        content .= "`n[AutoChallenge]"
        content .= "`nChallenge=" ChallengeBox.Value "`n"

        content .= "`n[TeamSwap]"
        content .= "`nSwap=" TeamSwap.Value "`n"

        content .= "`n[PhysicalTeam]"
        content .= "`nPhyTeam=" physicalTeam.Value "`n"
        
        content .= "`n[MagicTeam]"
        content .= "`nMagTeam=" magicTeam.Value "`n"

        content .= "`n`n[UpgradeDuringPlacement]"
        content .= "`nAttemptUpgrade=" UpgradeDuringPlacementBox.Value "`n"

        FileAppend(content, settingsFile)
        AddToLog("Configuration settings saved successfully")
        SaveWinterLocal()
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
            ; Define a mapping of section names to dropdown controls
            sectionDropdownMap := {
                PlacementLogic: PlacementPatternDropdown,
                MagicTeam: magicTeam,
                PhysicalTeam: physicalTeam,
                PlaceSpeed: PlaceSpeed,
                Matchmaking: MatchMaking,
                PriorityUpgrade: PriorityUpgrade,
                AutoChallenge: ChallengeBox
            }

            ; Loop through the section names and dropdown controls
            for section, dropdownControl in sectionDropdownMap {
                if InStr(section, section) {
                    if RegExMatch(line, section . "=(\w+)", &match) {
                        dropdownControl.Value := match.1 ; Set the dropdown value
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

SaveKeybindSettings(*) {
    AddToLog("Saving Keybind Configuration")
    
    if FileExist("Settings\Keybinds.txt")
        FileDelete("Settings\Keybinds.txt")
        
    FileAppend(Format("F1={}`nF2={}`nF3={}`nF4={}", F1Box.Value, F2Box.Value, F3Box.Value, F4Box.Value), "Settings\Keybinds.txt", "UTF-8")
    
    ; Update globals
    global F1Key := F1Box.Value
    global F2Key := F2Box.Value
    global F3Key := F3Box.Value
    global F4Key := F4Box.Value
    
    ; Update hotkeys
    Hotkey(F1Key, (*) => moveRobloxWindow())
    Hotkey(F2Key, (*) => StartMacro())
    Hotkey(F3Key, (*) => Reload())
    Hotkey(F4Key, (*) => TogglePause())
}

LoadKeybindSettings() {
    if FileExist("Settings\Keybinds.txt") {
        fileContent := FileRead("Settings\Keybinds.txt", "UTF-8")
        Loop Parse, fileContent, "`n" {
            parts := StrSplit(A_LoopField, "=")
            if (parts[1] = "F1")
                global F1Key := parts[2]
            else if (parts[1] = "F2")
                global F2Key := parts[2]
            else if (parts[1] = "F3")
                global F3Key := parts[2]
            else if (parts[1] = "F4")
                global F4Key := parts[2]
        }
    }
}