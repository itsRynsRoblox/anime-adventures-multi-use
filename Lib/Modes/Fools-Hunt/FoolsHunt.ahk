#Requires AutoHotkey v2.0

CheckForFoolBuffs() {
    CheckForRandomBuff()
    CheckForAstralGate()
    CheckForAstralSummon()
    CheckForClone()
    CheckForMerge()
    CheckForRefund()
}

CheckForRandomBuff() {
    global successfulCoordinates, maxedCoordinates
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.35, 0.35, RandomBuff)) {
        ; Prefer maxedCoordinates
        if maxedCoordinates.Length > 0 {
            randomIndex := Random(1, maxedCoordinates.Length)
            coord := maxedCoordinates[randomIndex]

            AddToLog("Found random buff, applying to maxed unit at X" coord.x " Y" coord.y)
            FixClick(X, Y - 20)
            Sleep(500)
            FixClick(coord.x, coord.y)
            Sleep(250)
            return true
        }
        ; Otherwise use successfulCoordinates
        else if successfulCoordinates.Length > 0 {
            randomIndex := Random(1, successfulCoordinates.Length)
            coord := successfulCoordinates[randomIndex]

            AddToLog("Found random buff, applying to random unit at X" coord.x " Y" coord.y)
            FixClick(X, Y - 20)
            Sleep(500)
            FixClick(coord.x, coord.y)
            Sleep(250)
            return true
        }
    }
    return false
}

CheckForClone() {
    global successfulCoordinates, maxedCoordinates
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.25, 0.25, Clone)) {
        ; Prefer maxedCoordinates
        if maxedCoordinates.Length > 0 {
            randomIndex := Random(1, maxedCoordinates.Length)
            coord := maxedCoordinates[randomIndex]

            AddToLog("Found clone, applying to maxed unit at X" coord.x " Y" coord.y)
            FixClick(X, Y - 20)
            Sleep(500)
            FixClick(coord.x, coord.y)
            Sleep(250)
            return true
        }
        ; Otherwise use successfulCoordinates
        else if successfulCoordinates.Length > 0 {
            randomIndex := Random(1, successfulCoordinates.Length)
            coord := successfulCoordinates[randomIndex]

            AddToLog("Found clone, applying to random unit at X" coord.x " Y" coord.y)
            FixClick(X, Y - 20)
            Sleep(500)
            FixClick(coord.x, coord.y)
            Sleep(250)
            return true
        }
    }
    return false
}

CheckForMerge() {
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.25, 0.25, Merge)) {
        AddToLog("Found merge, deleting buff...")
        FixClick(X + 15, Y - 45)
        Sleep(500)
        Sleep(250)
        return true
    }
    return false
}

CheckForRefund() {
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.25, 0.25, Refund)) {
        AddToLog("Found refund, deleting buff...")
        FixClick(X + 15, Y - 45)
        Sleep(500)
        return true
    }
    return false
}

CheckForAstralGate() {
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.35, 0.35, AstralGate)) {
        AddToLog("Found astral gate, attempting to use...")
        FindText().Click(X, Y)
        Sleep(500)
        return true
    }
    return false
}

CheckForAstralSummon() {
    if (ok := FindText(&X, &Y, 255, 561, 551, 605, 0.25, 0.25, AstralSummon)) {
        AddToLog("Found astral summon, attempting to use...")
        FindText().Click(X, Y)
        Sleep(500)
        return true
    }
    return false
}

ClickAndHoldExit() {
    if WinExist(rblxID) {
        WinMove(-10, 15, 800, 600, rblxID)
        WinActivate(rblxID)
        Sleep 1000
    }
    AddToLog("Freezing client for 2 minutes...")
    FreezeClient(777, -6, 120000) ; Freeze Client for 2 minutes before resuming
    AddToLog("Unfroze client")
    Sleep (1000)
    moveRobloxWindow()
}