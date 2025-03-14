﻿#Include %A_ScriptDir%\Lib\GUI.ahk
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
    global upgradeLimitEnabled1, upgradeLimitEnabled2, upgradeLimitEnabled3, upgradeLimitEnabled4, upgradeLimitEnabled5, upgradeLimitEnabled6
    global UpgradeLimit1, UpgradeLimit2, UpgradeLimit3, UpgradeLimit4, UpgradeLimit5, UpgradeLimit6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global mode
    global ChallengeBox, PriorityUpgrade
    global PlacementPatternDropdown, PlaceSpeed, MatchMaking
    global PhysicalTeam, MagicTeam, TeamSwap
    global QuitIfFailBox
    global RejoinRoblox
    global ReturnLobbyBox, StoryUINav, MaxUpgradeBeforeMoving

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

                case "UpgradeLimit1": UpgradeLimit1.Text := parts[2]
                case "UpgradeLimit2": UpgradeLimit2.Text := parts[2]
                case "UpgradeLimit3": UpgradeLimit3.Text := parts[2]
                case "UpgradeLimit4": UpgradeLimit4.Text := parts[2]
                case "UpgradeLimit5": UpgradeLimit5.Text := parts[2]
                case "UpgradeLimit6": UpgradeLimit6.Text := parts[2]

                case "UpgradeEnabled1": upgradeEnabled1.Value := parts[2]
                case "UpgradeEnabled2": upgradeEnabled2.Value := parts[2]
                case "UpgradeEnabled3": upgradeEnabled3.Value := parts[2]
                case "UpgradeEnabled4": upgradeEnabled4.Value := parts[2]
                case "UpgradeEnabled5": upgradeEnabled5.Value := parts[2]
                case "UpgradeEnabled6": upgradeEnabled6.Value := parts[2]
                case "UpgradeLimitEnabled1": upgradeLimitEnabled1.Value := parts[2]
                case "UpgradeLimitEnabled2": upgradeLimitEnabled2.Value := parts[2]
                case "UpgradeLimitEnabled3": upgradeLimitEnabled3.Value := parts[2]
                case "UpgradeLimitEnabled4": upgradeLimitEnabled4.Value := parts[2]
                case "UpgradeLimitEnabled5": upgradeLimitEnabled5.Value := parts[2]
                case "UpgradeLimitEnabled6": upgradeLimitEnabled6.Value := parts[2]
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

                case "StopAfterDefeat": QuitIfFailBox.Value := parts[2] ; Set the checkbox value
                case "FailsafeEnabled": RejoinRoblox.Value := parts[2] ; Set the checkbox value
                case "ToLobby": ReturnLobbyBox.Value := parts[2] ; Set the checkbox value
                case "UseNavigation": StoryUINav.Value := parts[2] ; Set the checkbox value
                case "Upgrade1By1": MaxUpgradeBeforeMoving.Value := parts[2] ; Set the checkbox value
            }
        }
        AddToLog("Configuration settings loaded successfully")
        LoadWinterLocal()
    } 
}


SaveSettings(*) {
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6
    global upgradeLimitEnabled1, upgradeLimitEnabled2, upgradeLimitEnabled3, upgradeLimitEnabled4, upgradeLimitEnabled5, upgradeLimitEnabled6
    global UpgradeLimit1, UpgradeLimit2, UpgradeLimit3, UpgradeLimit4, UpgradeLimit5, UpgradeLimit6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global mode
    global ChallengeBox, PriorityUpgrade
    global PlacementPatternDropdown, PlaceSpeed, MatchMaking
    global PhysicalTeam, MagicTeam, TeamSwap
    global RejoinRoblox, ReturnLobbyBox, QuitIfFailBox, StoryUINav, MaxUpgradeBeforeMoving

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

        ; Create ChallengePlacement section
        content .= "`n`n[ChallengePlacement]"
        Loop 6 {
            content .= "`nChallengePlacement" A_Index "=" ChallengePlacement%A_Index%.Text
        }

        ; Create ChallengePriority section
        content .= "`n`n[ChallengePriority]"
        Loop 6 {
            content .= "`nChallengePriority" A_Index "=" ChallengePriority%A_Index%.Text
        }

        ; Create Placement section
        content .= "`n`n[Placement]"
        Loop 6 {
            content .= "`nPlacement" A_Index "=" placement%A_Index%.Text
        }

        ; Create Priority section
        content .= "`n`n[Priority]"
        Loop 6 {
            content .= "`nPriority" A_Index "=" priority%A_Index%.Text
        }

        content .= "`n`nUpgradeLimit1=" UpgradeLimit1.Text
        content .= "`nUpgradeLimit2=" UpgradeLimit2.Text
        content .= "`nUpgradeLimit3=" UpgradeLimit3.Text
        content .= "`nUpgradeLimit4=" UpgradeLimit4.Text
        content .= "`nUpgradeLimit5=" UpgradeLimit5.Text
        content .= "`nUpgradeLimit6=" UpgradeLimit6.Text

        content .= "`n`nUpgradeEnabled1=" upgradeEnabled1.Value
        content .= "`nUpgradeEnabled2=" upgradeEnabled2.Value
        content .= "`nUpgradeEnabled3=" upgradeEnabled3.Value
        content .= "`nUpgradeEnabled4=" upgradeEnabled4.Value
        content .= "`nUpgradeEnabled5=" upgradeEnabled5.Value
        content .= "`nUpgradeEnabled6=" upgradeEnabled6.Value

        content .= "`n`nUpgradeLimitEnabled1=" upgradeLimitEnabled1.Value
        content .= "`nUpgradeLimitEnabled2=" upgradeLimitEnabled2.Value
        content .= "`nUpgradeLimitEnabled3=" upgradeLimitEnabled3.Value
        content .= "`nUpgradeLimitEnabled4=" upgradeLimitEnabled4.Value
        content .= "`nUpgradeLimitEnabled5=" upgradeLimitEnabled5.Value
        content .= "`nUpgradeLimitEnabled6=" upgradeLimitEnabled6.Value

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

        content .= "`n`n[QuitUponDefeat]"
        content .= "`nStopAfterDefeat=" QuitIfFailBox.Value "`n"

        content .= "`n`n[RejoinFailsafe]"
        content .= "`nFailsafeEnabled=" RejoinRoblox.Value "`n"

        content .= "`n`n[ReturnToLobby]"
        content .= "`nToLobby=" ReturnLobbyBox.Value "`n"

        content .= "`n`n[UINavigation]"
        content .= "`nUseNavigation=" StoryUINav.Value "`n"

        content .= "`n`n[UpgradeTesting]"
        content .= "`nUpgrade1By1=" MaxUpgradeBeforeMoving.Value "`n"

        FileAppend(content, settingsFile)
        AddToLog("Configuration settings saved successfully")
        SaveWinterLocal()
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