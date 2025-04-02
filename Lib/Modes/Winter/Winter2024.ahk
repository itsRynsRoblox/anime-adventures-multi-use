#Requires AutoHotkey v2.0

WinterEvent() {
    ; Execute the movement pattern
    AddToLog("Moving to position for Winter Event")
    EventMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 468-150000, 386-150000, 468+150000, 386+150000, 0, 0, JoinMatchmaking)) {
        Reconnect() ; Added Disconnect Check
        EventMovement()
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