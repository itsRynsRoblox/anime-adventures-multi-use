#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount
global contractPageCounter := 0
global contractSwitchPattern := 0
global BossRoomCompleted := false
global SaveChestsForBoss := true

LoadKeybindSettings()  ; Load saved keybinds
CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {

}

F6:: {

}

StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}

PlacingUnits() {
    CheckForCardSelection()
    global successfulCoordinates, maxedCoordinates, inChallengeMode
    successfulCoordinates := []
    maxedCoordinates := []
    placedCounts := Map()  

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        AddToLog("No units enabled - skipping to monitoring")
        return MonitorStage()
    }

    if CheckForXp() || CheckForReturnToLobby() || CheckForNextText() {
        AddToLog("Stage ended during placements, proceeding to results")
        return MonitorStage()
    }

    if (CheckForRobloxApp()) {
        AddToLog("Found Roblox App, rejoining private server...")
        return RejoinPrivateServer()
    }

    if CheckForLobbyText() {
        return CheckLobby()
    }

    if CheckForDisconnect() {
        return Reconnect()
    }

    placementPoints := PlacementPatternDropdown.Text = "3x3 Grid" ? GenerateMoreGridPoints(3) : PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() : PlacementPatternDropdown.Text = "Spiral(WIP)" ? GenerateSpiralGridPoints() : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()
    
    ; Go through each slot
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        
        ; Get number of placements wanted for this slot
        placements := inChallengeMode && ChallengeBox.Value ? "challengeplacement" slotNum : "placement" slotNum
        placements := %placements%
        placements := Integer(placements.Text)
        
        ; Initialize count if not exists
        if !placedCounts.Has(slotNum)
            placedCounts[slotNum] := 0
        
        ; If enabled, place all units for this slot
        if (enabled && placements > 0) {
            AddToLog("Placing Unit " slotNum " (0/" placements ")")
            CheckForCardSelection()
            ; Place all units for this slot
            while (placedCounts[slotNum] < placements) {
                for point in placementPoints {
                    ; Skip if this coordinate was already used successfully
                    alreadyUsed := false
                    for coord in successfulCoordinates {
                        if (coord.x = point.x && coord.y = point.y) {
                            alreadyUsed := true
                            break
                        }
                    }
                    for coord in maxedCoordinates { ; NEW CHECK
                        if (coord.x = point.x && coord.y = point.y) {
                            alreadyUsed := true
                            break
                        }
                    }
                    if (alreadyUsed)
                        continue
                    if PlaceUnit(point.x, point.y, slotNum) {
                        CheckForCardSelection()
                        successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                        placedCounts[slotNum] += 1
                        AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                        CheckAbility()
                        FixClick(560, 560) ; Move Click
                        AttemptUpgrade()
                        break
                    }
                        AttemptUpgrade()

                    if CheckForXp() || CheckForReturnToLobby() || CheckForNextText() {
                        AddToLog("Stage ended during placements, proceeding to results")
                        return MonitorStage()
                    }

                    if (CheckForRobloxApp()) {
                        AddToLog("Found Roblox App, rejoining private server...")
                        return RejoinPrivateServer()
                    }

                    if CheckForLobbyText() {
                        return CheckLobby()
                    }

                    if CheckForDisconnect() {
                        return Reconnect()
                    }

                    CheckEndAndRoute()
                }
                Sleep(500)
            }
            CheckForCardSelection()
        }
    }
    
    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}

AttemptUpgrade() {
    global successfulCoordinates, maxedCoordinates, PriorityUpgrade, debugMessages, inChallengeMode

    if (successfulCoordinates.Length = 0) {
        return ; No units placed yet
    } else {
        AddToLog("Attempting to upgrade placed units...")
    }

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "upgradeEnabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        if (debugMessages) {
            AddToLog("No units enabled - skipping")
        }
        return
    }

    if (PriorityUpgrade.Value) {
        if (debugMessages) {
            AddToLog("Using priority-based upgrading")
        }

        ; Loop through priority levels (1-6) and upgrade all matching units
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            upgradedThisRound := false

            for index, coord in successfulCoordinates { 
                ; Check if upgrading is enabled for this unit's slot
                upgradeEnabled := "upgradeEnabled" coord.slot
                upgradeEnabled := %upgradeEnabled%

                if (!upgradeEnabled.Value) {
                    if (debugMessages) {
                        AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                    }
                    continue
                }

                ; Get the priority value for this unit's slot
                priority := inChallengeMode && ChallengeBox.Value ? "challengepriority" coord.slot : "priority" coord.slot
                priority := %priority%

                upgradeLimitEnabled := "upgradeLimitEnabled" coord.slot
                upgradeLimitEnabled := %upgradeLimitEnabled%

                upgradeLimit := "UpgradeLimit" coord.slot
                upgradeLimit := %upgradeLimit%
                upgradeLimit := String(upgradeLimit.Text)

                
                if (priority.Text = priorityNum) {
                    if (debugMessages) {
                        AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
                    }

                    if (!upgradeLimitEnabled.Value) {
                        UpgradeUnit(coord.x, coord.y)
                    } else {
                        UpgradeUnitLimit(coord.x, coord.y, coord, index, upgradeLimit)
                    }

                    if CheckForXp() || CheckForReturnToLobby() || CheckForNextText() {
                        AddToLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        maxedCoordinates := []
                        return MonitorStage()
                    }

                    if (CheckForRobloxApp()) {
                        AddToLog("Found Roblox App, rejoining private server...")
                        return RejoinPrivateServer()
                    }

                    if CheckForLobbyText() {
                        return CheckLobby()
                    }

                    if CheckForDisconnect() {
                        return Reconnect()
                    }

                    if MaxUpgrade() {
                        AddToLog("Max upgrade reached for Unit " coord.slot)
                        successfulCoordinates.RemoveAt(index)
                        maxedCoordinates.Push(coord)
                        FixClick(325, 185) ; Close upgrade menu
                        continue
                    }

                    Sleep(200)
                    CheckAbility()
                    FixClick(560, 560) ; Move Click
                    CheckForCardSelection()
                    Reconnect()
                    CheckEndAndRoute()

                    upgradedThisRound := true
                }
            }

            if upgradedThisRound {
                Sleep(300) ; Add a slight delay between batches
            }
        }
    } else {
        ; Normal (non-priority) upgrading - upgrade all available units
        for index, coord in successfulCoordinates {
            ; Check if upgrading is enabled for this unit's slot
            upgradeEnabled := "upgradeEnabled" coord.slot
            upgradeEnabled := %upgradeEnabled%

            upgradeLimitEnabled := "upgradeLimitEnabled" coord.slot
            upgradeLimitEnabled := %upgradeLimitEnabled%

            upgradeLimit := "UpgradeLimit" coord.slot
            upgradeLimit := %upgradeLimit%
            upgradeLimit := String(upgradeLimit.Text)

            if (!upgradeEnabled.Value) {
                if (debugMessages) {
                    AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                }
                continue
            }

            if (debugMessages) {
                AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
            }

            if (!upgradeLimitEnabled.Value) {
                UpgradeUnit(coord.x, coord.y)
            } else {
                UpgradeUnitLimit(coord.x, coord.y, coord, index, upgradeLimit)
            }

            if CheckForXp() || CheckForReturnToLobby() || CheckForNextText() {
                AddToLog("Stage ended during upgrades, proceeding to results")
                successfulCoordinates := []
                maxedCoordinates := []
                return MonitorStage()
            }

            if (CheckForRobloxApp()) {
                AddToLog("Found Roblox App, rejoining private server...")
                return RejoinPrivateServer()
            }

            if CheckForLobbyText() {
                return CheckLobby()
            }

            if CheckForDisconnect() {
                return Reconnect()
            }

            if MaxUpgrade() {
                AddToLog("Max upgrade reached for Unit " coord.slot)
                successfulCoordinates.RemoveAt(index)
                maxedCoordinates.Push(coord)
                FixClick(325, 185) ; Close upgrade menu
                continue
            }

            Sleep(200)
            CheckAbility()
            FixClick(560, 560) ; Move Click
            CheckForCardSelection()
            Reconnect()
            CheckEndAndRoute()
        }
    }
    if (debugMessages) {
        AddToLog("Upgrade attempt completed")
    }
}

SetUnitAsMaxed(coord, index) {
    global successfulCoordinates, maxedCoordinates
    AddToLog("Max upgrade reached for Unit " coord.slot)
    successfulCoordinates.RemoveAt(index)
    maxedCoordinates.Push(coord)
    FixClick(325, 185) ; Close upgrade menu
}


UpgradeUnits() {
    global successfulCoordinates, maxedCoordinates, PriorityUpgrade, inChallengeMode

    local totalUnits := Map()  ; Initialize as a local variable
    local upgradedCount := Map()  ; Initialize as a local variable

    ; Initialize counters
    for coord in successfulCoordinates {
        totalUnits[coord.slot] := (totalUnits.Has(coord.slot) ? totalUnits[coord.slot] + 1 : 1)
        upgradedCount[coord.slot] := upgradedCount.Has(coord.slot) ? upgradedCount[coord.slot] : 0
    }

    AddToLog("Initiating Unit Upgrades...")

    if (PriorityUpgrade.Value) {
        AddToLog("Using priority upgrade system")
        ; Go through each priority level (1-6)
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            for slot in [1, 2, 3, 4, 5, 6] {
                priority := inChallengeMode && ChallengeBox.Value ? "challengepriority" slot : "priority" slot
                priority := %priority%

                if (priority.Text = priorityNum && HasUnitsInSlot(slot, successfulCoordinates)) {
                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    UpgradeSlot(slot, priorityNum, totalUnits, upgradedCount)
                }
            }
        }
        AddToLog("Priority upgrading completed")
    } else {
        ; Normal upgrade (no priority)
        while (successfulCoordinates.Length > 0) {
            UpgradeAllUnits(totalUnits, upgradedCount)
        }
        AddToLog("All units maxed, proceeding to monitor stage")
    }

    return MonitorStage()
}

HasUnitsInSlot(slot, coordinates) {
    for coord in coordinates {
        if (coord.slot = slot) {
            return true
        }
    }
    return false
}

UpgradeSlot(slot, priorityNum, totalUnits, upgradedCount) {
    while (true) {
        slotDone := true

        for index, coord in successfulCoordinates {
            if (coord.slot = slot) {
                slotDone := false

                ; If upgradeOneAtATime is true, only upgrade one unit
                if (MaxUpgradeBeforeMoving.Value) {
                    UpgradeUnitWithLimit(coord, index)

                    CheckForTerminationConditions()

                    if (MaxUpgrade()) {
                        HandleMaxUpgrade(coord, index, totalUnits, upgradedCount)
                        break
                    }

                    Sleep(200)
                    PostUpgradeChecks()

                    ; After upgrading one unit, exit the loop to prevent further upgrades
                    break
                } else {
                    ; Perform the upgrade as usual for multiple units
                    UpgradeUnitWithLimit(coord, index)

                    CheckForTerminationConditions()

                    if (MaxUpgrade()) {
                        HandleMaxUpgrade(coord, index, totalUnits, upgradedCount)
                        break
                    }

                    Sleep(200)
                    PostUpgradeChecks()
                }
            }
        }

        if (slotDone || successfulCoordinates.Length = 0) {
            AddToLog("Finished upgrades for priority " priorityNum)
            break
        }
    }
}

UpgradeAllUnits(totalUnits, upgradedCount) {
    for index, coord in successfulCoordinates {
        UpgradeUnitWithLimit(coord, index)

        if (CheckForDisconnect()) {
            return Reconnect()
        }

        if (CheckForRobloxApp()) {
            AddToLog("Found Roblox App, rejoining private server...")
            return RejoinPrivateServer()
        }

        CheckForTerminationConditions()

        if (MaxUpgrade()) {
            HandleMaxUpgrade(coord, index, totalUnits, upgradedCount)
            continue
        }

        Sleep(200)
        PostUpgradeChecks()
    }
}

UpgradeUnitWithLimit(coord, index) {
    upgradeLimitEnabled := "upgradeLimitEnabled" coord.slot
    upgradeLimitEnabled := %upgradeLimitEnabled%

    upgradeLimit := "UpgradeLimit" coord.slot
    upgradeLimit := %upgradeLimit%
    upgradeLimit := String(upgradeLimit.Text)

    if (!upgradeLimitEnabled.Value) {
        UpgradeUnit(coord.x, coord.y)
    } else {
        UpgradeUnitLimit(coord.x, coord.y, coord, index, upgradeLimit)
    }
}

CheckForTerminationConditions() {
    if (CheckForXp() || CheckForReturnToLobby() || CheckForNextText()) {
        AddToLog("Stage ended during upgrades, proceeding to results")
        successfulCoordinates := []
        maxedCoordinates := []
        return MonitorStage()
    }
    if (CheckForRobloxApp()) {
        AddToLog("Found Roblox App, rejoining private server...")
        return RejoinPrivateServer()
    }
    if (CheckForLobbyText()) {
        return CheckLobby()
    }
}

HandleMaxUpgrade(coord, index, totalUnits, upgradedCount) {
    upgradedCount[coord.slot]++
    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
    successfulCoordinates.RemoveAt(index)
    FixClick(325, 185) ; Close upgrade menu
}

PostUpgradeChecks() {
    CheckAbility()
    FixClick(560, 560) ; Move Click
    CheckForCardSelection()
    Reconnect()
    CheckEndAndRoute()
}

ChallengeMode() {    
    AddToLog("Moving to Challenge mode")
    ChallengeMovement()

    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        ChallengeMovement()
    }

    RestartStage()
}

StoryMode() {
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }
    AddToLog("Starting " currentStoryMap " - " currentStoryAct)
    
    if (StoryUINav.Value) {
        StartStory(currentStoryMap, currentStoryAct)
    } else {
        StartStoryNoUINavigation(currentStoryMap, currentStoryAct)
    }

    ; Handle play mode selection
    if (StoryActDropdown.Text != "Infinity") {
        PlayHere()  ; Always PlayHere for normal story acts
    } else {
        if (MatchMaking.Value) {
            FindMatch()
        } else {
            PlayHere()
        }
    }

    RestartStage()
}


LegendMode() {
    global LegendDropdown, LegendActDropdown
    
    ; Get current map and act
    currentLegendMap := LegendDropdown.Text
    currentLegendAct := LegendActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }
    AddToLog("Starting " currentLegendMap " - " currentLegendAct)
    if (StoryUINav.Value) {
        StartLegend(currentLegendMap, currentLegendAct)
    } else {
        StartLegendNoUINavigation(currentLegendMap, currentLegendAct)
    }

    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere()
    }

    RestartStage()
}

RaidMode() {
    global RaidDropdown, RaidActDropdown
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)
    RaidMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        RaidMovement()
    }
    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    if (StoryUINav.Value) {
        StartRaid(currentRaidMap, currentRaidAct)
    } else {
        StartRaidNoUINavigation(currentRaidMap, currentRaidAct)
    }
    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere()
    }

    RestartStage()
}

InfinityCastleMode() {
    global InfinityCastleDropdown
    
    ; Get current difficulty
    currentDifficulty := InfinityCastleDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for Infinity Castle")
    InfCastleMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        InfCastleMovement()
    }
    AddToLog("Starting Infinity Castle - " currentDifficulty)

    ; Select difficulty with direct clicks
    if (currentDifficulty = "Normal") {
        FixClick(418, 375)  ; Click Easy Mode
    } else {
        FixClick(485, 375)  ; Click Hard Mode
    }
    
    ;Start Inf Castle
    if (ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        ClickUntilGone(0, 0, 325, 520, 489, 587, ModeCancel, -10, -120)
    }

    RestartStage()
}

WinterEvent() {
    ; Execute the movement pattern
    AddToLog("Moving to position for Winter Event")
    WinterEventMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 468-150000, 386-150000, 468+150000, 386+150000, 0, 0, JoinMatchmaking)) {
        Reconnect() ; Added Disconnect Check
        WinterEventMovement()
    }

    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere()
    }

    AddToLog("Starting Winter Event")
    RestartStage()
}

CursedWombMode() {
    AddToLog("Moving to Cursed womb")
    CursedWombMovement()

    while !(ok := FindText(&X, &Y, 445, 440, 650, 487, 0, 0, Capacity)) {
        Reconnect() ; Added Disconnect Check
        if (ok := FindText(&X, &Y, 434-150000, 383-150000, 434+150000, 383+150000, 0, 0, RobuxPurchaseKey)) {
            AddToLog("Found Key Purchase Attempt")
            Sleep 50000
        }
        CursedWombMovement()
    }

    FixClick(500, 190)
    for char in StrSplit("Key (Cursed Womb)") {
    Send char
    Sleep (100)
    } 
    sleep (1000)
    FixClick(215, 285)
    sleep (500)
    FixClick(345, 370)
    sleep (500)
    
    RestartStage()
}

ContractMode() {
   Sleep(2500)
   FixClick(33, 400)
   Sleep(2500)
   HandleContractJoin()
   Sleep(2500)
   RestartStage()
}

PortalMode() {
    HandlePortalJoin()
    Sleep(2500)
    RestartStage()
}

DungeonMode() {
    AddToLog("Entering Dungeon Mode")
    FixClick(85, 400)  ; Click Dungeon mode button
    Sleep(1000)
    if (ok := FindText(&X, &Y, 310, 395, 495, 440, 0.20, 0.20, EnterDungeon)) {
        FixClick(395,380)
    }
    Sleep(1000)
    ; Select dungeon route and enter
    SelectDungeonRoute()
}

CheckForReturnToLobby() {
    if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {
        return true
    }
    return false
}

CheckForNextText() {
    if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
        return true
    }
    return false
}

MonitorEndScreen() {
    global mode, StoryDropdown, StoryActDropdown, ReturnLobbyBox, MatchMaking, challengeStartTime, inChallengeMode

    Loop {
        Sleep(3000)  
        
        FixClick(560, 560)
        FixClick(560, 560)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
            ClickUntilGone(0, 0, 260, 400, 390, 450, NextText, 0, -40)
        }

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {
            AddToLog("Found Lobby Text - Current Mode: " (inChallengeMode ? "Challenge" : mode))
            Sleep(2000)

            ; Challenge mode logic first
            if (inChallengeMode) {
                 AddToLog("Challenge completed - returning to " mode " mode")
                inChallengeMode := false
                challengeStartTime := A_TickCount
                ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                return CheckLobby()
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && ChallengeBox.Value) {
                timeElapsed := A_TickCount - challengeStartTime
                if (timeElapsed >= 1800000) {
                    AddToLog("30 minutes passed - switching to Challenge mode")
                    inChallengeMode := true
                    challengeStartTime := A_TickCount
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                    return CheckLobby()
                }
            }


            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (StoryActDropdown.Text != "Infinity") {
                    if (NextLevelBox.Value && lastResult = "win") {
                        AddToLog("Next level")
                        ClickNextLevel()
                    } else {
                        AddToLog("Replay level")
                        ClickReplay()
                    }
                } else {
                    if (StoryDropdown.Text = "Shibuya District") {
                        if (ShibuyaSwap.Value) {
                            ModeDropdown.Text := "Portal"
                            PortalDropdown.Text := "Shibuya Portal"
                            PortalJoinDropdown.Text := "Solo"
                            AddToLog("Returning to lobby, attempting to do Shibuya Portal...")
                            ClickReturnToLobby()
                            return CheckLobby()
                        } else {
                            if (ReturnLobbyBox.Value) {
                                AddToLog("Return to lobby")
                                ClickReturnToLobby()
                            } else {
                                AddToLog("Story Infinity replay")
                                ClickReplay()
                            }
                        }
                    } else {
                        if (ReturnLobbyBox.Value) {
                            AddToLog("Return to lobby")
                            ClickReturnToLobby()
                        } else {
                            AddToLog("Story Infinity replay")
                            ClickReplay()
                        }
                    }
                }
                return RestartStage()
            }
            else if (mode = "Raid") {
                AddToLog("Handling Raid end")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby")
                    ClickReturnToLobby()
                    return CheckLobby()
                } else {
                    AddToLog("Replay raid")
                    ClickReplay()
                    return RestartStage()
                }
            }
            else if (mode = "Dungeon") {
                AddToLog("Handling Dungeon end")
                return MonitorDungeonEnd()
            }
            else if (mode = "Infinity Castle") {
                AddToLog("Handling Infinity Castle end")
                if (lastResult = "win") {
                    AddToLog("Next floor")
                    ClickReplay() ; Uses the replay coords for next level
                } else {
                    AddToLog("Restart floor")
                    ClickReplay()
                }
                return RestartStage()
            }
            else if (mode = "Cursed Womb") {
                AddToLog("Handling Cursed Womb End")
                AddToLog("Returning to lobby")
                ClickReturnToLobby()
                return CheckLobby()
            }
            else if (mode = "Winter Event") {
                AddToLog("Handling Winter Event end")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby enabled")
                    ClickReturnToLobby()
                    return CheckLobby()
                } else {
                    AddToLog("Replaying")
                    ClickReplay()
                }
                return RestartStage()
            }
            else {
                AddToLog("Handling end case")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby enabled")
                    ClickReturnToLobby()
                    return CheckLobby()
                } else {
                    AddToLog("Replaying")
                    ClickReplay()
                    return RestartStage()
                }
            }
        }
        Reconnect()
    }
}


MonitorStage() {
global mode, StoryActDropdown

    lastClickTime := A_TickCount
    
    Loop {
        Sleep(1000)
        
        timeElapsed := A_TickCount - lastClickTime
        if (timeElapsed >= 20000) {
            AddToLog("Performing anti-AFK click")
            FixClick(560, 560)
            lastClickTime := A_TickCount
        }

        if (mode = "Winter Event") {
            CheckForCardSelection()
        }

        if CheckForDisconnect() {
            return Reconnect()
        }

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if CheckForXp(true) {
            HandleStageEnd()
        }
        CheckEndAndRoute()
        Reconnect()
    }
}

PerformAntiAFK(lastClickTime) {
    if (A_TickCount - lastClickTime >= 60000) {
        AddToLog("Performing anti-AFK click")
        Loop 3 {
            FixClick(560, 560)
        }
        return A_TickCount ; Return the updated lastClickTime
    }
}

HandleStageEnd() {
    global Wins, loss, stageStartTime

    isWin := false

    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
        ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
    }

    if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText) or (ok:=FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText2))) {
        isWin := false
    }

    if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, VictoryText) or (ok:=FindText(&X, &Y, 150, 180, 350, 260, 0, 0, VictoryText2))) {
        isWin := true
    }

    if isWin {
        AddToLog("Victory detected - Stage Length: " stageLength)
        Wins += 1
    } else {
        AddToLog("Defeat detected - Stage Length: " stageLength)
        loss += 1
    }

    SendWebhookWithTime(isWin, stageLength)

    if (mode = "Portal") {
        return HandlePortalEnd()            
    } else if (mode = "Contract") {
        return HandleContractEnd() 
    } else if (mode = "Dungeon") {
        return MonitorDungeonEnd()
    } else {
        return MonitorEndScreen() 
    }
}

StoryMovement() {
    FixClick(85, 295)
    sleep (1000)
    SendInput ("{w down}")
    Sleep(300)
    SendInput ("{w up}")
    Sleep(300)
    SendInput ("{d down}")
    SendInput ("{w down}")
    Sleep(4500)
    SendInput ("{d up}")
    SendInput ("{w up}")
    Sleep(500)
}

ChallengeMovement() {
    FixClick(765, 475)
    Sleep (500)
    FixClick(300, 415)
    SendInput ("{a down}")
    sleep (7000)
    SendInput ("{a up}")
}

RaidMovement() {
    FixClick(765, 475) ; Click Area
    Sleep(300)
    FixClick(495, 410)
    Sleep(500)
    SendInput ("{a down}")
    Sleep(400)
    SendInput ("{a up}")
    Sleep(500)
    SendInput ("{w down}")
    Sleep(5000)
    SendInput ("{w up}")
}

InfCastleMovement() {
    FixClick(765, 475)
    Sleep (300)
    FixClick(370, 330)
    Sleep (500)
    SendInput ("{w down}")
    Sleep (500)
    SendInput ("{w up}")
    Sleep (500)
    SendInput ("{a down}")
    sleep (4000)
    SendInput ("{a up}")
    Sleep (500)
}

CursedWombMovement() {
    FixClick(85, 295)
    Sleep (500)
    SendInput ("{a down}")
    sleep (3000)
    SendInput ("{a up}")
    sleep (1000)
    SendInput ("{s down}")
    sleep (4000)
    SendInput ("{s up}")
}

WinterEventMovement() {
    FixClick(592, 204) ; Close Matchmaking UI (Just in case)
    Sleep (200)
    FixClick(85, 295) ; Click Play
    sleep (1000)
    SendInput ("{a up}")
    Sleep 100
    SendInput ("{a down}")
    Sleep 6000
    SendInput ("{a up}")
    KeyWait "a" ; Wait for "d" to be fully processed
    Sleep 1200
}

StartStory(map, StoryActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    downArrows := GetStoryDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    Loop 4 {
        SendInput("{Up}") ; Makes sure it selects act
        Sleep(200)
    }

    SendInput("{Left}") ; Go to act selection
    Sleep(1000)
    
    actArrows := GetStoryActDownArrows(StoryActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartStoryNoUINavigation(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    if (CheckForNotification()) {
        ClickUntilGone(0, 0, 748, 94, 778, 551, ExitNotification, -3, -30)
        Sleep (1000)
    }

    ; Get Story map 
    StoryMap := GetMapData("StoryMap", map)
    
    ; Scroll if needed
    if (StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(700, 210)
        loop StoryMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetMapData("StoryAct", act)
    
    ; Scroll if needed for act
    if (StoryAct.scrolls > 0) {
        AddToLog("Scrolling down " StoryAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop StoryAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(StoryAct.x, StoryAct.y)
    Sleep(1000)
    
    return true
}

GetMapData(type, name) {
    data := Map(
        "StoryMap", Map(
            "Planet Greenie", {x: 630, y: 250, scrolls: 0},
            "Walled City", {x: 630, y: 300, scrolls: 0},
            "Snowy Town", {x: 630, y: 350, scrolls: 0},
            "Sand Village", {x: 630, y: 400, scrolls: 0},

            "Navy Bay", {x: 630, y: 325, scrolls: 1},
            "Fiend City", {x: 630, y: 375, scrolls: 1},
            "Spirit World", {x: 630, y: 425, scrolls: 1},

            "Ant Kingdom", {x: 630, y: 340, scrolls: 2},
            "Magic Town", {x: 630, y: 375, scrolls: 2},

            "Haunted Academy", {x: 630, y: 310, scrolls: 3},
            "Magic Hills", {x: 630, y: 360, scrolls: 3},
            "Space Center", {x: 630, y: 410, scrolls: 3},

            "Alien Spaceship", {x: 630, y: 325, scrolls: 4},
            "Fabled Kingdom", {x: 630, y: 375, scrolls: 4},
            "Space Center", {x: 630, y: 435, scrolls: 4},

            "Puppet Island", {x: 630, y: 350, scrolls: 5},
            "Virtual Dungeon", {x: 630, y: 400, scrolls: 5},

            "Snowy Kingdom", {x: 630, y: 315, scrolls: 6},
            "Dungeon Throne", {x: 630, y: 365, scrolls: 6},
            "Mountain Temple", {x: 630, y: 415, scrolls: 6},

            "Rain Village", {x: 630, y: 335, scrolls: 7},
            "Shibuya District", {x: 630, y: 385, scrolls: 7}
        ),
        "StoryAct", Map(
            "Infinity", {x: 285, y: 235, scrolls: 0},
            "Act 1", {x: 285, y: 270, scrolls: 0},
            "Act 2", {x: 285, y: 305, scrolls: 0},
            "Act 3", {x: 285, y: 340, scrolls: 0},
            "Act 4", {x: 285, y: 385, scrolls: 0},

            "Act 5", {x: 300, y: 350, scrolls: 1},
            "Act 6", {x: 300, y: 385, scrolls: 1}
        ),
        "RaidMap", Map(
            "Ant Kingdom", {x: 630, y: 250, scrolls: 0},
            "Sacred Planet", {x: 630, y: 300, scrolls: 0},
            "Strange Town", {x: 630, y: 350, scrolls: 0},
            "Ruined City", {x: 630, y: 400, scrolls: 0},
            "Cursed Festival", {x: 630, y: 325, scrolls: 1},
        ),
        "RaidAct", Map(
            "Act 1", {x: 285, y: 235, scrolls: 0},
            "Act 2", {x: 285, y: 270, scrolls: 0},
            "Act 3", {x: 285, y: 305, scrolls: 0},
            "Act 4", {x: 285, y: 340, scrolls: 0},
            "Act 5", {x: 285, y: 375, scrolls: 0}
        ),
        "LegendMap", Map(
            "Magic Hills", {x: 630, y: 240, scrolls: 0},
            "Spirit Invasion", {x: 630, y: 290, scrolls: 0},
            "Space Center", {x: 630, y: 340, scrolls: 0},
            "Fabled Kingdom", {x: 630, y: 390, scrolls: 0},
            "Ruined City", {x: 630, y: 440, scrolls: 0},

            "Virtual Dungeon", {x: 630, y: 350, scrolls: 1},
            "Dungeon Throne", {x: 630, y: 405, scrolls: 1},
            "Rain Village", {x: 630, y: 440, scrolls: 1}
        ),
        "LegendAct", Map(
            "Act 1", {x: 285, y: 235, scrolls: 0},
            "Act 2", {x: 285, y: 270, scrolls: 0},
            "Act 3", {x: 285, y: 305, scrolls: 0},
            "Act 4", {x: 285, y: 340, scrolls: 0},
            "Act 5", {x: 285, y: 375, scrolls: 0}
        )
    )

    return data.Has(type) && data[type].Has(name) ? data[type][name] : {}
}

StartLegend(map, LegendActDropdown) {
    
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)
    SendInput("{Down}")
    Sleep(500)
    SendInput("{Enter}") ; Opens Legend Stage

    downArrows := GetLegendDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select LegendStage
    Sleep(500)

    Loop 4 {
        SendInput("{Up}") ; Makes sure it selects act
        Sleep(200)
    }

    SendInput("{Left}") ; Go to act selection
    Sleep(1000)
    
    actArrows := GetLegendActDownArrows(LegendActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartLegendNoUINavigation(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    FixClick(660, 140) ; Click Legend Stages
    Sleep(500)

    if (CheckForNotification()) {
        ClickUntilGone(0, 0, 748, 94, 778, 551, ExitNotification, -3, -30)
        Sleep (1000)
    }

    ; Get Legend Stage Map 
    LegendMap := GetMapData("LegendMap", map)
    
    ; Scroll if needed
    if (LegendMap.scrolls > 0) {
        AddToLog("Scrolling down " LegendMap.scrolls " for " map)
        MouseMove(700, 210)
        loop LegendMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(LegendMap.x, LegendMap.y)
    Sleep(1000)
    
    ; Get act details
    LegendAct := GetMapData("LegendAct", act)
    
    ; Scroll if needed for act
    if (LegendAct.scrolls > 0) {
        AddToLog("Scrolling down " LegendAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop LegendAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(LegendAct.x, LegendAct.y)
    Sleep(1000)
    
    return true
}

StartRaid(map, RaidActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    downArrows := GetRaidDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select Raid

    Loop 4 {
        SendInput("{Up}") ; Makes sure it selects act
        Sleep(200)
    }

    SendInput("{Left}") ; Go to act selection
    Sleep(500)
    
    actArrows := GetRaidActDownArrows(RaidActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(300)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

PlayHere() {
    FixClick(400, 435)  ; Play Here or Find Match 
    Sleep (500)
    FixClick(330, 325) ;Click Play here
    Sleep (1200)
    ClickStartStory()
    Sleep (500)
}

StartRaidNoUINavigation(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    if (CheckForNotification()) {
        ClickUntilGone(0, 0, 748, 94, 778, 551, ExitNotification, -3, -30)
        Sleep (1000)
    }

    ; Get Story map 
    RaidMap := GetMapData("RaidMap", map)
    
    ; Scroll if needed
    if (RaidMap.scrolls > 0) {
        AddToLog("Scrolling down " RaidMap.scrolls " for " map)
        MouseMove(700, 210)
        loop RaidMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(RaidMap.x, RaidMap.y)
    Sleep(1000)
    
    ; Get act details
    RaidAct := GetMapData("RaidAct", act)
    
    ; Scroll if needed for act
    if (RaidAct.scrolls > 0) {
        AddToLog("Scrolling down " RaidAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop RaidAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(RaidAct.x, RaidAct.y)
    Sleep(1000)
    
    return true
}


FindMatch() {
    startTime := A_TickCount

    Loop {
        if (A_TickCount - startTime > 50000) {
            AddToLog("Matchmaking timeout, restarting mode")
            FixClick(400, 520)
            return StartSelectedMode()
        }

        FixClick(400, 435)  ; Play Here or Find Match 
        Sleep(300)
        FixClick(460, 330)  ; Click Find Match
        Sleep(300)
        
        ; Try captcha    
        if (!CaptchaDetect(252, 292, 300, 50, 400, 335)) {
            AddToLog("Captcha not detected, retrying...")
            FixClick(585, 190)  ; Click close
            Sleep(1000)
            continue
        }
        FixClick(300, 385)  ; Enter captcha
        return true
    }
}

GetStoryDownArrows(map) {
    switch map {
        case "Planet Greenie": return 2
        case "Walled City": return 3
        case "Snowy Town": return 4
        case "Sand Village": return 5
        case "Navy Bay": return 6
        case "Fiend City": return 7
        case "Spirit World": return 8
        case "Ant Kingdom": return 9
        case "Magic Town": return 10
        case "Haunted Academy": return 11
        case "Magic Hills": return 12
        case "Space Center": return 13
        case "Alien Spaceship": return 14
        case "Fabled Kingdom": return 15
        case "Ruined City": return 16
        case "Puppet Island": return 17
        case "Virtual Dungeon": return 18
        case "Snowy Kingdom": return 19
        case "Dungeon Throne": return 20
        case "Mountain Temple": return 21
        case "Rain Village": return 22
        case "Shibuya District": return 23
    }
}

GetStoryActDownArrows(StoryActDropdown) {
    switch StoryActDropdown {
        case "Infinity": return 1
        case "Act 1": return 2
        case "Act 2": return 3
        case "Act 3": return 4
        case "Act 4": return 5
        case "Act 5": return 6
        case "Act 6": return 7
    }
}


GetLegendDownArrows(map) {
    switch map {
        case "Magic Hills": return 1
        case "Space Center": return 3
        case "Fabled Kingdom": return 4
        case "Virtual Dungeon": return 6
        case "Dungeon Throne": return 7
        case "Rain Village": return 8
    }
}

GetLegendActDownArrows(LegendActDropdown) {
    switch LegendActDropdown {
        case "Act 1": return 1
        case "Act 2": return 2
        case "Act 3": return 3
        case "Random": 
            return Random(1, 3) ; Generates a random number between 1 and 3
    }
}

GetRaidDownArrows(map) {
    switch map {
        case "The Spider": return 1
        case "Sacred Planet": return 2
        case "Strange Town": return 3
        case "Ruined City": return 4
    }
}

GetRaidActDownArrows(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return 1
        case "Act 2": return 2
        case "Act 3": return 3
        case "Act 4": return 4
        case "Act 5": return 5
    }
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100

    ; Zoom in smoothly
    Loop 10 {
        Send "{WheelUp}"
        Sleep 50
    }

    ; Look down
    Click
    MouseMove(400, 400)  ; Move mouse down to angle camera down
    
    ; Zoom back out smoothly
    Loop 20 {
        Send "{WheelDown}"
        Sleep 50
    }
    
    ; Move mouse back to center
    MouseMove(400, 300)
}

TpSpawn() {
    FixClick(26, 570) ;click settings
    Sleep 300
    FixClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 150
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    if (ok := FindText(&X, &Y, 215, 160, 596, 480, 0, 0, Spawn)) {
        AddToLog("Found Teleport to Spawn button")
        FixClick(X + 100, Y - 30)
    } else {
        AddToLog("Could not find Teleport button")
    }
    Sleep 300
    FixClick(583, 147)
    Sleep 300

    ;

}

CloseChat() {
    if (ok := FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup() {
    SendInput("{Tab}") ; Closes Player leaderboard
    Sleep 300
    FixClick(564, 72) ; Closes Player leaderboard
    Sleep 300
    CloseChat()
    Sleep 300
    Zoom()
    Sleep 300
    TpSpawn()
}

DetectMap() {
    AddToLog("Determining Movement Necessity on Map...")
    startTime := A_TickCount
    
    Loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
                AddToLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddToLog("Could not detect map after 5 minutes - proceeding without movement")
            return "no map found"
        }

        ; Check for vote screen
        if (ok := FindText(&X, &Y, 326, 60, 547, 173, 0, 0, VoteStart) or (ok := FindText(&X, &Y, 340, 537, 468, 557, 0, 0, Yen)))  {
            AddToLog("No Map Found or Movement Unnecessary")
            return "no map found"
        }

        mapPatterns := Map(
            "Ant Kingdom", Ant,
            "Sand Village", Sand,
            "Magic Town", MagicTown, 
            "Magic Hills", MagicHills,
            "Navy Bay", Navy,
            "Snowy Town", SnowyTown,
            "Fiend City", Fiend,
            "Spirit World", Spirit,
            "Haunted Academy", Academy,
            "Alien Spaceship", AlienSpaceship,
            "Space Center", SpaceCenter,
            "Mountain Temple", Mount,
            "Cursed Festival", Cursed,
            "Nightmare Train", Nightmare,
            "Air Craft", AirCraft,
            "Hellish City", Hellish,
            "Contracts", ContractLoadingScreen,
            "Winter Event", Winter,
            "Shibuya District", Shibuya
        )

        for mapName, pattern in mapPatterns {
            if (ModeDropdown.Text = "Winter Event" or ModeDropdown.Text = "Contracts") {
                if (ok := FindText(&X, &Y, 10, 70, 350, 205, 0, 0, pattern)) {
                    AddToLog("Detected map: " mapName)
                    return mapName
                }
            } else {
                if (ok := FindText(&X, &Y, 10, 90, 415, 160, 0, 0, pattern)) {
                    AddToLog("Detected map: " mapName)
                    return mapName
                }
            }
        }
        
        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
        case "Planet Greenie":
            MoveForPlanetGreenie()
        case "Snowy Town":
            MoveForSnowyTown()
        case "Sand Village":
            MoveForSandVillage()
        case "Ant Kingdom":
            MoveForAntKingdom()
        case "Magic Town":
            MoveForMagicTown()
        case "Magic Hills":
            MoveForMagicHill()
        case "Navy Bay":
            MoveForNavyBay()
        case "Alien Spaceship":
            MoveForAlienSpaceship()    
        case "Fiend City":
            MoveForFiendCity()
        case "Spirit World":
            MoveForSpiritWorld()
        case "Haunted Academy":
            MoveForHauntedAcademy()
        case "Space Center":
            MoveForSpaceCenter()
        case "Mountain Temple":
            MoveForMountainTemple()
        case "Cursed Festival":
            MoveForCursedFestival()
        case "Nightmare Train":
            MoveForNightmareTrain()
        case "Air Craft":
            MoveForAirCraft()
        case "Hellish City":
            MoveForHellish()
        case "Winter Event":
            MoveForWinterEventNoClick()
        case "Contracts":
            MoveForContracts()
        case "Shibuya District":
            MoveForShibuya()    
    }
}

MoveForPlanetGreenie() {
    SendInput ("{a down}")
    SendInput ("{w down}")
    Sleep (2200)
    SendInput ("{a up}")
    SendInput ("{w up}")
}

MoveForAlienSpaceship() {
    if (ok := FindText(&X, &Y, 0, 244, 48, 278, 0.15, 0.15, AlienSpaceshipAngle)) {
        FixClick(73, 176, "Right")
        Sleep (2500)
    } else {
        FixClick(658, 61, "Right")
        Sleep (2500)
    }
}

MoveForSnowyTown() {
    Fixclick(672, 122, "Right")
    Sleep (6500)
}

MoveForNavyBay() {
    SendInput ("{a down}")
    SendInput ("{w down}")
    Sleep (1700)
    SendInput ("{a up}")
    SendInput ("{w up}")
}

MoveForSandVillage() {
    Fixclick(777, 415, "Right")
    Sleep (3000)
    Fixclick(560, 555, "Right")
    Sleep (3000)
    Fixclick(125, 570, "Right")
    Sleep (3000)
    Fixclick(200, 540, "Right")
    Sleep (3000)
}

MoveForFiendCity() {
    Fixclick(185, 410, "Right")
    Sleep (3000)
    SendInput ("{a down}")
    Sleep (3000)
    SendInput ("{a up}")
    Sleep (500)
    SendInput ("{s down}")
    Sleep (2000)
    SendInput ("{s up}")
}

MoveForSpiritWorld() {
    SendInput ("{d down}")
    SendInput ("{w down}")
    Sleep(7000)
    SendInput ("{d up}")
    SendInput ("{w up}")
    sleep(500)
    Fixclick(614, 97, "Right")
    sleep(4000)
}

MoveForAntKingdom() {
    Fixclick(130, 550, "Right")
    Sleep (3000)
    Fixclick(130, 550, "Right")
    Sleep (4000)
    Fixclick(30, 450, "Right")
    Sleep (3000)
    Fixclick(120, 100, "Right")
    sleep (3000)
}

MoveForMagicTown() {
    Fixclick(700, 315, "Right")
    Sleep (2500)
    Fixclick(585, 535, "Right")
    Sleep (3000)
    SendInput ("{d down}")
    Sleep (3800) ;was 3800
    SendInput ("{d up}")
}


MoveForMagicHill() {
    if (ok := FindText(&X, &Y, 518, 334, 566, 404, 0.15, 0.15, MagicHillsBench) or (ok := FindText(&X, &Y, 522, 339, 557, 402, 0.15, 0.15, MagicHillLegendStageBench))) {
        Fixclick(500, 20, "Right")
        Sleep (3000)
        Fixclick(500, 20, "Right")
        Sleep (3500)
        Fixclick(285, 15, "Right")
        Sleep (2500)
        Fixclick(285, 25, "Right")
        Sleep (3000)
        Fixclick(410, 25, "Right")
        Sleep (3000)
        Fixclick(765, 150, "Right")
        Sleep (3000)
        Fixclick(545, 30, "Right")
        Sleep (3000)
    } else {
        Fixclick(45, 185, "Right")
        Sleep (3000)
        Fixclick(140, 250, "Right")
        Sleep (2500)
        Fixclick(25, 485, "Right")
        Sleep (3000)
        SendInput ("{a down}")
        sleep (3000)
        SendInput ("{a up}")
        Sleep (3000)
        SendInput ("{s down}")
        sleep (1200)
        SendInput ("{s up}")
        Sleep (3000)
    }
}

MoveForHauntedAcademy() {
    if (ok := FindText(&X, &Y, 173, 401, 224, 437, 0.15, 0.15, HauntedAcademyAngle)) {
        if (ModeDropdown.Text = "Story") {
            AddToLog("Angle 1")
            SendInput ("{d up}")
            Sleep 100
            SendInput ("{d down}")
            Sleep 3500
            SendInput ("{d up}")
            KeyWait "d"
        } else {
            SendInput ("{w up}")
            Sleep 100
            SendInput ("{w down}")
            Sleep 6500
            SendInput ("{w up}")
            KeyWait "w"
        }
    }
    if (ok := FindText(&X, &Y, 720, 124, 766, 170, 0.15, 0.15, HauntedAcademyAngle2)) {    
        if (ModeDropdown.Text = "Story") {
            SendInput ("{s up}")
            Sleep 100
            SendInput ("{s down}")
            Sleep 3500
            SendInput ("{s up}")
            KeyWait "s"
        } else {
            SendInput ("{d up}")
            Sleep 100
            SendInput ("{d down}")
            Sleep 6500
            SendInput ("{d up}")
            KeyWait "s"
        }
    }
}

MoveForSpaceCenter() {
    if (ok := FindText(&X, &Y, 248, 402, 283, 438, 0.15, 0.15, SpaceCenterAngle)) {
        Fixclick(160, 280, "Right")
        Sleep (7000)
    } else {
        FixClick(590, 15) ; click on paths
        loop {
            if FindAndClickSpaceCenterPath() {
                FixClick(590, 15) ; click on paths
                break
            }
        }
    }
}

MoveForMountainTemple() {
    Fixclick(40, 500, "Right")
    Sleep (4000)
}

MoveForCursedFestival(){
    SendInput ("{d down}")
    sleep (1800)
    SendInput ("{d up}")
}

MoveForNightmareTrain() {
    SendInput ("{a down}")
    sleep (1800)
    SendInput ("{a up}")
}

MoveForAirCraft() {
    SendInput ("{w down}")
    sleep (800)
    SendInput ("{w up}")
}

MoveForHellish() {
    Fixclick(600, 300, "Right")
    Sleep (7000)
}

MoveForWinterEvent() {
    loop {
        if FindAndClickColor() {
            break
        }
        else {
            AddToLog("Color not found. Turning again.")
            SendInput ("{Left up}")
            Sleep 200
            SendInput ("{Left down}")
            Sleep 750
            SendInput ("{Left up}")
            KeyWait "Left" ; Wait for key to be fully processed
            Sleep 200
        }
    }
}

MoveForWinterEventNoClick() {
    loop 200 {
        Sleep 100

        if FindAndClickBeam() {
            break
        }
    }
}

MoveForContracts() {
    FixClick(590, 15) ; click on paths
    loop {
        if FindAndClickColor() {
            FixClick(590, 15) ; click on paths
            break
        }
        else {
            AddToLog("Color not found. Turning again.")
            SendInput ("{Left up}")
            Sleep 200
            SendInput ("{Left down}")
            Sleep 750
            SendInput ("{Left up}")
            KeyWait "Left" ; Wait for key to be fully processed
            Sleep 200
        }
    }
}

MoveForShibuya() {
    if (ok := FindText(&X, &Y, 220, 190, 320, 250, 0.15, 0.15, ShibuyaAngle)) {
        SendInput ("{a down}")
        Sleep (600)
        SendInput ("{a up}")
        Sleep (500)
        SendInput ("{a down}")
        SendInput ("{w down}")
        Sleep (1500)
        SendInput ("{a up}")
        SendInput ("{w up}")
    } else {
        SendInput ("{d down}")
        Sleep(2000)
        SendInput ("{d up}")
    }
}
    
RestartStage() {
    currentMap := DetectMap()
    
    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    BasicSetup()
    if (currentMap != "no map found") {
        HandleMapMovement(currentMap)
    }

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    if (PlacementPatternDropdown.Text = "Spiral(WIP)") {
        SpiralPlacement()
    } else {
        PlacingUnits()
    }
    
    ; Monitor stage progress
    MonitorStage()
}

CheckForDisconnect() {
    if (ok := FindText(&X, &Y, 450, 410, 539, 427, 0, 0, Disconnect)) {
        AddToLog("Found 20 minute disconnect message...")
        return true
    }
    return false
}

Reconnect() {   
    ; Check for Disconnected Screen using FindText
    if (ok := FindText(&X, &Y, 450, 410, 539, 427, 0, 0, Disconnect)) {
        AddToLog("Lost Connection! Attempting To Reconnect To Private Server...")

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

        ; Reconnect to Ps
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddToLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=8304191830")
        }

        Sleep(5000)  

        loop {
            AddToLog("Reconnecting to Roblox...")
            Sleep(15000)

            if WinExist(rblxID) {
            forceRobloxSize()
            moveRobloxWindow()
            Sleep(1000)
            }
            
            if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode()
            } else {
                Reconnect() 
            }
        }
    }
}

RejoinPrivateServer() {   
    AddToLog("Attempting To Reconnect To Private Server...")

    psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

    if psLink {
        AddToLog("Connecting to private server...")
        Run(psLink)
    } else {
        Run("roblox://placeID=8304191830")  ; Public server if no PS file or empty
    }

    Sleep(5000)

    ; Loop until successfully reconnected
    loop {
        AddToLog("Reconnecting to Roblox...")
        Sleep(5000)

        if WinExist(rblxID) {
            forceRobloxSize() 
            Sleep(1000)
        }

        if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
            AddToLog("Reconnected Successfully!")
            return StartSelectedMode()
        }

        Reconnect()
    }
}

PlaceUnit(x, y, slot := 1) {
    if (ModeDropdown.Text = "Winter Event") {
        CheckForCardSelection()
    }
    SendInput(slot)
    Sleep 50
    FixClick(x, y)
    Sleep 50
    SendInput("q")
    
    if UnitPlaced() {
        Sleep 15
        return true
    }
    return false
}

MaxUpgrade() {
    Sleep 500
    ; Check for max text
    if (ok := FindText(&X, &Y, 225, 388, 278, 412 , 0, 0, MaxText) or (ok:=FindText(&X, &Y, 255, 234, 299, 250, 0, 0, MaxText2))) {
        if (CheckForElyssiaSummon()) {
            return false
        }
        return true
    }
    return false
}

CheckForElyssiaSummon() {
    if FindText(&X, &Y, 14, 226, 138, 246, 0, 0, ElyssiaSummons) {
        AddToLog("Clicked on Elyssia Eel, ignoring...")
        return true
    }
}

MaxUpgraded(limit) {
    levelTexts := Map(
        1, Upgrade1,
        2, Upgrade2,
        3, Upgrade3,
        4, Upgrade4,
        5, Upgrade5,
        6, Upgrade6
    )

    if levelTexts.Has(limit) {
        level := levelTexts[limit]
        if (!level) {
            AddToLog("Error: Level " limit " is undefined or empty")
            return false
        }
        if (ok := FindText(&X, &Y, 150, 200, 350, 450, 0, 0, level)) {
            return true
        }
        return false
    }
}


ReachedUpgradeLimit() {

    ; Search for the dynamic upgrade text
    if (ok := FindText(&X, &Y, 168, 227, 314, 254, 0, 0, Upgrade3)) {
        AddToLog("Upgrade: 0")
        return true
    }
    return false
}

UnitPlaced() {
    if (WaitForUpgradeText(PlacementSpeed())) { ; Wait up to 4.5 seconds for the upgrade text to appear
        AddToLog("Unit Placed Successfully")
        CheckAbility()
        FixClick(325, 185) ; Close upgrade menu
        return true
    }
    return false
}

WaitForUpgradeText(timeout := 4500) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (FindText(&X, &Y, 160, 215, 330, 420, 0, 0, UpgradeText) or (FindText(&X, &Y, 160, 215, 330, 420, 0, 0, UpgradeText2))) {
            if (CheckForElyssiaSummon()) {
                return false
            }
            timeSaved := (A_TickCount - startTime)  ; Time saved
            if (debugMessages) {
                AddToLog("Placement Speed: " . PlacementSpeed() . " ms")
                AddToLog("Upgrade text found! Time saved: " . timeSaved . " ms")
            }
            return true
        }
        Sleep 100  ; Check every 100ms
    }
    if (debugMessages) {
        AddToLog("Timed out! No upgrade text found. Timeout was: " . timeout . " ms")
    }
    return false  ; Timed out, upgrade text was not found
}

CheckAbility() {
    global AutoAbilityBox  ; Reference your checkbox
    ; Only check ability if checkbox is checked
    if (AutoAbilityBox.Value) {
        if (ok := FindText(&X, &Y, 342, 253, 401, 281, 0, 0, AutoOff)) {
            FixClick(373, 237)  ; Turn ability on
            AddToLog("Auto Ability Enabled")
        }
    }
}

CheckForErwin() {
    if (ok := FindText(&X, &Y, 15, 228, 141, 245, 0, 0, ErwinAbility)) {
        return true
    }
    return false
}

CheckForCardSelection() {
    if (ok := FindText(&cardX, &cardY, 196, 204, 568, 278, 0, 0, pick_card)) {
        cardSelector()
    }
}

CheckForXp(closeLeaderboard := false) {
    if (closeLeaderboard) {
        FixClick(564, 72)
        Sleep(500)
    }
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 340, 369, 437, 402, 0, 0, XpText) or (ok:=FindText(&X, &Y, 539, 155, 760, 189, 0, 0, XpText2))) {
        FixClick(325, 185)
        FixClick(560, 560)
        return true
    }
    return false
}

UpgradeUnit(x, y) {
    FixClick(x, y - 3)
    Sleep (500)
    SendInput("R")
    SendInput("R")
    SendInput("R")
}

UpgradeUnitLimit(x, y, coord, index, upgradeLimit) {
    FixClick(x, y - 3)
    Sleep (1000)
    if CheckUpgradeLimit(upgradeLimit + 1) {
        SetUnitAsMaxed(coord, index)
    } else {
        SendInput("R")
    }
}

ClickUnit(x, y) {
    FixClick(x, y - 3)
    Sleep (1000)
}

CheckLobby() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
    AddToLog("Returned to lobby, restarting selected mode")
    return StartSelectedMode()
}

CheckForLobbyText() {
    if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
        return true
    }
    return false
}

CheckLoaded() {
    loop {
        Sleep(1000)
        
        ; Check for vote screen
        if (ok := FindText(&X, &Y, 326, 60, 547, 173, 0, 0, VoteStart) or PixelGetColor(320, 60) = 0x00EE00) {
            AddToLog("Successfully Loaded In")
            Sleep(1000)
            break
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        if (ok := FindText(&X, &Y, 326, 60, 547, 173, 0, 0, VoteStart)) {
            FixClick(350, 103) ; click yes
            FixClick(350, 100)
            FixClick(350, 97)
            continue  ; Keep waiting if vote screen is still there
        }
        
        ; If we don't see vote screen anymore the game has started
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    global inChallengeMode, firstStartup, challengeStartTime
    FixClick(400,340)
    FixClick(400,390)

    if (ChallengeBox.Value && firstStartup) {
        AddToLog("Auto Challenge enabled - starting with challenge")
        inChallengeMode := true
        firstStartup := false
        challengeStartTime := A_TickCount  ; Set initial challenge time
        ChallengeMode()
        return
    }

    ; If we're in challenge mode, do challenge
    if (inChallengeMode) {
        AddToLog("Starting Challenge Mode")
        ChallengeMode()
        return
    }    
    else if (ModeDropdown.Text = "Story") {
        StoryMode()
    }
    else if (ModeDropdown.Text = "Legend") {
        LegendMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        RaidMode()
    }
    else if (ModeDropdown.Text = "Infinity Castle") {
        InfinityCastleMode()
    }
    else if (ModeDropdown.Text = "Contract") {
        if (contractsEnabled) {
            ContractMode()
        } else {
            AddToLog("Contracts are is not currently in Anime Adventures!")
        }
    }
    else if (ModeDropdown.Text = "Winter Event") {
        if (isWinter) {
            WinterEvent()
        } else {
            AddToLog("The Winter Event is not currently in Anime Adventures!")
        }
    }
    else if (ModeDropdown.Text = "Cursed Womb") {
        CursedWombMode()
    }
    else if (ModeDropdown.Text = "Portal") {
        PortalMode()
    }
    else if (ModeDropdown.Text = "Dungeon") {
        DungeonMode()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

HandlePortalEnd() {
    global inChallengeMode, challengeStartTime
    selectedPortal := PortalDropdown.Text

    Loop {
        Sleep(3000)  
        
        FixClick(560, 560)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
            ClickUntilGone(0, 0, 260, 400, 390, 450, NextText, 0, -40)
        }

        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {

            if (inChallengeMode) {
                AddToLog("Challenge completed - returning to selected mode")
                inChallengeMode := false
                challengeStartTime := A_TickCount
                Sleep(1500)
                ClickReturnToLobby()
                return CheckLobby()
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && ChallengeBox.Value) {
                timeElapsed := A_TickCount - challengeStartTime
                if (timeElapsed >= 1800000) {  ; 30 minutes in milliseconds
                    AddToLog("30 minutes passed - switching to Challenge mode")
                    inChallengeMode := true
                    challengeStartTime := A_TickCount
                    Sleep(1500)
                    ClickReturnToLobby()
                    return CheckLobby()
                }
            }
            
            AddToLog("Found Lobby Text - creating/joining new portal")
            Sleep(2000)

        if (PortalJoinDropdown.Text = "Solo") {
            FixClick(485, 120) ;Select New Portal
            Sleep(1500)
            FixClick(510, 190) ; Click search
            Sleep(1500)
            SendInput(selectedPortal)
            Sleep(1500)
            FixClick(215, 285)  ; Click On Portal
            Sleep (1500)
            CheckForPortal(false)
            Sleep(5000)
            return RestartStage()
        }
        else if (PortalJoinDropdown.Text = "Creating") {
            FixClick(485, 120) ;Select New Portal
            Sleep(1500)
            FixClick(510, 190) ; Click search
            Sleep(1500)
            SendInput(selectedPortal)
            Sleep(1500)
            FixClick(215, 285)  ; Click On Portal
            Sleep (1500)
            CheckForPortal(false)
            Sleep(5000)
        } else {
            AddToLog("Waiting for next portal")
            Sleep(5000)
        }
        return RestartStage()
        }
        
        Reconnect()
        CheckEndAndRoute()
    }
}

HandlePortalJoin() {
    selectedPortal := PortalDropdown.Text
    joinType := PortalJoinDropdown.Text

    FixClick(640, 70) ; Closes Player leaderboard
    Sleep (500)

    if (joinType = "Solo") {
    ; Click items
        FixClick(33, 300)
        Sleep(1500)
        
        ; Click portals tab
        FixClick(435, 230)
        Sleep(1500)
                
        ; Click search
        FixClick(510, 190)
        Sleep(1500)
                
        ; Type portal name
        SendInput(selectedPortal)
        Sleep(1500)
        
        AddToLog("Soloing " selectedPortal)
        FixClick(215, 285)  ; Click On Portal
        Sleep (1500)
        CheckForPortal(true)
        Sleep(1500)
        FixClick(250, 350) ; Click Open
        Sleep(1500)
        FixClick(400, 460)  ; Start portal
    }
    else if (joinType = "Creating") {

        ; Click items
        FixClick(33, 300)
        Sleep(1500)

        ; Click portals tab
        FixClick(435, 230)
        Sleep(1500)
        
        ; Click search
        FixClick(510, 190)
        Sleep(1500)
        
        ; Type portal name
        SendInput(selectedPortal)
        Sleep(1500)

        AddToLog("Creating " selectedPortal)
        FixClick(215, 285)  ; Click On Portal
        Sleep (1500)
        CheckForPortal(true)
        Sleep(1500)
        FixClick(250, 350) ; Click Open
        Sleep(1500)
        AddToLog("Waiting 15 seconds for others to join")
        Sleep(15000)
        FixClick(400, 460)  ; Start portal
    } else {
        AddToLog("Please join " selectedPortal " manually")
        Sleep(5000)
    }
}

HandleContractJoin() {
    selectedPage := ContractPageDropdown.Text
    joinType := ContractJoinDropdown.Text
    
    ; Handle 4-5 Page pattern selection
    if (selectedPage = "Page 4-5") {
        selectedPage := GetContractPage()
        AddToLog("Pattern selected: " selectedPage)
    }
    
    pageNum := selectedPage = "Page 4-5" ? GetContractPage() : selectedPage
    pageNum := Integer(RegExReplace(RegExReplace(pageNum, "Page\s*", ""), "-.*", ""))

    ; Define click coordinates for each page
    clickCoords := Map(
        1, { openHere: {x: 170, y: 420}, matchmaking: {x: 240, y: 420} },  ; Example coords for page 1
        2, { openHere: {x: 330, y: 420}, matchmaking: {x: 400, y: 420} },  ; Example coords for page 2
        3, { openHere: {x: 490, y: 420}, matchmaking: {x: 560, y: 420} }, ; Example coords for page 3
        4, { openHere: {x: 237, y: 420}, matchmaking: {x: 305, y: 420} },  ; Example coords for page 4
        5, { openHere: {x: 397, y: 420}, matchmaking: {x: 465, y: 420} },  ; Example coords for page 5
        6, { openHere: {x: 557, y: 420}, matchmaking: {x: 625, y: 420} }  ; Example coords for page 6
    )

    ; First scroll if needed for pages 4-6
    if (pageNum >= 4) {
        FixClick(445, 300)
        Sleep(200)
        Loop 5 {
            SendInput("{WheelDown}")
            Sleep(150)
        }
        Sleep(300)
    }

    if (TeamSwap.Value) {
        CheckBuffs()
    }
    Sleep 1500

    ; Get coordinates for the selected page
    pageCoords := clickCoords[pageNum]

    ; Handle different join types
    if (joinType = "Creating") {
        AddToLog("Creating contract portal on page " pageNum)
        FixClick(pageCoords.openHere.x, pageCoords.openHere.y)
        Sleep(300)
        FixClick(255, 355)
        Sleep(20000)
        AddToLog("Waiting 20 seconds for others to join")
        FixClick(400, 460)
    }   else if (joinType = "Joining") {
        AddToLog("Attempting to join by holding E")
        SendInput("{e down}")
        Sleep(5000)
        SendInput("{e up}")
    }   else if (joinType = "Solo") {
        AddToLog("Attempting to start solo")
        FixClick(pageCoords.openHere.x, pageCoords.openHere.y)
        Sleep(300)
        FixClick(255, 355)
        Sleep 300
        FixClick(400, 468) ; Start Contract
    }   else if (joinType = "Matchmaking") {
        AddToLog("Joining matchmaking for contract on page " pageNum)
        FixClick(pageCoords.matchmaking.x, pageCoords.matchmaking.y)  ; Click matchmaking button
        Sleep(300)
            
        ; Try captcha    
        if (!CaptchaDetect(252, 292, 300, 50, 400, 335)) {
        AddToLog("Captcha not detected, retrying...")
        FixClick(585, 190)  ; Click close
        return
       }
       FixClick(300, 385)  ; Enter captcha

        startTime := A_TickCount
        while (A_TickCount - startTime < 20000) {  ; Check for 20 seconds
        if !(ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
            AddToLog("Area text gone - matchmaking successful")
            return true
        }
        Sleep(200)  ; Check every 200ms
       }
    
        AddToLog("Matchmaking failed - still on area screen after 20s, retrying...")
        FixClick(445, 220) 
        Sleep(1000)
        Loop 5 {
            SendInput("{WheelUp}")
            Sleep(150)
        }
        Sleep(1000)
        return HandleContractJoin()
      }

     AddToLog("Joining Contract Mode")
     return true
}

HandleNextContract() {
    selectedPage := ContractPageDropdown.Text
    if (selectedPage = "Page 4-5") {
        selectedPage := GetContractPage() 
    }
    
    pageNum := Integer(RegExReplace(selectedPage, "Page ", ""))

    ; Define click coordinates to vote
    clickCoords := Map(
        1, {x: 205, y: 470},
        2, {x: 365, y: 470},
        3, {x: 525, y: 470},
        4, {x: 272, y: 470},
        5, {x: 432, y: 470},
        6, {x: 592, y: 470}
    )

    ; First scroll if needed for pages 4-6
    if (pageNum >= 4) {
        FixClick(400, 300)
        Sleep(200)
        Loop 5 {
            SendInput("{WheelDown}")
            Sleep(150)
        }
        Sleep(300)
    }

    ; Click the Open Here button for the selected page
    AddToLog("Opening contract on page " selectedPage)
    FixClick(clickCoords[pageNum].x, clickCoords[pageNum].y)
    Sleep(500)

    return RestartStage()
}

HandleContractEnd() {
    global inChallengeMode, challengeStartTime

    Loop {
        Sleep(3000)  
        
        ; Click to claim any drops/rewards     
        FixClick(560, 560)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
            ClickUntilGone(0, 0, 260, 400, 390, 450, NextText, 0, -40)
        } 

        ; Check for both lobby texts
        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {
            AddToLog("Found Lobby Text - proceeding with contract end options")
            Sleep(2000)  ; Wait for UI to settle

            if (inChallengeMode) {
                AddToLog("Challenge completed - returning to selected mode")
                inChallengeMode := false
                challengeStartTime := A_TickCount
                Sleep(1500)
                ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                return CheckLobby()
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && ChallengeBox.Value) {
                timeElapsed := A_TickCount - challengeStartTime
                if (timeElapsed >= 1800000) {  ; 30 minutes in milliseconds
                    AddToLog("30 minutes passed - switching to Challenge mode")
                    inChallengeMode := true
                    challengeStartTime := A_TickCount
                    Sleep(1500)
                    ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                    return CheckLobby()
                }
            }
            if (ReturnLobbyBox.Value) {
                AddToLog("Contract complete - returning to lobby")
                Sleep(1500)
                ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                CheckLobby()
                return StartSelectedMode()
            } else {
                AddToLog("Starting next contract")
                Sleep(1500)
                ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
                return HandleNextContract()
            }
        }
        Reconnect()
    }
}

GetContractPage() {
    global contractPageCounter, contractSwitchPattern
    
    if (contractSwitchPattern = 0) {  ; During page 4 phase
        contractPageCounter++
        if (contractPageCounter >= 6) {  ; After 6 times on page 4
            contractPageCounter := 0
            contractSwitchPattern := 1  ; Switch to page 5
            return "Page 5"
        }
        return "Page 4"
    } else {  ; During page 5 phase
        contractPageCounter := 0
        contractSwitchPattern := 0  ; Switch back to page 4 pattern
        return "Page 4"
    }
}

CheckEndAndRoute() {
    if (ok := FindText(&X, &Y, 140, 130, 662, 172, 0, 0, LobbyText)) {
        AddToLog("Found end screen")
        if (mode = "Contract") {
            return HandleContractEnd()
        } else if (mode = "Dungeon") {
            return MonitorDungeonEnd()
        } else if (mode = "Portal") {
            return HandlePortalEnd()
        } else {
            return MonitorEndScreen()
        }
    }
    return false
}

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

ClickUntilGoneWithFailSafe(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        
        waitTime := A_TickCount ; Start timer

        if ((A_TickCount - waitTime) > 300000) { ; 5-minute limit
            AddToLog("5 minute failsafe triggered, trying to open roblox...")
            return RejoinPrivateServer()
        }
        
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

RightClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {

        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY, "Right")  
        } else {
            FixClick(x, y, "Right") 
        }
        Sleep(1000)
    }
}

IsColorInRange(color, targetColor, tolerance := 50) {
    ; Extract RGB components
    r1 := (color >> 16) & 0xFF
    g1 := (color >> 8) & 0xFF
    b1 := color & 0xFF
    
    ; Extract target RGB components
    r2 := (targetColor >> 16) & 0xFF
    g2 := (targetColor >> 8) & 0xFF
    b2 := targetColor & 0xFF
    
    ; Check if within tolerance range
    return Abs(r1 - r2) <= tolerance 
        && Abs(g1 - g2) <= tolerance 
        && Abs(b1 - b2) <= tolerance
}


PlacementSpeed() {
    speeds := [1000, 1500, 2000, 2500, 3000, 4000, 5000]  ; Array of sleep values
    speedIndex := PlaceSpeed.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}

FindAndClickBeam(targetColor := 0x006783, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]
	
    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
		AddToLog("Beam found at X" foundX " Y" foundY)
        AddToLog("Moving towards it...")
	Sleep 50
	SendInput("{space up}")
	Sleep 50
	SendInput("{w up}")
	Sleep 50
	SendInput("{a up}")
	Sleep 50
	SendInput("{s up}")
	Sleep 50
	SendInput("{d up}")
	Sleep 50
	MouseMove(400, 300)
	
	PosX:= foundX-400
	PosY:= foundY-300
	
	Sleep 50
	SendInput("{space down}")
	Sleep 50
	if(PosX > 0){
		SendInput("{d down}")
		Sleep PosX*6
		SendInput("{d up}")
	}
	else {
		SendInput("{a down}")
		Sleep -PosX*6
		SendInput("{a up}")
	}	
	Sleep 50
	if(PosY > 0){
		SendInput("{s down}")
		Sleep PosY*6
		SendInput("{s up}")
	}
	else {
		SendInput("{w down}")
		Sleep -PosY*6
		SendInput("{w up}")
	}
	Sleep 50
	SendInput("{space up}")
	Sleep 50
	
		Sleep 100
        return true
    }
}

FindAndMoveToPath(targetColors := [0x32FF3D, 0xFFFF00], searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Loop through each target color
    for _, color in targetColors {
        if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 0)) {
            ; Color found, log details and move
            AddToLog("Path found at X" foundX " Y" foundY " (Color: " color ")")
            AddToLog("Moving towards it...")

            ; Stop movement before adjusting
            StopAllMovement()
            
            ; Recenter mouse
            MouseMove(400, 300)
            
            ; Calculate movement direction
            PosX := foundX - 400
            PosY := foundY - 300

            ; Move towards detected position
            MoveToPosition(PosX, PosY)

            return true
        }
    }
    return false  ; No color found
}

StopAllMovement() {
    Sleep 50
    SendInput("{space up}")
    Sleep 50
    SendInput("{w up}")
    Sleep 50
    SendInput("{a up}")
    Sleep 50
    SendInput("{s up}")
    Sleep 50
    SendInput("{d up}")
    Sleep 50
}

MoveToPosition(PosX, PosY) {
    Sleep 50
    SendInput("{space down}")
    Sleep 50
    if (PosX > 0) {
        SendInput("{d down}")
        Sleep PosX * 6
        SendInput("{d up}")
    } else {
        SendInput("{a down}")
        Sleep -PosX * 6
        SendInput("{a up}")
    }    
    Sleep 50
    if (PosY > 0) {
        SendInput("{s down}")
        Sleep PosY * 6
        SendInput("{s up}")
    } else {
        SendInput("{w down}")
        Sleep -PosY * 6
        SendInput("{w up}")
    }
    Sleep 50
    SendInput("{space up}")
    Sleep 50
}

ClickReplay() {
    if (RejoinRoblox.Value) {
        ClickUntilGoneWithFailSafe(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
    } else {
        ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +120, -35, LobbyText2)
    }
}

ClickNextLevel() {
    if (RejoinRoblox.Value) {
        ClickUntilGoneWithFailSafe(0, 0, 80, 85, 739, 224, LobbyText, +260, -35, LobbyText2)
    } else {
        ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, +260, -35, LobbyText2)
    }
}

ClickReturnToLobby() {
    if (RejoinRoblox.Value) {
        ClickUntilGoneWithFailSafe(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
    } else {
        ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
    }
}

ClickStartStory() {
    ClickUntilGone(0, 0, 320, 468, 486, 521, StartStoryButton, 0, -35)
}

ClickSelectPortal() {
    ClickUntilGone(0, 0, 257, 419, 445, 520, SelectPortal, 0, -35)
}

ClickUsePortal() {
    ClickUntilGone(0, 0, 211, 341, 401, 504, UsePortal, 0, -35)
}

ClickDungeonContinueOld() {
    ClickUntilGone(0, 0, 212, 280, 406, 476, DungeonContinue, 0, -35)
}

ClickDungeonContinue() {
    ClickUntilGone(0, 0, 380, 385, 615, 490, DungeonContinue, -3, -35, DungeonContinue2)
}

CheckIfFinalRoom() {
    if (ok := FindText(&X, &Y, 434, 215, 479, 230, 0, 0, FinalRoom)) {
        return true
    }
    return false
}

; Custom monitor for dungeon ending
MonitorDungeonEnd() {
    global mode, Wins, loss, challengeStartTime, inChallengeMode

    failed := false
    
    Loop {
        Sleep(3000)  
        
        FixClick(560, 560)  ; Move click

        ; Check for unit exit UI element
        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }
        
        if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText) or (ok:=FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText2))) {
            failed := true
        }

        ; Check for next text UI element
        if (ok := FindText(&X, &Y, 260, 400, 390, 450, 0, 0, NextText)) {
            ClickUntilGone(0, 0, 260, 400, 390, 450, NextText, 0, -40)
        }

        ; Check for returning to lobby
        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {

            ; Challenge mode logic first
            if (inChallengeMode) {
                AddToLog("Challenge completed - returning to " mode " mode")
               inChallengeMode := false
               challengeStartTime := A_TickCount
               ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
               return CheckLobby()
           }

           ; Check if it's time for challenge mode
           if (!inChallengeMode && ChallengeBox.Value) {
               timeElapsed := A_TickCount - challengeStartTime
               if (timeElapsed >= 1800000) {
                   AddToLog("30 minutes passed - switching to Challenge mode")
                   inChallengeMode := true
                   challengeStartTime := A_TickCount
                   ClickUntilGone(0, 0, 80, 85, 739, 224, LobbyText, 0, -35, LobbyText2)
                   return CheckLobby()
               }
           }

            if (QuitIfFailBox.Value && failed) {
                AddToLog("Dungeon run failed, stopping to save lives...")
                ClickReturnToLobby()
                SendFinalWebhookBeforeExit()
                CheckLobby()
                Sleep(2000)
                return Reload()
            } else  {
                AddToLog("Dungeon run completed, clicking replay")
            
                ; Click replay button
                ClickReplay()
                
                ; After clicking replay, check for shop/shrine/chest
                CheckDungeonSpecials()
    
                if (CheckForFinishDungeon()) {
                    AddToLog("Handled dungeon completion")
                    return
                }
                
                ; Start a new dungeon run
                AddToLog("Starting next dungeon")
                return SelectDungeonRoute()
            }
            Reconnect()
        }
    }
}

; Function to check for special dungeon elements after replay
CheckDungeonSpecials() {
    AddToLog("Checking for dungeon shop, shrine, open chest")
    
    ; Give time for special elements to appear
    Sleep(2000)
    
    foundShop := false
    foundShrine := false
    foundChest := false

    ; Check the area for shop, shrine, or chest
    Loop 5 {
        ; Check for shop
        if (!foundShop && FindText(&X, &Y, 140, 200, 375, 250, 0, 0, Shop)) {
            AddToLog("Found Shop")
            Sleep(1000)
            HandleShop()
            Sleep(1000)
            foundShop := true
        }
        ; Check for shrine
        if (!foundShrine && FindText(&X, &Y, 140, 200, 375, 250, 0, 0, Shrine)) {
            AddToLog("Found Shrine, Denying")
            ClickUntilGone(0, 0, 490, 420, 605, 455, DenyShrine, 0, -30)
            Sleep(1000)
            foundShrine := true
        }
        ; Check for Chest Opening
        if (!foundChest && FindText(&X, &Y, 140, 200, 375, 250, 0, 0, ChestRoom)) {
            AddToLog("Found Chest Opening")
            HandleChestScreen()
            foundChest := true
        }
        
        ; If all elements are found, exit early
        if (foundShop && foundShrine && foundChest)
            break

        Sleep(1000)  ; Wait and check again
    }
    
    if (!foundShop && !foundShrine && !foundChest)
        AddToLog("No shop, shrine, or chest found")
}

SelectDungeonRoute() {
    CheckDungeonSpecials()
    Sleep(2000)
    if (ok := FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom) or (ok := FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom2))) {
        AddToLog("Boss room detected!")
        global BossRoomCompleted := true
        FixClick(X, Y-30)
        WaitFor("Dungeon Room Enter")
    }
    else if (ok := FindText(&X, &Y, 360, 348, 443, 434, 0.20, 0.20, DoubleChest) or (ok := FindText(&X, &Y, 360, 348, 443, 434, 0.20, 0.20, DoubleChestNoHover))) {
        AddToLog("Found Double Chest Room, clicking it")
        FixClick(X, Y-30)
        WaitFor("Dungeon Room Enter")
    }
    else if (ok := FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, Chest)) {
        AddToLog("Found Chest Room, clicking it")
        FixClick(X, Y-30)
        WaitFor("Dungeon Room Enter")
    }
    else if (ok := FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, Hoard)) {
        AddToLog("Found Hoard Room, clicking it")
        FixClick(X, Y-30)
        WaitFor("Dungeon Room Enter")
    }
    else {
        ; If no chest/hoard found, click default positions
        AddToLog("No chest/hoard found, clicking default positions")
        FixClick(400, 355)
        Sleep(500)
        FixClick(335, 355)
        WaitFor("Dungeon Room Enter")
    }
    
    ; Look for Enter button and click until gone
    if (ok := FindText(&X, &Y, 120, 425, 680, 500, 0.20, 0.20, Enter)) {
        AddToLog("Found Enter button, joining dungeon")
        ClickUntilGone(0, 0, 120, 425, 680, 500, Enter, 0, -30)
        Sleep(2000)
        
        ; Start dungeon run
        AddToLog("Starting dungeon run")
        RestartStage()
    }
}

HandleShop() {
    AddToLog("Handling shop - buying available items")
    
    ; Give the shop time to fully load
    Sleep(1000)
    
    ; Buy item in slot 3 (bottom)
    FixClick(560, 335)
    Sleep(1000)
    
    ; Buy item in slot 2 (middle)
    FixClick(560, 280)
    Sleep(1000)
    
    ; Buy item in slot 1 (top)
    FixClick(560, 225)
    Sleep(1000)
    
    ; Click continue to close the shop
    AddToLog("Closing shop")
    FixClick(485, 410)
    ClickDungeonContinue()
    Sleep(1000)
    return true
}

HandleChestScreen() {
    global BossRoomCompleted, SaveChestsForBoss
    
    ; Determine if we should open chests now
    shouldOpenChests := BossRoomCompleted || !SaveChestsForBoss
    
    if (shouldOpenChests) {
        AddToLog("Opening all available chests")
        
        ; Process first chest position - keep clicking until exhausted
        firstChestExhausted := false
        
        while (!firstChestExhausted ) {
            ; Click first chest OPEN button
            FixClick(565, 260)
            Sleep(2000)
            
            ; Check if we're still on the chest screen
            if (!IsChestScreenVisible()) {
                ClaimChestReward()
            } else {
                firstChestExhausted := true
            }
        }
        
        ; Process second chest position - keep clicking until exhausted
        secondChestExhausted := false
        
        while (!secondChestExhausted) {
            ; Click second chest OPEN button
            FixClick(565, 320)
            Sleep(1000)
            
            ; Check if we're still on the chest screen
            if (!IsChestScreenVisible()) {
                ClaimChestReward()
            } else {
                secondChestExhausted := true
            }
        }

        AddToLog("All chests opened")

        if (BossRoomCompleted) {
            BossRoomCompleted := false
            ClickDungeonContinue()
        }
        } else {
            AddToLog("Saving chests for boss room - clicking continue")
            ClickDungeonContinue()
        }
        Sleep(1000)
        Reconnect()
        return true
    }

ClaimChestReward() {
    maxClicks := 40  ; Safety limit
    clicks := 0
    
    while (clicks < maxClicks) {
        ; Click to claim reward
        FixClick(560, 560)
        Sleep(1500)
        
        ; Check if chest screen has returned
        if (IsChestScreenVisible()) {
            return true
        }
        
        clicks++
    }
    
    AddToLog("Max clicks reached while claiming rewards")
    return false
}

IsChestScreenVisible() {
    return FindText(&X, &Y, 140, 200, 375, 250, 0, 0, ChestRoom)
}

CheckForPortal(lobby := false) {
    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    if (lobby) {
        if TryHandlePortal(211, 341, 401, 504, UsePortal, "starting portal") {
            return
        }
        HandlePortalFallback()
    } else {
        if TryHandlePortal(257, 419, 445, 520, SelectPortal, "restarting portal") {
            return
        }
        HandlePortalFallback()
    }
}

TryHandlePortal(x1, y1, x2, y2, portalText, action) {
    if (ok := FindText(&portalX, &portalY, x1, y1, x2, y2, 0, 0, portalText)) {
        AddToLog("Portal detected, " action "...")
        if (portalText = SelectPortal) {
            ClickSelectPortal()
        } else {
            ClickUsePortal()
        }
        return true
    }
    return false
}

HandlePortalFallback() {
    global mode
    FixClick(660, 187) ; Close Portal Interface if applicable

    if (PortalDropdown.Text = "Shibuya Portal") {
        AddToLog("No portal detected, changing to Shibuya District Infinite...")
        mode := "Story"

        ModeDropdown.Text := "Story"
        StoryDropdown.Text := "Shibuya District"
        StoryActDropdown.Text := "Infinity"

        return CheckLobby()
    } else {
        AddToLog("No portal detected, shutting down...")
        SendFinalWebhookBeforeExit()
        Sleep(2000)
        return Reload()
    }
}

CheckForFinishDungeon() {
    ; Check for the finish dungeon popup
    if (ok := FindText(&X, &Y, 240, 180, 565, 480, 0, 0, FinishDungeon) or (ok := FindText(&X, &Y, 310, 395, 495, 440, 0.20, 0.20, EnterDungeon)) or (ok := FindText(&X, &Y, 370, 225, 545, 300, 0.20, 0.20, DungeonDeath))) {
        
        ; Click the Finish button
        ClickUntilGone(0, 0, 240, 180, 565, 480, DungeonFinish, -3, -35)
        Sleep(1500)
        
        ; Click the X in the top right
        ClickUntilGone(0, 0, 640, 175, 700, 205, DungeonRedX, -3, -35)
        Sleep(1000)
        
        ; Return to lobby
        AddToLog("Returning to lobby after completing dungeon")
        ClickReturnToLobby()
        
        ; Check for lobby and restart
        return CheckLobby()
    }
    
    return false
}

CheckForUpgrade(upgradeLimit) {
    if (!MaxUpgrade()) {
        return UpgradeDetect(170, 231, 118, 22, 400, 335, upgradeLimit) ? true : false
    }
    return false
}

CheckUpgradeLimit(upgradeCap) {
    Sleep 500

    ; Map the upgrade cap to the corresponding MaxText variable
    upgradeTexts := [
        Upgrade0, Upgrade1, Upgrade2, Upgrade3, Upgrade4,
        Upgrade5, Upgrade6, Upgrade7, Upgrade8, Upgrade9
    ]

    ; Select the correct upgrade text based on the cap
    targetText := upgradeTexts[upgradeCap]

    ; Check for max text in the designated area
    if (ok := FindText(&X, &Y, 170, 228, 312, 252, 0, 0, targetText) or (ok := FindText(&X, &Y, 170, 228, 312, 252, 0, 0, targetText))) {
        return true
    }
    
    return false
}

CheckForRobloxApp() {
    return FindText(&X, &Y, 14, 55, 57, 115, 0, 0, RobloxApp) ? true : false
}

CheckForNotification() {
    return FindText(&X, &Y, 748, 94, 778, 551, 0, 0, ExitNotification) ? true : false
}