#Requires AutoHotkey v2.0

GetMapForFarming(name) {
    farmMap := Map(
        "Eclipse Portal", "Snowy Kingdom",
        "Snowy Kingdom", "Eclipse Portal",

        "Demon Leader's Portal", "Fabled Kingdom",
        "Fabled Kingdom", "Demon Leader's Portal",

        "Noble Portal", "Mountain Temple",
        "Mountain Temple", "Noble Portal",

        "Puppet Portal", "Puppet Island",
        "Puppet Island", "Puppet Portal",

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
    global mode
    if (ModeDropdown.Text = "Story") {
        newMap := GetMapForFarming(StoryDropdown.Text)
        if (newMap != "no map found") {
            ModeDropdown.Text := "Portal"
            PortalDropdown.Text := newMap
            PortalJoinDropdown.Text := "Solo"
            mode := "Portal"
            AddToLog("Switched to " newMap)
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
            mode := "Story"
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
    Sleep(500)

    ; Click items and portals tab
    ClickItemsAndPortalsTab()

    ; Click search and type portal name
    ClickSearchAndTypePortal(selectedPortal)

    if (joinType = "Solo") {
        AddToLog("Soloing " selectedPortal)
        HandlePortalSelection()
        FixClick(400, 460)  ; Start portal
    } else if (joinType = "Creating") {
        AddToLog("Creating " selectedPortal)
        HandlePortalSelection()
        AddToLog("Waiting 15 seconds for others to join")
        Sleep(15000)
        FixClick(400, 460)  ; Start portal
    } else {
        AddToLog("Please join " selectedPortal " manually")
        Sleep(5000)
    }
}

HandlePortalSelection() {
    FixClick(215, 285)  ; Click On Portal
    Sleep(1500)
    CheckForPortal(true)
    Sleep(1500)
    FixClick(250, 350) ; Click Open
    Sleep(1500)
}

ClickItemsAndPortalsTab() {
    FixClick(33, 300) ; Click items
    Sleep(1500)
    FixClick(435, 230) ; Click portals tab
    Sleep(1500)
}

ClickSearchAndTypePortal(selectedPortal) {
    FixClick(510, 190) ; Click search
    Sleep(1500)
    SendInput(selectedPortal) ; Type portal name
    Sleep(1500)
}

CheckForPortal(lobby := false) {
    x1 := lobby ? 211 : 257
    y1 := lobby ? 341 : 419
    x2 := lobby ? 401 : 445
    y2 := lobby ? 504 : 520
    portalText := lobby ? UsePortal : SelectPortal
    action := lobby ? "starting portal" : "restarting portal"

    if TryHandlePortal(x1, y1, x2, y2, portalText, action) {
        return
    }
    HandlePortalFallback(lobby)
}

TryHandlePortal(x1, y1, x2, y2, portalText, action) {
    if (ok := FindText(&portalX, &portalY, x1, y1, x2, y2, 0, 0, portalText)) {
        AddToLog("Portal detected, " action "...")
        (portalText = SelectPortal) ? ClickSelectPortal() : ClickUsePortal()
        return true
    }
    return false
}

HandlePortalFallback(lobby := false) {
    FixClick(660, 187) ; Close Portal Interface
    SwitchActiveFarm()
    Sleep(1500)
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

        HandleTextFind(300, 190, 360, 250, UnitExit, -4, -35)
        Sleep(1500)

        HandleTextFind(260, 400, 390, 450, NextText, 0, -40)
        Sleep(1500)

        if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText) or (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText2))) {
            if (inChallengeMode) {
                CompleteChallenge()
                return
            }

            if (CheckChallengeMode()) {
                return
            }

            AddToLog("Found Lobby Text - creating/joining new portal")
            Sleep(2000)

            CreateOrJoinPortal(selectedPortal)

            if (PortalJoinDropdown.Text = "Solo") {
                return RestartStage()
            } else if (PortalJoinDropdown.Text = "Creating") {
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

HandleTextFind(x1, y1, x2, y2, text, offsetX, offsetY) {
    if (ok := FindText(&X, &Y, x1, y1, x2, y2, 0, 0, text)) {
        ClickUntilGone(0, 0, x1, y1, x2, y2, text, offsetX, offsetY)
    }
}

CompleteChallenge() {
    global inChallengeMode, challengeStartTime
    AddToLog("Challenge completed - returning to selected mode")
    inChallengeMode := false
    challengeStartTime := A_TickCount
    Sleep(1500)
    ClickReturnToLobby()
    CheckLobby()
}

CheckChallengeMode() {
    global inChallengeMode, challengeStartTime
    if (!inChallengeMode && ChallengeBox.Value) {
        timeElapsed := A_TickCount - challengeStartTime
        if (timeElapsed >= 1800000) {  ; 30 minutes in milliseconds
            AddToLog("30 minutes passed - switching to Challenge mode")
            inChallengeMode := true
            challengeStartTime := A_TickCount
            Sleep(1500)
            ClickReturnToLobby()
            CheckLobby()
            return true
        }
    }
    return false
}

CreateOrJoinPortal(selectedPortal) {
    FixClick(485, 120) ; Select New Portal
    Sleep(1500)
    FixClick(510, 190) ; Click search
    Sleep(1500)
    SendInput(selectedPortal)
    Sleep(1500)
    FixClick(215, 285) ; Click On Portal
    Sleep(1500)
    CheckForPortal(false)
    Sleep(5000)
}

ClickSelectPortal() {
    ClickUntilGone(0, 0, 257, 419, 445, 520, SelectPortal, 0, -35)
}

ClickUsePortal() {
    ClickUntilGone(0, 0, 211, 341, 401, 504, UsePortal, 0, -35)
}