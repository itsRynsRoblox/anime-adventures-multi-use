global RoutePrioritySelector := Gui("+AlwaysOnTop")
RoutePrioritySelector.SetFont("s10 bold", "Segoe UI")
RoutePrioritySelector.BackColor := "0c000a"
RoutePrioritySelector.MarginX := 20
RoutePrioritySelector.MarginY := 20
RoutePrioritySelector.Title := "Route Priority"

RoutePriorityOrder := RoutePrioritySelector.Add("GroupBox", "x30 y25 w180 h180  +Center cWhite", "Route Priority Order")

roomOptions := ["MultiChest", "Chest", "Hoard", "Shop", "Shrine"]

numDropDowns := 19
yStart := 50
ySpacing := 28

global routeDropDowns := []

For index, room in roomOptions {
    if (index > numDropDowns)
        Break
    yPos := yStart + ((index - 1) * ySpacing)
    RoutePrioritySelector.Add("Text", Format("x38 y{} w30 h17 +0x200 cWhite", yPos), index)
    dropDown := RoutePrioritySelector.Add("DropDownList", Format("x60 y{} w135 Choose{}", yPos, index), roomOptions)
    routeDropDowns.Push(dropDown)

    AttachRouteDropDownEvent(dropDown, index)
}

OpenRoutePriorityPicker() {
    RoutePrioritySelector.Show()
}

global routePriorityOrder := ["MultiChest", "Chest", "Hoard", "Shop", "Shrine"]

AttachRouteDropDownEvent(dropDown, index) {
    dropDown.OnEvent("Change", (*) => OnRouteDropDownChange(dropDown, index))
}

RemoveRouteEmptyStrings(array) {
    for index, value in array {
        if (value = "") {
            array.RemoveAt(index)
        }
    }
}

OnRouteDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        routePriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        }
        RemoveRouteEmptyStrings(routePriorityOrder)
        SaveDungeonLocal
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}