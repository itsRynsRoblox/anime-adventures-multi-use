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
    roomSearchAreas := [
        {x1: 200, y1: 343, x2: 297, y2: 442}, ; First Room (200, 344, 297, 437)
        {x1: 353, y1: 343, x2: 448, y2: 442}, ; Second Room (353, 342, 448, 437)
        {x1: 510, y1: 343, x2: 607, y2: 442},  ; Third Room (510, 343, 607, 442)

        {x1: 275, y1: 340, x2: 300, y2: 437}, ;275, 339, 300, 437
        {x1: 428, y1: 340, x2: 455, y2: 437} ;434, 345, 524, 436 / 428, 340, 455, 437

    ]

    for index, room in roomSearchAreas {
        if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.20, 0.20, DungeonRoomBorder)) {
            AddToLog("Room " index " found via FindText (Available)")
            visibleRooms++  ; Count as visible room
        }
        else if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.10, 0.10, DungeonRoomBorderDark)) {
            AddToLog("Room " index " found via FindText (Unavailable)")
            visibleRooms++  ; Count as a visible room
            unavailableRooms++  ; Increment unavailable room count
        } else if (FindText(&X, &Y, room.x1, room.y1, room.x2, room.y2, 0.10, 0.10, DungeonRoomBorderCursed)) {
            AddToLog("Room " index " found via FindText (Cursed)")
            visibleRooms++  ; Count as a visible room
            cursedRooms++  ; Increment unavailable room count
        }
    }

    AddToLog(Format("Visible Rooms Count: {}", visibleRooms))
    AddToLog(Format("Cursed Rooms Count: {}", cursedRooms))
    AddToLog(Format("Unavailable Rooms Count: {}", unavailableRooms))

    return CheckDungeonRoomsNew(visibleRooms)
}

CheckDungeonRoomsNew(totalrooms) {
    foundRoom := false
    unsafeRooms := [] ; Store unsafe rooms
    lastFoundRoom := {} ; Store last found room to fall back on

    roomDefs := [
        {x: 250, y: 360, search: {x1: 213, y1: 357, x2: 282, y2: 424}}, ; First Room
        {x: 400, y: 360, search: {x1: 370, y1: 357, x2: 436, y2: 424}}, ; Second Room (First Room if only one room)
        {x: 555, y: 360, search: {x1: 524, y1: 356, x2: 590, y2: 424}}, ; Third Room
        {x: 325, y: 360, search: {x1: 283, y1: 350, x2: 365, y2: 430}}, ; First Room (2 Rooms)
        {x: 480, y: 360, search: {x1: 439, y1: 349, x2: 523, y2: 430}}  ; Second Room (2 Rooms)
    ]

    visibleRoomsCount := totalrooms
    rooms := (visibleRoomsCount == 2) ? [roomDefs[4], roomDefs[5]] : (visibleRoomsCount == 1) ? [roomDefs[2]] : [roomDefs[1], roomDefs[2], roomDefs[3]] ; Filter rooms based on visibility

    ; Begin loop to go through rooms
    while (!foundRoom && rooms.Length > 0) {
        for i, room in rooms {
            if (unsafeRooms.Has(i))  ; Skip rooms marked as unsafe
                continue

            roomFound := false ; Track whether a room is found in this iteration

            for index, priority in routePriorityOrder {
                if (!roomTexts.Has(priority)) {
                    if (debugMessages) {
                        AddToLog(Format("{} room not available", priority))
                    }
                    continue
                }

                ; Searching for room
                if (ok := FindText(&X, &Y, room.search.x1, room.search.y1, room.search.x2, room.search.y2, 0.20, 0.20, roomTexts.Get(priority))) {
                    if (debugMessages) {
                        AddToLog("Found room: " (i))
                    }

                    if (unsafeRooms.Has(i))  ; Skip rooms marked as unsafe
                        continue

                    lastFoundRoom := room ; Store this room as fallback

                    if (priority = "MultiChest" || priority = "Chest") {
                        if (ok := ImageSearch(&searchX, &searchY, room.search.x1, room.search.y1, room.search.x2, room.search.y2, RareChest)) {
                            AddToLog("Found Room: Rare Chest")
                            FixClick(room.x, room.y)
                            foundRoom := true
                            roomFound := true ; Mark room as found for this iteration
                            break
                        }
                    }
                    foundRoom := true
                    AddToLog(Format("Found Room: {}", priority))
                    FixClick(room.x, room.y)
                    Sleep(500)
                    roomFound := true ; Mark room as found

                    ; Now call DetectCurse only if necessary
                    curseResult := DetectCurse()
                    if (curseResult != "no curse found") {
                        AddToLog(Format("Curse detected: {}! Marking room as unsafe.", curseResult))
                        unsafeRooms.Push(i) ; Mark room as unsafe
                        foundRoom := false ; Reset found room for this loop, don't break yet
                        roomFound := false
                        FixClick(room.x, room.y)
                        continue ; Skip to next room
                    }

                    break
                }
            }

            ; If no priority is found but it's the only room, don't mark it unsafe
            if (!roomFound && i = rooms.Length) {
                AddToLog("No priority found in room but it's the last room.")
                continue
            }

            if (roomFound) ; If a valid room is found, break out of the outer loop
                break
        }

        ; If no room is found, loop through again
        if (!foundRoom && unsafeRooms.Length < rooms.Length) {
            AddToLog("All rooms marked unsafe. Retrying.")
            ; Remove the unsafe room from the list and loop back through the remaining ones
            rooms := rooms.Filter(room => !unsafeRooms.Has(rooms.IndexOf(room)))
            Sleep(1000) ; Give some time before retrying
        }
    }

    ; If no room is found but fallback room exists, use it.
    if (!foundRoom && lastFoundRoom) {
        AddToLog("All rooms marked unsafe. Clicking fallback room.")
        FixClick(lastFoundRoom.x, lastFoundRoom.y)
    }
    ; If no room is found and no fallback, click default positions
    else if (!foundRoom && !lastFoundRoom) {
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
            "Curse of Wind", CurseOfWind,
            "Curse of Money", CurseOfMoney
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