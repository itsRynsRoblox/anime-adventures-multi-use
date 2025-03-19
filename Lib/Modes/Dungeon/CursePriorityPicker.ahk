global CursePrioritySelector := Gui("+AlwaysOnTop")
CursePrioritySelector.SetFont("s10 bold", "Segoe UI")
CursePrioritySelector.BackColor := "0c000a"
CursePrioritySelector.MarginX := 20
CursePrioritySelector.MarginY := 20
CursePrioritySelector.Title := "Avoided Curses"

CursePriorityOrder := CursePrioritySelector.Add("GroupBox", "x30 y25 w180 h260  +Center cWhite", "Avoided Curses")

roomOptions := ["None", "Flying", "Wind", "Money", "Health", "Exploding", "Shielding", "Regen"]

numDropDowns := 19
yStart := 50
ySpacing := 28

global curseDropDowns := []
global enabledCurses := []

For index, room in roomOptions {
    if (index > numDropDowns)
        Break
    yPos := yStart + ((index - 1) * ySpacing)
    CursePrioritySelector.Add("Text", Format("x38 y{} w30 h17 +0x200 cWhite", yPos), index)
    dropDown := CursePrioritySelector.Add("DropDownList", Format("x60 y{} w135 Choose1", yPos), roomOptions)
    curseDropDowns.Push(dropDown)

    AttachCurseDropDownEvent(dropDown, index)
}

OpenCursePriorityPicker() {
    CursePrioritySelector.Show()
}

global cursePriorityOrder := ["None", "Flying", "Wind", "Money", "Health", "Exploding", "Shielding", "Regen"]

AttachCurseDropDownEvent(dropDown, index) {
    dropDown.OnEvent("Change", (*) => OnCurseDropDownChange(dropDown, index))
}

RemoveCurseEmptyStrings(array) {
    for index, value in array {
        if (value = "") {
            array.RemoveAt(index)
        }
    }
}

OnCurseDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        cursePriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        }
        RemoveCurseEmptyStrings(cursePriorityOrder)
        UpdateEnabledCurses()
        SaveDungeonLocal
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

HasValue(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}