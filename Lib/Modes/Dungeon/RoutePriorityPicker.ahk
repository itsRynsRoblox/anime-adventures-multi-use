global RoutePrioritySelector := Gui("+AlwaysOnTop")
RoutePrioritySelector.SetFont("s10 bold", "Segoe UI")
RoutePrioritySelector.BackColor := "0c000a"
RoutePrioritySelector.MarginX := 20
RoutePrioritySelector.MarginY := 20
RoutePrioritySelector.Title := "Route Priority"

RoutePriorityOrder := RoutePrioritySelector.Add("GroupBox", "x30 y25 w180 h200  +Center cWhite", "Route Priority Order")

roomOptions := ["Rare_Chest", "Chest", "Hoard", "Shop", "Shrine", "Boss"]

numDropDowns := roomOptions.Length
yStart := 50
ySpacing := 28

global routeDropDowns := []

Loop numDropDowns {
    yPos := yStart + ((A_Index - 1) * ySpacing)
    dropDown := RoutePrioritySelector.Add("DropDownList", Format("x60 y{} w135 Choose1", yPos), roomOptions)
    routeDropDowns.Push(dropDown)
    AttachDropDownEvent(dropDown, A_Index, OnRouteDropDownChange)
}

OpenRoutePriorityPicker() {
    RoutePrioritySelector.Show()
}

global routePriorityOrder := ["Rare_Chest", "Chest", "Hoard", "Shop", "Shrine", "Boss"]

OnRouteDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        routePriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        }
        RemoveEmptyStrings(routePriorityOrder)
        SaveDungeonLocal()
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}