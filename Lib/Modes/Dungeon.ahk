#Requires AutoHotkey v2.0


CheckForChestRoom() {
    return FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, Chest)
}

CheckForDoubleChestRoom() {
    return FindText(&X, &Y, 360, 348, 443, 434, 0.20, 0.20, DoubleChest) or (ok := FindText(&X, &Y, 360, 348, 443, 434, 0.20, 0.20, DoubleChestNoHover))
}

CheckForHoardRoom() {
    return FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, Hoard)
}

CheckForBossRoom() {
    return FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom) or (ok := FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom2))
}

CheckForDungeonShop() {
    return FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, DungeonShop)
}

CheckForShrineRoom() {
    return FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, ShrineRoom)
}

CheckRoomForCurse() {
   return FindText(&X, &Y, 121, 168, 681, 493, 0.20, 0.20, CurseOfFlight)
}

CountVisibleRooms() {
    visibleRooms := 0
    unavailableRooms := 0
    cursedRooms := 0
    openingRooms := 0
    foundRooms := []

    roomSearchAreas := [
        {x1: 200, y1: 340, x2: 222, y2: 437}, ;200, 344, 222, 435
        {x1: 353, y1: 340, x2: 378, y2: 437}, ;353, 340, 378, 436
        {x1: 507, y1: 340, x2: 530, y2: 437}, ;507, 341, 530, 437
        
        {x1: 275, y1: 340, x2: 300, y2: 437},
        {x1: 428, y1: 340, x2: 455, y2: 437}
    ]

    for index, room in roomSearchAreas {
        if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.20, 0.20, DungeonRoomBorder)) {
            foundRooms.Push({index: index, type: "Available", coords: room})
            if (debugMessages) {
                AddToLog("Room " index " found via FindText (Available)")
            }
            visibleRooms++
        }
        else if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.10, 0.10, DungeonRoomBorderDark)) {
            foundRooms.Push({index: index, type: "Unavailable", coords: room})
            if (debugMessages) {
                AddToLog("Room " index " found via FindText (Unavailable)")
            }
            visibleRooms++
            unavailableRooms++
        }
        else if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.10, 0.10, DungeonRoomBorderCursed)) {
            foundRooms.Push({index: index, type: "Cursed", coords: room})
            if (debugMessages) {
                AddToLog("Room " index " found via FindText (Cursed)")
            }
            visibleRooms++
            cursedRooms++
        }
        else if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.10, 0.10, DungeonRoomBorderChestOpen)) {
            foundRooms.Push({index: index, type: "Opening", coords: room})
            if (debugMessages) {
                AddToLog("Room " index " found via FindText (Opening)")
            }
            visibleRooms++
            openingRooms++
        }
    }

    if (debugMessages) {
        AddToLog(Format("Visible Rooms Count: {}", visibleRooms))
        AddToLog(Format("Cursed Rooms Count: {}", cursedRooms))
        AddToLog(Format("Unavailable Rooms Count: {}", unavailableRooms))
    }

    return CheckDungeonRoomsNew(visibleRooms, foundRooms)
}

CheckDungeonRoomsNew(totalrooms, foundRooms) {
    foundRoom := false
    unsafeRooms := Map()
    lastFoundRoom := {}
    bestRoom := {}
    bestRoomFound := false
    bestRoomIndex := -1

    ; Use foundRooms data for dynamic room coordinates
    roomDefs := []
    for index, room in foundRooms {
        roomDefs.Push({x: (room.coords.x1 + room.coords.x2) // 2, y: (room.coords.y1 + room.coords.y2) // 2, search: room.coords})
    }

    for index, priority in routePriorityOrder {
        roomFoundForPriority := false
        for i, room in roomDefs {
            if (unsafeRooms.Has(i))
                continue

            if (!roomTexts.Has(priority)) {
                if (debugMessages) AddToLog(Format("{} room not available", priority))
                continue
            }

            if (ok := FindText(&X, &Y, room.search.x1, room.search.y1, room.search.x2, room.search.y2, 0.20, 0.20, roomTexts.Get(priority))) {
                roomFoundForPriority := true
                if (debugMessages)
                    AddToLog("Found room: " i)

                if (unsafeRooms.Has(i))
                    continue

                lastFoundRoom := room

                if (!bestRoomFound) {
                    bestRoom := room
                    bestRoomFound := true
                    bestRoomIndex := i
                    if (debugMessages)
                        AddToLog(Format("Found room for priority {}: {}", priority, i))
                }
            }
        }

        if (!roomFoundForPriority) {
            if (debugMessages)
                AddToLog(Format("No room found for priority: {}", priority))
            continue
        }

        if (bestRoom) {
            if (debugMessages) 
                AddToLog(Format("Found highest priority room: {} with priority: {}", bestRoom.x, priority))
            AddToLog("X: " bestRoom.x " Y: " bestRoom.y)
            FixClick(bestRoom.x, bestRoom.y - 30)
            foundRoom := true

            curseResult := DetectCurse()
            if (curseResult != "no curse found") {
                AddToLog(Format("Curse detected: {}!", curseResult))
                unsafeRooms[bestRoomIndex] := true
                foundRoom := false
                bestRoomFound := false
                Sleep(1000)
                FixClick(bestRoom.x, bestRoom.y - 30, 1)
                continue
            }

            break
        }
    }

    if (!foundRoom && lastFoundRoom) {
        AddToLog("All rooms marked unsafe. Clicking fallback room.")
        FixClick(lastFoundRoom.x, lastFoundRoom.y)
    } else if (!foundRoom && !lastFoundRoom) {
        AddToLog("No safe chest/hoard found, clicking default positions")
        FixClick(400, 355)
        Sleep(500)
        FixClick(335, 355)
    }
}


CheckDungeonRooms() {

    foundRoom := false

    roomDefs := [
        {x: 506, y: 284, search: {x1: 213, y1: 357, x2: 282, y2: 424}}, ;First Room : 213, 357, 282, 423
        {x: 296, y: 284, search: {x1: 370, y1: 357, x2: 436, y2: 424}}, ;Second Room : 370, 357, 436, 424
        {x: 506, y: 284, search: {x1: 524, y1: 356, x2: 590, y2: 424}}, ;Third Room : 524, 356, 590, 424

        ;Only 2 Rooms
        {x: 506, y: 284, search: {x1: 283, y1: 350, x2: 365, y2: 430}}, ;First Room : 283, 350, 365, 430
        {x: 506, y: 284, search: {x1: 439, y1: 349, x2: 523, y2: 428}} ;Second Room : 439, 349, 523, 428
    ]
    
    rooms := roomDefs

    for i, room in rooms {

        for index, priority in routePriorityOrder {
            if (!roomTexts.Has(priority)) {		
                AddToLog(Format("{} room not available", priority))														
                continue
            }
    
            if (ok := FindText(&X, &Y, room.search.x1, room.search.y1, room.search.x2, room.search.y2, 0.20, 0.20, roomTexts.Get(priority))) {
                if (debugMessages) {
                    AddToLog("Found room: " (i))
                }
                if (priority = "MultiChest" || priority = "Chest") {
                    if (ok := ImageSearch(&searchX, &searchY, room.search.x1, room.search.y1, room.search.x2, room.search.y2, RareChest)) {
                        AddToLog("Found Room: Rare Chest")
                        FixClick(X, Y-30)
                        foundRoom := true
                        break
    
                    }
                }
                foundRoom := true
                AddToLog(Format("Found Room: {}", priority))
                MouseMove(X + 2, Y - 30, 1)
                Sleep (500)
                MouseMove(X - 2, Y - 30, 1)
                Sleep (500)
                DetectCurse()
                break
            }
        }
    }

    if (!foundRoom) {
        ; If no chest/hoard found, click default positions
        AddToLog("No chest/hoard found, clicking default positions")
        FixClick(400, 355)
        Sleep(500)
        FixClick(335, 355)
    }
}

CheckAllDungeonRooms() {

    foundRooms := []  ; Initialize an empty list to store found rooms

    roomDefs := [
        {x: 506, y: 284, search: {x1: 213, y1: 357, x2: 282, y2: 424}}, ; First Room
        {x: 296, y: 284, search: {x1: 370, y1: 357, x2: 436, y2: 424}}, ; Second Room
        {x: 506, y: 284, search: {x1: 524, y1: 356, x2: 590, y2: 424}}, ; Third Room

        ; Instance of 2 rooms
        {x: 506, y: 284, search: {x1: 283, y1: 350, x2: 365, y2: 430}}, ; First Room
        {x: 506, y: 284, search: {x1: 439, y1: 350, x2: 523, y2: 430}}  ; Second Room
    ]
    
    rooms := roomDefs

    for i, room in rooms {

        for index, priority in routePriorityOrder {
            if (!roomTexts.Has(priority)) {		
                AddToLog(Format("{} room not available", priority))														
                continue
            }
    
            if (ok := FindText(&X, &Y, room.search.x1, room.search.y1, room.search.x2, room.search.y2, 0.20, 0.20, roomTexts.Get(priority))) {
                if (debugMessages) {
                    AddToLog("Found room: " (i))
                }
                if (priority = "MultiChest" || priority = "Chest") {
                    if (ok := ImageSearch(&searchX, &searchY, room.search.x1, room.search.y1, room.search.x2, room.search.y2, RareChest)) {
                        AddToLog("Chest room contains a rare chest...")
                    }
                }
                AddToLog(Format("Found Room: {}", priority))
                foundRooms.Push(priority)  ; Add the found room to the list
            }
        }
    }
    return foundRooms  ; Return the list of found rooms
}

CheckDungeonRoomsCopy(roomSet) {
    roomDefs := [
        {x: 506, y: 284, search: {x1: 213, y1: 357, x2: 282, y2: 424}}, ;First Room : 213, 357, 282, 423
        {x: 296, y: 284, search: {x1: 370, y1: 357, x2: 436, y2: 424}}, ;Second Room : 370, 357, 436, 424
        {x: 506, y: 284, search: {x1: 524, y1: 356, x2: 590, y2: 424}} ;Third Room : 524, 356, 590, 424
    ]
    
    rooms := roomDefs

    for i, room in rooms {
        if (ok := FindText(&X, &Y, room.search.x1, room.search.y1, room.search.x2, room.search.y2, 0.20, 0.20, roomSet)) {
            AddToLog("Found room: " (i))
            MouseMove(X + 2, Y - 30, 1)
            return true
        }
    }
    AddToLog("No preferred room found. Defaulting to center room.")
    Sleep 1000
    return false
}

StartDungeonRoute() {
    CheckDungeonSpecials()
    Sleep(2000)

    foundRoom := false

    for index, priority in routePriorityOrder {
        if (!roomTexts.Has(priority)) {		
            AddToLog(Format("{} room not available in textCards", priority))														
            continue
        }
    
        if (ok := FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom) or (ok := FindText(&X, &Y, 300, 260, 500, 465, 0.10, 0.10, BossRoom2))) {
            global BossRoomCompleted := true
            FixClick(X, Y-30)
            foundRoom := true
            break
        }
    
        else if (ok := FindText(&X, &Y, 200, 350, 600, 435, 0.20, 0.20, roomTexts.Get(priority))) {
            if (priority = "Chest") {
                if (ok := ImageSearch(&searchX, &searchY, 200, 350, 600, 435, RareChest)) {
                    AddToLog("Found Room: Rare Chest")
                    FixClick(X, Y-30)
                    foundRoom := true
                    break

                }
            }
            AddToLog(Format("Found Room: {}", priority))
            FixClick(X, Y-30)
            foundRoom := true
            break
        }
    }
    
    if (!foundRoom) {
        ; If no chest/hoard found, click default positions
        AddToLog("No chest/hoard found, clicking default positions")
        FixClick(400, 355)
        Sleep(500)
        FixClick(335, 355)
        WaitFor("Dungeon Room Enter")
    } else {
        WaitFor("Dungeon Room Enter")
    }

    if (FindText(&X, &Y, 370, 225, 545, 300, 0.20, 0.20, DungeonDeath)) {
        AddToLog("Found Death Screen")
        ClickDungeonDeathContinue()
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
            if (DenyShrines.Value) {
                AddToLog("Found Shrine, Denying")
                ClickUntilGone(0, 0, 490, 420, 605, 455, DenyShrine, 0, -30)
            } else {
                AddToLog("Found Shrine, accepting...")
                ClickUntilGone(0, 0, 364, 421, 476, 455, ShrineAccept, 0, -30)
            }
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
        } else {
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
                return StartDungeonRoute()
            }
            Reconnect()
        }
    }
}

ClickDungeonContinue() {
    ClickUntilGone(0, 0, 380, 385, 615, 490, DungeonContinue, -3, -35, DungeonContinue2)
}

ClickDungeonDeathContinue() {
    ClickUntilGone(0, 0, 308, 391, 494, 437, DungeonDeathContinue, -0, -30)
}

CheckIfFinalRoom() {
    if (ok := FindText(&X, &Y, 434, 215, 479, 230, 0, 0, FinalRoom)) {
        return true
    }
    return false
}

DetectCurse() {
    AddToLog("Checking room for curse...")  ; Log the curse check start
    curseCheckTime := A_TickCount
    
    Loop {
        if (A_TickCount - curseCheckTime > 3000) {
            AddToLog("Could not detect curse after 3 seconds - proceeding...")
            return "no curse found"
        }

        curseTexts := Map(
            "Curse of Flight", CurseOfFlight,
            "Curse of Flight", CurseOfFlightLobby,
            "Curse of Wind", CurseOfWind,
            "Curse of Money", CurseOfMoney,
            "Curse of Health", CurseOfHealth,
            "Curse of Shielding", CurseOfShielding,
            "Curse of Shielding", CurseOfShieldingLobby
        )

        for curseName, curse in curseTexts {
            if (ok := FindText(&X, &Y, 121, 168, 681, 493, 0.10, 0.10, curse)) {
                AddToLog("Detected Curse: " curseName)
                return curseName
            }
        }
        Sleep 1000
    }
}