#Requires AutoHotkey v2.0

GetMapForFarming(name) {
    farmMap := Map(
        "Shibuya Portal", "Shibuya District",
        "Shibuya District", "Shibuya Portal"
    )
    if (farmMap.Has(name)) {
        return farmMap[name]
    } else {
        return "no map found"
    }
}

SetMapForPortalFarm(name) {
    return StoryDropdown.Text := name
}

SwitchActiveFarm() {
    if (ModeDropdown.Text = "Story") {
        newMap := GetMapForFarming(StoryDropdown.Text)
        if (newMap != "no map found") {
            ModeDropdown.Text := "Portal"
            PortalDropdown.Text := newMap
            PortalJoinDropdown.Text := "Solo"
            AddToLog("Switched to " newMap " Portals")
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Portal: " PortalDropdown.Text)
                AddToLog("Join Type: " PortalJoinDropdown.Text)
            }
        } else {
            if (debugMessages) {
                AddToLog("No valid portal mapping found for " StoryDropdown.Text)
            }
        }
    } else {
        newMap := GetMapForFarming(PortalDropdown.Text)
        if (newMap != "no map found") {
            ModeDropdown.Text := "Story"
            StoryActDropdown.Text := "Infinity"
            StoryDropdown.Text := newMap
            AddToLog("Switched to " newMap " for farming portals")
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Story Act: " StoryActDropdown.Text)
                AddToLog("Story: " StoryDropdown.Text)
            }
        } else {
            if (debugMessages) {
                AddToLog("No valid story mapping found for " PortalDropdown.Text)
            }
        }
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

CheckForPortal(lobby := false) {
    if (lobby) {
        if TryHandlePortal(211, 341, 401, 504, UsePortal, "starting portal") {
            return
        }
        HandlePortalFallback(lobby)
    } else {
        if TryHandlePortal(257, 419, 445, 520, SelectPortal, "restarting portal") {
            return
        }
        HandlePortalFallback(lobby)
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

HandlePortalFallback(lobby) {
    FixClick(660, 187) ; Close Portal Interface
    SwitchActiveFarm()
    if (!lobby) {
        ClickReturnToLobby()
    }
    return CheckLobby()
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

ClickSelectPortal() {
    ClickUntilGone(0, 0, 257, 419, 445, 520, SelectPortal, 0, -35)
}

ClickUsePortal() {
    ClickUntilGone(0, 0, 211, 341, 401, 504, UsePortal, 0, -35)
}