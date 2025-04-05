global MapSkipPrioritySelector := Gui("+AlwaysOnTop")
MapSkipPrioritySelector.SetFont("s10 bold", "Segoe UI")
MapSkipPrioritySelector.BackColor := "0c000a"
MapSkipPrioritySelector.MarginX := 20
MapSkipPrioritySelector.MarginY := 20
MapSkipPrioritySelector.Title := "Skipped Maps"

MapSkipGroup := MapSkipPrioritySelector.Add("GroupBox", "x30 y25 w180 h260  +Center cWhite", "Skipped Maps")

mapOptions := ["None", "Ant Kingdom", "Magic Hills"]

numDropDowns := 19
yStart := 50
ySpacing := 28

global mapDropDowns := []
global enabledMapSkips := []

For index, maps in mapOptions {
    if (index > numDropDowns)
        Break
    yPos := yStart + ((index - 1) * ySpacing)
    MapSkipPrioritySelector.Add("Text", Format("x38 y{} w30 h17 +0x200 cWhite", yPos), index)
    dropDown := MapSkipPrioritySelector.Add("DropDownList", Format("x60 y{} w135 Choose1", yPos), mapOptions)
    mapDropDowns.Push(dropDown)

    AttachMapDropDownEvent(dropDown, index)
}

OpenMapSkipPriorityPicker() {
    MapSkipPrioritySelector.Show()
}

global mapSkipPriorityOrder := ["None", "Ant Kingdom", "Magic Hills"]

AttachMapDropDownEvent(dropDown, index) {
    dropDown.OnEvent("Change", (*) => OnMapDropDownChange(dropDown, index))
}

RemoveMapEmptyStrings(array) {
    for index, value in array {
        if (value = "") {
            array.RemoveAt(index)
        }
    }
}

OnMapDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        mapSkipPriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Map Skip Priority {} set to {}", index, ctrl.Text))
        }
        RemoveMapEmptyStrings(mapSkipPriorityOrder)
        UpdateEnabledMapSkips()
        SaveMapSkipLocal
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}

UpdateEnabledMapSkips() {
    global enabledMapSkips
    enabledMapSkips := []
    for index, map in mapSkipPriorityOrder {
        if (map != "" and map != "None") {
            enabledMapSkips.Push(map)
        }
    }
}

ShouldSkipMap(map) {
    global enabledMapSkips
    return HasMapValue(enabledMapSkips, map)
}

HasMapValue(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}