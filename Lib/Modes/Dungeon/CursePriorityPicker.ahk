global CursePrioritySelector := Gui("+AlwaysOnTop")
CursePrioritySelector.SetFont("s10 bold", "Segoe UI")
CursePrioritySelector.BackColor := "0c000a"
CursePrioritySelector.MarginX := 20
CursePrioritySelector.MarginY := 20
CursePrioritySelector.Title := "Avoided Curses"

CursePriorityOrder := CursePrioritySelector.Add("GroupBox", "x30 y25 w180 h260  +Center cWhite", "Avoided Curses")

curseOptions := ["None", "Flying", "Wind", "Money", "Health", "Exploding", "Shielding", "Regen"]

numDropDowns := curseOptions.Length
yStart := 50
ySpacing := 28

global curseDropDowns := []
global enabledCurses := []

Loop numDropDowns {
    yPos := yStart + ((A_Index - 1) * ySpacing)
    dropDown := CursePrioritySelector.Add("DropDownList", Format("x60 y{} w135 Choose1", yPos), curseOptions)
    curseDropDowns.Push(dropDown)
    AttachDropDownEvent(dropDown, A_Index, OnCurseDropDownChange)
}

OpenCursePriorityPicker() {
    CursePrioritySelector.Show()
}

global cursePriorityOrder := ["None", "Flying", "Wind", "Money", "Health", "Exploding", "Shielding", "Regen"]


OnCurseDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        cursePriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        }
        RemoveEmptyStrings(cursePriorityOrder)
        UpdateEnabledCurses()
        SaveDungeonLocal()
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}

UpdateEnabledCurses() {
    global enabledCurses
    enabledCurses := []
    for index, curse in cursePriorityOrder {
        if (curse != "" and curse != "None") {
            enabledCurses.Push(curse)
        }
    }
}

ShouldSkipCurse(curse) {
    global enabledCurses
    return HasValue(enabledCurses, curse)
}

LogSkippedCurses() {
    global enabledCurses
    if (enabledCurses.Length > 0) {
        AddToLog("Skipped Curses: " . StringJoin(enabledCurses))
    } else {
        AddToLog("No curses are skipped.")
    }
}