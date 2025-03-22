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
    ; General settings
    global mode, UseCustomSettings

    ; General Unit Settings
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global PlacementPatternDropdown, LobbySleepTimer

    ; Upgrade limits
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6
    global upgradeLimitEnabled1, upgradeLimitEnabled2, upgradeLimitEnabled3, upgradeLimitEnabled4, upgradeLimitEnabled5, upgradeLimitEnabled6
    global UpgradeLimit1, UpgradeLimit2, UpgradeLimit3, UpgradeLimit4, UpgradeLimit5, UpgradeLimit6


    ; General settings
    global ChallengeBox, PriorityUpgrade, PlaceSpeed, MatchMaking, MaxUpgradeBeforeMoving, RejoinRoblox, ReturnLobbyBox, StoryUINav

    ; Challenge placements
    global ChallengeEnabled1, ChallengeEnabled2, ChallengeEnabled3, ChallengeEnabled4, ChallengeEnabled5, ChallengeEnabled6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global challengeUpgradeEnabled1, challengeUpgradeEnabled2, challengeUpgradeEnabled3, challengeUpgradeEnabled4, challengeUpgradeEnabled5, challengeUpgradeEnabled6
    global challengeUpgradeLimitEnabled1, challengeUpgradeLimitEnabled2, challengeUpgradeLimitEnabled3, challengeUpgradeLimitEnabled4, challengeUpgradeLimitEnabled5, challengeUpgradeLimitEnabled6
    global ChallengeUpgradeLimit1, ChallengeUpgradeLimit2, ChallengeUpgradeLimit3, ChallengeUpgradeLimit4, ChallengeUpgradeLimit5, ChallengeUpgradeLimit6

    ; Contract placements
    global ContractEnabled1, ContractEnabled2, ContractEnabled3, ContractEnabled4, ContractEnabled5, ContractEnabled6
    global ContractPlacement1, ContractPlacement2, ContractPlacement3, ContractPlacement4, ContractPlacement5, ContractPlacement6
    global ContractPriority1, ContractPriority2, ContractPriority3, ContractPriority4, ContractPriority5, ContractPriority6
    global contractUpgradeEnabled1, contractUpgradeEnabled2, contractUpgradeEnabled3, contractUpgradeEnabled4, contractUpgradeEnabled5, contractUpgradeEnabled6
    global contractUpgradeLimitEnabled1, contractUpgradeLimitEnabled2, contractUpgradeLimitEnabled3, contractUpgradeLimitEnabled4, contractUpgradeLimitEnabled5, contractUpgradeLimitEnabled6
    global ContractUpgradeLimit1, ContractUpgradeLimit2, ContractUpgradeLimit3, ContractUpgradeLimit4, ContractUpgradeLimit5, ContractUpgradeLimit6

    ; Dungeon placements
    global DungeonEnabled1, DungeonEnabled2, DungeonEnabled3, DungeonEnabled4, DungeonEnabled5, DungeonEnabled6
    global DungeonPlacement1, DungeonPlacement2, DungeonPlacement3, DungeonPlacement4, DungeonPlacement5, DungeonPlacement6
    global DungeonPriority1, DungeonPriority2, DungeonPriority3, DungeonPriority4, DungeonPriority5, DungeonPriority6
    global dungeonUpgradeEnabled1, dungeonUpgradeEnabled2, dungeonUpgradeEnabled3, dungeonUpgradeEnabled4, dungeonUpgradeEnabled5, dungeonUpgradeEnabled6
    global dungeonUpgradeLimitEnabled1, dungeonUpgradeLimitEnabled2, dungeonUpgradeLimitEnabled3, dungeonUpgradeLimitEnabled4, dungeonUpgradeLimitEnabled5, dungeonUpgradeLimitEnabled6
    global DungeonUpgradeLimit1, DungeonUpgradeLimit2, DungeonUpgradeLimit3, DungeonUpgradeLimit4, DungeonUpgradeLimit5, DungeonUpgradeLimit6

    ; Raid placements
    global raidEnabled1, raidEnabled2, raidEnabled3, raidEnabled4, raidEnabled5, raidEnabled6
    global raidPlacement1, raidPlacement2, raidPlacement3, raidPlacement4, raidPlacement5, raidPlacement6
    global raidPriority1, raidPriority2, raidPriority3, raidPriority4, raidPriority5, raidPriority6
    global raidUpgradeEnabled1, raidUpgradeEnabled2, raidUpgradeEnabled3, raidUpgradeEnabled4, raidUpgradeEnabled5, raidUpgradeEnabled6
    global raidUpgradeLimitEnabled1, raidUpgradeLimitEnabled2, raidUpgradeLimitEnabled3, raidUpgradeLimitEnabled4, raidUpgradeLimitEnabled5, raidUpgradeLimitEnabled6
    global raidUpgradeLimit1, raidUpgradeLimit2, raidUpgradeLimit3, raidUpgradeLimit4, raidUpgradeLimit5, raidUpgradeLimit6

    ; Winter placements
    global winterEnabled1, winterEnabled2, winterEnabled3, winterEnabled4, winterEnabled5, winterEnabled6
    global winterPlacement1, winterPlacement2, winterPlacement3, winterPlacement4, winterPlacement5, winterPlacement6
    global winterPriority1, winterPriority2, winterPriority3, winterPriority4, winterPriority5, winterPriority6
    global winterUpgradeEnabled1, winterUpgradeEnabled2, winterUpgradeEnabled3, winterUpgradeEnabled4, winterUpgradeEnabled5, winterUpgradeEnabled6
    global winterUpgradeLimitEnabled1, winterUpgradeLimitEnabled2, winterUpgradeLimitEnabled3, winterUpgradeLimitEnabled4, winterUpgradeLimitEnabled5, winterUpgradeLimitEnabled6
    global winterUpgradeLimit1, winterUpgradeLimit2, winterUpgradeLimit3, winterUpgradeLimit4, winterUpgradeLimit5, winterUpgradeLimit6


    ;Dungeon Settings
    global StopAfterDefeat, DenyShrines, UseNewDungeonRoute, SaveChestsBox

    ; Team settings
    global PhysicalTeam, MagicTeam, TeamSwap

    ;Maharaga
    global FirstAdaptation, SecondAdaptation, FinalAdaptation, MahoragoMode

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

                case "ChallengeEnabled1": ChallengeEnabled1.Value := parts[2]
                case "ChallengeEnabled2": ChallengeEnabled2.Value := parts[2]
                case "ChallengeEnabled3": ChallengeEnabled3.Value := parts[2]
                case "ChallengeEnabled4": ChallengeEnabled4.Value := parts[2]
                case "ChallengeEnabled5": ChallengeEnabled5.Value := parts[2]
                case "ChallengeEnabled6": ChallengeEnabled6.Value := parts[2]

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

                case "ChallengeUpgradeLimit1": ChallengeUpgradeLimit1.Text := parts[2]
                case "ChallengeUpgradeLimit2": ChallengeUpgradeLimit2.Text := parts[2]
                case "ChallengeUpgradeLimit3": ChallengeUpgradeLimit3.Text := parts[2]
                case "ChallengeUpgradeLimit4": ChallengeUpgradeLimit4.Text := parts[2]
                case "ChallengeUpgradeLimit5": ChallengeUpgradeLimit5.Text := parts[2]
                case "ChallengeUpgradeLimit6": ChallengeUpgradeLimit6.Text := parts[2]

                case "ChallengeUpgradeEnabled1": challengeUpgradeEnabled1.Value := parts[2]
                case "ChallengeUpgradeEnabled2": challengeUpgradeEnabled2.Value := parts[2]
                case "ChallengeUpgradeEnabled3": challengeUpgradeEnabled3.Value := parts[2]
                case "ChallengeUpgradeEnabled4": challengeUpgradeEnabled4.Value := parts[2]
                case "ChallengeUpgradeEnabled5": challengeUpgradeEnabled5.Value := parts[2]
                case "ChallengeUpgradeEnabled6": challengeUpgradeEnabled6.Value := parts[2]

                case "ChallengeUpgradeLimitEnabled1": challengeUpgradeLimitEnabled1.Value := parts[2]
                case "ChallengeUpgradeLimitEnabled2": challengeUpgradeLimitEnabled2.Value := parts[2]
                case "ChallengeUpgradeLimitEnabled3": challengeUpgradeLimitEnabled3.Value := parts[2]
                case "ChallengeUpgradeLimitEnabled4": challengeUpgradeLimitEnabled4.Value := parts[2]
                case "ChallengeUpgradeLimitEnabled5": challengeUpgradeLimitEnabled5.Value := parts[2]
                case "ChallengeUpgradeLimitEnabled6": challengeUpgradeLimitEnabled6.Value := parts[2]

                case "ContractEnabled1": ContractEnabled1.Value := parts[2]
                case "ContractEnabled2": ContractEnabled2.Value := parts[2]
                case "ContractEnabled3": ContractEnabled3.Value := parts[2]
                case "ContractEnabled4": ContractEnabled4.Value := parts[2]
                case "ContractEnabled5": ContractEnabled5.Value := parts[2]
                case "ContractEnabled6": ContractEnabled6.Value := parts[2]
                
                case "ContractPlacement1": ContractPlacement1.Text := parts[2]
                case "ContractPlacement2": ContractPlacement2.Text := parts[2]
                case "ContractPlacement3": ContractPlacement3.Text := parts[2]
                case "ContractPlacement4": ContractPlacement4.Text := parts[2]
                case "ContractPlacement5": ContractPlacement5.Text := parts[2]
                case "ContractPlacement6": ContractPlacement6.Text := parts[2]
                
                case "ContractPriority1": ContractPriority1.Text := parts[2]
                case "ContractPriority2": ContractPriority2.Text := parts[2]
                case "ContractPriority3": ContractPriority3.Text := parts[2]
                case "ContractPriority4": ContractPriority4.Text := parts[2]
                case "ContractPriority5": ContractPriority5.Text := parts[2]
                case "ContractPriority6": ContractPriority6.Text := parts[2]
                
                case "ContractUpgradeLimit1": ContractUpgradeLimit1.Text := parts[2]
                case "ContractUpgradeLimit2": ContractUpgradeLimit2.Text := parts[2]
                case "ContractUpgradeLimit3": ContractUpgradeLimit3.Text := parts[2]
                case "ContractUpgradeLimit4": ContractUpgradeLimit4.Text := parts[2]
                case "ContractUpgradeLimit5": ContractUpgradeLimit5.Text := parts[2]
                case "ContractUpgradeLimit6": ContractUpgradeLimit6.Text := parts[2]
                
                case "ContractUpgradeEnabled1": contractUpgradeEnabled1.Value := parts[2]
                case "ContractUpgradeEnabled2": contractUpgradeEnabled2.Value := parts[2]
                case "ContractUpgradeEnabled3": contractUpgradeEnabled3.Value := parts[2]
                case "ContractUpgradeEnabled4": contractUpgradeEnabled4.Value := parts[2]
                case "ContractUpgradeEnabled5": contractUpgradeEnabled5.Value := parts[2]
                case "ContractUpgradeEnabled6": contractUpgradeEnabled6.Value := parts[2]
                
                case "ContractUpgradeLimitEnabled1": contractUpgradeLimitEnabled1.Value := parts[2]
                case "ContractUpgradeLimitEnabled2": contractUpgradeLimitEnabled2.Value := parts[2]
                case "ContractUpgradeLimitEnabled3": contractUpgradeLimitEnabled3.Value := parts[2]
                case "ContractUpgradeLimitEnabled4": contractUpgradeLimitEnabled4.Value := parts[2]
                case "ContractUpgradeLimitEnabled5": contractUpgradeLimitEnabled5.Value := parts[2]
                case "ContractUpgradeLimitEnabled6": contractUpgradeLimitEnabled6.Value := parts[2]

                case "DungeonEnabled1": DungeonEnabled1.Value := parts[2]
                case "DungeonEnabled2": DungeonEnabled2.Value := parts[2]
                case "DungeonEnabled3": DungeonEnabled3.Value := parts[2]
                case "DungeonEnabled4": DungeonEnabled4.Value := parts[2]
                case "DungeonEnabled5": DungeonEnabled5.Value := parts[2]
                case "DungeonEnabled6": DungeonEnabled6.Value := parts[2]
                
                case "DungeonPlacement1": DungeonPlacement1.Text := parts[2]
                case "DungeonPlacement2": DungeonPlacement2.Text := parts[2]
                case "DungeonPlacement3": DungeonPlacement3.Text := parts[2]
                case "DungeonPlacement4": DungeonPlacement4.Text := parts[2]
                case "DungeonPlacement5": DungeonPlacement5.Text := parts[2]
                case "DungeonPlacement6": DungeonPlacement6.Text := parts[2]
                
                case "DungeonPriority1": DungeonPriority1.Text := parts[2]
                case "DungeonPriority2": DungeonPriority2.Text := parts[2]
                case "DungeonPriority3": DungeonPriority3.Text := parts[2]
                case "DungeonPriority4": DungeonPriority4.Text := parts[2]
                case "DungeonPriority5": DungeonPriority5.Text := parts[2]
                case "DungeonPriority6": DungeonPriority6.Text := parts[2]
                
                case "DungeonUpgradeLimit1": DungeonUpgradeLimit1.Text := parts[2]
                case "DungeonUpgradeLimit2": DungeonUpgradeLimit2.Text := parts[2]
                case "DungeonUpgradeLimit3": DungeonUpgradeLimit3.Text := parts[2]
                case "DungeonUpgradeLimit4": DungeonUpgradeLimit4.Text := parts[2]
                case "DungeonUpgradeLimit5": DungeonUpgradeLimit5.Text := parts[2]
                case "DungeonUpgradeLimit6": DungeonUpgradeLimit6.Text := parts[2]
                
                case "DungeonUpgradeEnabled1": dungeonUpgradeEnabled1.Value := parts[2]
                case "DungeonUpgradeEnabled2": dungeonUpgradeEnabled2.Value := parts[2]
                case "DungeonUpgradeEnabled3": dungeonUpgradeEnabled3.Value := parts[2]
                case "DungeonUpgradeEnabled4": dungeonUpgradeEnabled4.Value := parts[2]
                case "DungeonUpgradeEnabled5": dungeonUpgradeEnabled5.Value := parts[2]
                case "DungeonUpgradeEnabled6": dungeonUpgradeEnabled6.Value := parts[2]
                
                case "DungeonUpgradeLimitEnabled1": dungeonUpgradeLimitEnabled1.Value := parts[2]
                case "DungeonUpgradeLimitEnabled2": dungeonUpgradeLimitEnabled2.Value := parts[2]
                case "DungeonUpgradeLimitEnabled3": dungeonUpgradeLimitEnabled3.Value := parts[2]
                case "DungeonUpgradeLimitEnabled4": dungeonUpgradeLimitEnabled4.Value := parts[2]
                case "DungeonUpgradeLimitEnabled5": dungeonUpgradeLimitEnabled5.Value := parts[2]
                case "DungeonUpgradeLimitEnabled6": dungeonUpgradeLimitEnabled6.Value := parts[2]

                case "RaidEnabled1": raidEnabled1.Value := parts[2]
                case "RaidEnabled2": raidEnabled2.Value := parts[2]
                case "RaidEnabled3": raidEnabled3.Value := parts[2]
                case "RaidEnabled4": raidEnabled4.Value := parts[2]
                case "RaidEnabled5": raidEnabled5.Value := parts[2]
                case "RaidEnabled6": raidEnabled6.Value := parts[2]

                case "RaidPlacement1": raidPlacement1.Text := parts[2]
                case "RaidPlacement2": raidPlacement2.Text := parts[2]
                case "RaidPlacement3": raidPlacement3.Text := parts[2]
                case "RaidPlacement4": raidPlacement4.Text := parts[2]
                case "RaidPlacement5": raidPlacement5.Text := parts[2]
                case "RaidPlacement6": raidPlacement6.Text := parts[2]

                case "RaidPriority1": raidPriority1.Text := parts[2]
                case "RaidPriority2": raidPriority2.Text := parts[2]
                case "RaidPriority3": raidPriority3.Text := parts[2]
                case "RaidPriority4": raidPriority4.Text := parts[2]
                case "RaidPriority5": raidPriority5.Text := parts[2]
                case "RaidPriority6": raidPriority6.Text := parts[2]

                case "RaidUpgradeLimit1": raidUpgradeLimit1.Text := parts[2]
                case "RaidUpgradeLimit2": raidUpgradeLimit2.Text := parts[2]
                case "RaidUpgradeLimit3": raidUpgradeLimit3.Text := parts[2]
                case "RaidUpgradeLimit4": raidUpgradeLimit4.Text := parts[2]
                case "RaidUpgradeLimit5": raidUpgradeLimit5.Text := parts[2]
                case "RaidUpgradeLimit6": raidUpgradeLimit6.Text := parts[2]

                case "RaidUpgradeEnabled1": raidUpgradeEnabled1.Value := parts[2]
                case "RaidUpgradeEnabled2": raidUpgradeEnabled2.Value := parts[2]
                case "RaidUpgradeEnabled3": raidUpgradeEnabled3.Value := parts[2]
                case "RaidUpgradeEnabled4": raidUpgradeEnabled4.Value := parts[2]
                case "RaidUpgradeEnabled5": raidUpgradeEnabled5.Value := parts[2]
                case "RaidUpgradeEnabled6": raidUpgradeEnabled6.Value := parts[2]

                case "RaidUpgradeLimitEnabled1": raidUpgradeLimitEnabled1.Value := parts[2]
                case "RaidUpgradeLimitEnabled2": raidUpgradeLimitEnabled2.Value := parts[2]
                case "RaidUpgradeLimitEnabled3": raidUpgradeLimitEnabled3.Value := parts[2]
                case "RaidUpgradeLimitEnabled4": raidUpgradeLimitEnabled4.Value := parts[2]
                case "RaidUpgradeLimitEnabled5": raidUpgradeLimitEnabled5.Value := parts[2]
                case "RaidUpgradeLimitEnabled6": raidUpgradeLimitEnabled6.Value := parts[2]

                case "WinterEnabled1": winterEnabled1.Value := parts[2]
                case "WinterEnabled2": winterEnabled2.Value := parts[2]
                case "WinterEnabled3": winterEnabled3.Value := parts[2]
                case "WinterEnabled4": winterEnabled4.Value := parts[2]
                case "WinterEnabled5": winterEnabled5.Value := parts[2]
                case "WinterEnabled6": winterEnabled6.Value := parts[2]

                case "WinterPlacement1": winterPlacement1.Text := parts[2]
                case "WinterPlacement2": winterPlacement2.Text := parts[2]
                case "WinterPlacement3": winterPlacement3.Text := parts[2]
                case "WinterPlacement4": winterPlacement4.Text := parts[2]
                case "WinterPlacement5": winterPlacement5.Text := parts[2]
                case "WinterPlacement6": winterPlacement6.Text := parts[2]

                case "WinterPriority1": winterPriority1.Text := parts[2]
                case "WinterPriority2": winterPriority2.Text := parts[2]
                case "WinterPriority3": winterPriority3.Text := parts[2]
                case "WinterPriority4": winterPriority4.Text := parts[2]
                case "WinterPriority5": winterPriority5.Text := parts[2]
                case "WinterPriority6": winterPriority6.Text := parts[2]

                case "WinterUpgradeLimit1": winterUpgradeLimit1.Text := parts[2]
                case "WinterUpgradeLimit2": winterUpgradeLimit2.Text := parts[2]
                case "WinterUpgradeLimit3": winterUpgradeLimit3.Text := parts[2]
                case "WinterUpgradeLimit4": winterUpgradeLimit4.Text := parts[2]
                case "WinterUpgradeLimit5": winterUpgradeLimit5.Text := parts[2]
                case "WinterUpgradeLimit6": winterUpgradeLimit6.Text := parts[2]

                case "WinterUpgradeEnabled1": winterUpgradeEnabled1.Value := parts[2]
                case "WinterUpgradeEnabled2": winterUpgradeEnabled2.Value := parts[2]
                case "WinterUpgradeEnabled3": winterUpgradeEnabled3.Value := parts[2]
                case "WinterUpgradeEnabled4": winterUpgradeEnabled4.Value := parts[2]
                case "WinterUpgradeEnabled5": winterUpgradeEnabled5.Value := parts[2]
                case "WinterUpgradeEnabled6": winterUpgradeEnabled6.Value := parts[2]

                case "WinterUpgradeLimitEnabled1": winterUpgradeLimitEnabled1.Value := parts[2]
                case "WinterUpgradeLimitEnabled2": winterUpgradeLimitEnabled2.Value := parts[2]
                case "WinterUpgradeLimitEnabled3": winterUpgradeLimitEnabled3.Value := parts[2]
                case "WinterUpgradeLimitEnabled4": winterUpgradeLimitEnabled4.Value := parts[2]
                case "WinterUpgradeLimitEnabled5": winterUpgradeLimitEnabled5.Value := parts[2]
                case "WinterUpgradeLimitEnabled6": winterUpgradeLimitEnabled6.Value := parts[2]

                case "Speed": PlaceSpeed.Value := parts[2] ; Set the dropdown value
                case "Logic": PlacementPatternDropdown.Value := parts[2] ; Set the dropdown value
                case "Sleep": LobbySleepTimer.Value := parts[2] ; Set the dropdown value
                case "Upgrade": PriorityUpgrade.Value := parts[2] ; Set the checkbox value
                case "Matchmake": MatchMaking.Value := parts[2] ; Set the checkbox value
                case "Challenge": ChallengeBox.Value := parts[2] ; Set the checkbox value
                case "Swap": TeamSwap.Value := parts[2] ; Set the checkbox value
                case "PhyTeam": physicalTeam.Text := parts[2]
                case "MagTeam": magicTeam.Text := parts[2]

                case "FailsafeEnabled": RejoinRoblox.Value := parts[2] ; Set the checkbox value
                case "ToLobby": ReturnLobbyBox.Value := parts[2] ; Set the checkbox value
                case "UseNavigation": StoryUINav.Value := parts[2] ; Set the checkbox value
                case "Upgrade1By1": MaxUpgradeBeforeMoving.Value := parts[2] ; Set the checkbox value

                ;Dungeon settings
                case "StopAfterDefeat": StopAfterDefeat.Value := parts[2] ; Set the checkbox value
                case "SaveChests": SaveChestsBox.Value := parts[2] ; Set the checkbox value
                case "NewSystem": UseNewDungeonRoute.Value := parts[2] ; Set the checkbox value
                case "AutoReject": DenyShrines.Value := parts[2] ; Set the checkbox value

                case "FirstAdapt": FirstAdaptation.Value := parts[2] ; Set the checkbox value
                case "SecondAdapt": SecondAdaptation.Value := parts[2] ; Set the checkbox value
                case "FinalAdapt": FinalAdaptation.Value := parts[2] ; Set the checkbox value
                case "Style": MahoragoMode.Value := parts[2] ; Set the checkbox value

                case "CustomSettings": UseCustomSettings.Value := parts[2] ; Set the checkbox value
            }
        }
        AddToLog("Configuration settings loaded successfully")
        LoadDungeonLocal
        LoadWinterLocal
    } 
}


SaveSettings(*) {
    ; General settings
    global mode, UseCustomSettings

    ; General Unit Settings
    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global PlacementPatternDropdown, LobbySleepTimer

    ; Upgrade limits
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6
    global upgradeLimitEnabled1, upgradeLimitEnabled2, upgradeLimitEnabled3, upgradeLimitEnabled4, upgradeLimitEnabled5, upgradeLimitEnabled6
    global UpgradeLimit1, UpgradeLimit2, UpgradeLimit3, UpgradeLimit4, UpgradeLimit5, UpgradeLimit6

    ; General settings
    global ChallengeBox, PriorityUpgrade, PlaceSpeed, MatchMaking, MaxUpgradeBeforeMoving, RejoinRoblox, ReturnLobbyBox, StoryUINav

    ; Challenge placements
    global ChallengeEnabled1, ChallengeEnabled2, ChallengeEnabled3, ChallengeEnabled4, ChallengeEnabled5, ChallengeEnabled6
    global ChallengePlacement1, ChallengePlacement2, ChallengePlacement3, ChallengePlacement4, ChallengePlacement5, ChallengePlacement6
    global ChallengePriority1, ChallengePriority2, ChallengePriority3, ChallengePriority4, ChallengePriority5, ChallengePriority6
    global challengeUpgradeEnabled1, challengeUpgradeEnabled2, challengeUpgradeEnabled3, challengeUpgradeEnabled4, challengeUpgradeEnabled5, challengeUpgradeEnabled6
    global challengeUpgradeLimitEnabled1, challengeUpgradeLimitEnabled2, challengeUpgradeLimitEnabled3, challengeUpgradeLimitEnabled4, challengeUpgradeLimitEnabled5, challengeUpgradeLimitEnabled6
    global ChallengeUpgradeLimit1, ChallengeUpgradeLimit2, ChallengeUpgradeLimit3, ChallengeUpgradeLimit4, ChallengeUpgradeLimit5, ChallengeUpgradeLimit6

    ; Contract placements
    global ContractEnabled1, ContractEnabled2, ContractEnabled3, ContractEnabled4, ContractEnabled5, ContractEnabled6
    global ContractPlacement1, ContractPlacement2, ContractPlacement3, ContractPlacement4, ContractPlacement5, ContractPlacement6
    global ContractPriority1, ContractPriority2, ContractPriority3, ContractPriority4, ContractPriority5, ContractPriority6
    global contractUpgradeEnabled1, contractUpgradeEnabled2, contractUpgradeEnabled3, contractUpgradeEnabled4, contractUpgradeEnabled5, contractUpgradeEnabled6
    global contractUpgradeLimitEnabled1, contractUpgradeLimitEnabled2, contractUpgradeLimitEnabled3, contractUpgradeLimitEnabled4, contractUpgradeLimitEnabled5, contractUpgradeLimitEnabled6
    global ContractUpgradeLimit1, ContractUpgradeLimit2, ContractUpgradeLimit3, ContractUpgradeLimit4, ContractUpgradeLimit5, ContractUpgradeLimit6

    ; Dungeon placements
    global DungeonEnabled1, DungeonEnabled2, DungeonEnabled3, DungeonEnabled4, DungeonEnabled5, DungeonEnabled6
    global DungeonPlacement1, DungeonPlacement2, DungeonPlacement3, DungeonPlacement4, DungeonPlacement5, DungeonPlacement6
    global DungeonPriority1, DungeonPriority2, DungeonPriority3, DungeonPriority4, DungeonPriority5, DungeonPriority6
    global dungeonUpgradeEnabled1, dungeonUpgradeEnabled2, dungeonUpgradeEnabled3, dungeonUpgradeEnabled4, dungeonUpgradeEnabled5, dungeonUpgradeEnabled6
    global dungeonUpgradeLimitEnabled1, dungeonUpgradeLimitEnabled2, dungeonUpgradeLimitEnabled3, dungeonUpgradeLimitEnabled4, dungeonUpgradeLimitEnabled5, dungeonUpgradeLimitEnabled6
    global DungeonUpgradeLimit1, DungeonUpgradeLimit2, DungeonUpgradeLimit3, DungeonUpgradeLimit4, DungeonUpgradeLimit5, DungeonUpgradeLimit6

    ; Raid placements
    global raidEnabled1, raidEnabled2, raidEnabled3, raidEnabled4, raidEnabled5, raidEnabled6
    global raidPlacement1, raidPlacement2, raidPlacement3, raidPlacement4, raidPlacement5, raidPlacement6
    global raidPriority1, raidPriority2, raidPriority3, raidPriority4, raidPriority5, raidPriority6
    global raidUpgradeEnabled1, raidUpgradeEnabled2, raidUpgradeEnabled3, raidUpgradeEnabled4, raidUpgradeEnabled5, raidUpgradeEnabled6
    global raidUpgradeLimitEnabled1, raidUpgradeLimitEnabled2, raidUpgradeLimitEnabled3, raidUpgradeLimitEnabled4, raidUpgradeLimitEnabled5, raidUpgradeLimitEnabled6
    global raidUpgradeLimit1, raidUpgradeLimit2, raidUpgradeLimit3, raidUpgradeLimit4, raidUpgradeLimit5, raidUpgradeLimit6

    ; Winter placements
    global winterEnabled1, winterEnabled2, winterEnabled3, winterEnabled4, winterEnabled5, winterEnabled6
    global winterPlacement1, winterPlacement2, winterPlacement3, winterPlacement4, winterPlacement5, winterPlacement6
    global winterPriority1, winterPriority2, winterPriority3, winterPriority4, winterPriority5, winterPriority6
    global winterUpgradeEnabled1, winterUpgradeEnabled2, winterUpgradeEnabled3, winterUpgradeEnabled4, winterUpgradeEnabled5, winterUpgradeEnabled6
    global winterUpgradeLimitEnabled1, winterUpgradeLimitEnabled2, winterUpgradeLimitEnabled3, winterUpgradeLimitEnabled4, winterUpgradeLimitEnabled5, winterUpgradeLimitEnabled6
    global winterUpgradeLimit1, winterUpgradeLimit2, winterUpgradeLimit3, winterUpgradeLimit4, winterUpgradeLimit5, winterUpgradeLimit6


    ;Dungeon Settings
    global StopAfterDefeat, DenyShrines, UseNewDungeonRoute, SaveChestsBox

    ; Team settings
    global PhysicalTeam, MagicTeam, TeamSwap

    ;Maharaga
    global FirstAdaptation, SecondAdaptation, FinalAdaptation, MahoragoMode

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
        } else if (mode = "Portal") {
            content .= "Portal=" PortalDropdown.Text
        }
        
        
        ; Save settings for each unit

        ; Create Enabled section
        content .= "`n`n[Enabled]"
        Loop 6 {
            content .= "`nEnabled" A_Index "=" Enabled%A_Index%.Value
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

        ; Create UpgradeEnabled section
        content .= "`n`n[UpgradeEnabled]"
        Loop 6 {
            content .= "`nUpgradeEnabled" A_Index "=" UpgradeEnabled%A_Index%.Value
        }

        ; Create UpgradeLimitEnabled section
        content .= "`n`n[UpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nUpgradeLimitEnabled" A_Index "=" UpgradeLimitEnabled%A_Index%.Value
        }

        ; Create UpgradeLimit section
        content .= "`n`n[UpgradeLimit]"
        Loop 6 {
            content .= "`nUpgradeLimit" A_Index "=" UpgradeLimit%A_Index%.Text
        }

        ; Create ChallengeEnabled section
        content .= "`n`n[ChallengeEnabled]"
        Loop 6 {
            content .= "`nChallengeEnabled" A_Index "=" ChallengeEnabled%A_Index%.Value
        }

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

        ; Create ChallengeUpgradeEnabled section
        content .= "`n`n[ChallengeUpgradeEnabled]"
        Loop 6 {
            content .= "`nChallengeUpgradeEnabled" A_Index "=" challengeUpgradeEnabled%A_Index%.Value
        }

        ; Create ChallengeUpgradeLimitEnabled section
        content .= "`n`n[ChallengeUpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nChallengeUpgradeLimitEnabled" A_Index "=" challengeUpgradeLimitEnabled%A_Index%.Value
        }

        ; Create ChallengeUpgradeLimit section
        content .= "`n`n[ChallengeUpgradeLimit]"
        Loop 6 {
            content .= "`nChallengeUpgradeLimit" A_Index "=" ChallengeUpgradeLimit%A_Index%.Text
        }

        ; Create ContractEnabled section
        content .= "`n`n[ContractEnabled]"
        Loop 6 {
            content .= "`nContractEnabled" A_Index "=" ContractEnabled%A_Index%.Value
        }

        ; Create ContractPlacement section
        content .= "`n`n[ContractPlacement]"
        Loop 6 {
            content .= "`nContractPlacement" A_Index "=" ContractPlacement%A_Index%.Text
        }

        ; Create ContractPriority section
        content .= "`n`n[ContractPriority]"
        Loop 6 {
            content .= "`nContractPriority" A_Index "=" ContractPriority%A_Index%.Text
        }

        ; Create ContractUpgradeEnabled section
        content .= "`n`n[ContractUpgradeEnabled]"
        Loop 6 {
            content .= "`nContractUpgradeEnabled" A_Index "=" contractUpgradeEnabled%A_Index%.Value
        }

        ; Create ContractUpgradeLimitEnabled section
        content .= "`n`n[ContractUpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nContractUpgradeLimitEnabled" A_Index "=" contractUpgradeLimitEnabled%A_Index%.Value
        }

        ; Create ContractUpgradeLimit section
        content .= "`n`n[ContractUpgradeLimit]"
        Loop 6 {
            content .= "`nContractUpgradeLimit" A_Index "=" ContractUpgradeLimit%A_Index%.Text
        }

        ; Create DungeonEnabled section
        content .= "`n`n[DungeonEnabled]"
        Loop 6 {
            content .= "`nDungeonEnabled" A_Index "=" DungeonEnabled%A_Index%.Value
        }

        ; Create DungeonPlacement section
        content .= "`n`n[DungeonPlacement]"
        Loop 6 {
            content .= "`nDungeonPlacement" A_Index "=" DungeonPlacement%A_Index%.Text
        }

        ; Create DungeonPriority section
        content .= "`n`n[DungeonPriority]"
        Loop 6 {
            content .= "`nDungeonPriority" A_Index "=" DungeonPriority%A_Index%.Text
        }

        ; Create DungeonUpgradeEnabled section
        content .= "`n`n[DungeonUpgradeEnabled]"
        Loop 6 {
            content .= "`nDungeonUpgradeEnabled" A_Index "=" dungeonUpgradeEnabled%A_Index%.Value
        }

        ; Create DungeonUpgradeLimitEnabled section
        content .= "`n`n[DungeonUpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nDungeonUpgradeLimitEnabled" A_Index "=" dungeonUpgradeLimitEnabled%A_Index%.Value
        }

        ; Create DungeonUpgradeLimit section
        content .= "`n`n[DungeonUpgradeLimit]"
        Loop 6 {
            content .= "`nDungeonUpgradeLimit" A_Index "=" DungeonUpgradeLimit%A_Index%.Text
        }

        ; Create RaidEnabled section
        content .= "`n`n[RaidEnabled]"
        Loop 6 {
            content .= "`nRaidEnabled" A_Index "=" raidEnabled%A_Index%.Value
        }

        ; Create RaidPlacement section
        content .= "`n`n[RaidPlacement]"
        Loop 6 {
            content .= "`nRaidPlacement" A_Index "=" raidPlacement%A_Index%.Text
        }

        ; Create RaidPriority section
        content .= "`n`n[RaidPriority]"
        Loop 6 {
            content .= "`nRaidPriority" A_Index "=" raidPriority%A_Index%.Text
        }

        ; Create RaidUpgradeEnabled section
        content .= "`n`n[RaidUpgradeEnabled]"
        Loop 6 {
            content .= "`nRaidUpgradeEnabled" A_Index "=" RaidUpgradeEnabled%A_Index%.Value
        }

        ; Create RaidUpgradeLimitEnabled section
        content .= "`n`n[RaidUpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nRaidUpgradeLimitEnabled" A_Index "=" RaidUpgradeLimitEnabled%A_Index%.Value
        }

        ; Create RaidUpgradeLimit section
        content .= "`n`n[RaidUpgradeLimit]"
        Loop 6 {
            content .= "`nRaidUpgradeLimit" A_Index "=" RaidUpgradeLimit%A_Index%.Text
        }

        ; Create WinterEnabled section
        content .= "`n`n[WinterEnabled]"
        Loop 6 {
            content .= "`nWinterEnabled" A_Index "=" winterEnabled%A_Index%.Value
        }

        ; Create WinterPlacement section
        content .= "`n`n[WinterPlacement]"
        Loop 6 {
            content .= "`nWinterPlacement" A_Index "=" winterPlacement%A_Index%.Text
        }

        ; Create WinterPriority section
        content .= "`n`n[WinterPriority]"
        Loop 6 {
            content .= "`nWinterPriority" A_Index "=" winterPriority%A_Index%.Text
        }

        ; Create WinterUpgradeEnabled section
        content .= "`n`n[WinterUpgradeEnabled]"
        Loop 6 {
            content .= "`nWinterUpgradeEnabled" A_Index "=" WinterUpgradeEnabled%A_Index%.Value
        }

        ; Create WinterUpgradeLimitEnabled section
        content .= "`n`n[WinterUpgradeLimitEnabled]"
        Loop 6 {
            content .= "`nWinterUpgradeLimitEnabled" A_Index "=" WinterUpgradeLimitEnabled%A_Index%.Value
        }

        ; Create WinterUpgradeLimit section
        content .= "`n`n[WinterUpgradeLimit]"
        Loop 6 {
            content .= "`nWinterUpgradeLimit" A_Index "=" WinterUpgradeLimit%A_Index%.Text
        }

        content .= "`n`n[PlacementLogic]"
        content .= "`nLogic=" PlacementPatternDropdown.Value "`n"

        content .= "`n[PlaceSpeed]"
        content .= "`nSpeed=" PlaceSpeed.Value "`n"

        content .= "`n[SleepTimer]"
        content .= "`nSleep=" LobbySleepTimer.Value "`n"

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

        content .= "`n[Dungeons]"
        content .= "`nStopAfterDefeat=" StopAfterDefeat.Value "`n"
        content .= "`nAutoReject=" DenyShrines.Value "`n"
        content .= "`nSaveChests=" SaveChestsBox.Value "`n"
        content .= "`nNewSystem=" UseNewDungeonRoute.Value "`n"

        content .= "`n[RejoinFailsafe]"
        content .= "`nFailsafeEnabled=" RejoinRoblox.Value "`n"

        content .= "`n[ReturnToLobby]"
        content .= "`nToLobby=" ReturnLobbyBox.Value "`n"

        content .= "`n[UINavigation]"
        content .= "`nUseNavigation=" StoryUINav.Value "`n"

        content .= "`n[UpgradeTesting]"
        content .= "`nUpgrade1By1=" MaxUpgradeBeforeMoving.Value "`n"

        content .= "`n[FirstAdaptation]"
        content .= "`nFirstAdapt=" FirstAdaptation.Value "`n"

        content .= "`n[SecondAdaptation]"
        content .= "`nSecondAdapt=" SecondAdaptation.Value "`n"

        content .= "`n[FinalAdaptation]"
        content .= "`nFinalAdapt=" FinalAdaptation.Value "`n"

        content .= "`n[MahoragoMode]"
        content .= "`nStyle=" MahoragoMode.Value "`n"

        content .= "`n[UseCustomSettings]"
        content .= "`nCustomSettings=" UseCustomSettings.Value "`n"

        FileAppend(content, settingsFile)
        AddToLog("Configuration settings saved successfully")
        SaveWinterLocal()
        SaveDungeonLocal()
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