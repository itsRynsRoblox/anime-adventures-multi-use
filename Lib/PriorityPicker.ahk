; updated card priority from @haie's event macro
global PriorityCardSelector := Gui("+AlwaysOnTop")
PriorityCardSelector.SetFont("s10 bold", "Segoe UI")
PriorityCardSelector.BackColor := "0c000a"
PriorityCardSelector.MarginX := 20
PriorityCardSelector.MarginY := 20
PriorityCardSelector.Title := "Card Priority"

PriorityOrder := PriorityCardSelector.Add("GroupBox", "x30 y25 w180 h570 cWhite", "Modifier Priority Order")

options := ["new_path", "range_3", "attack_3", "cooldown_3", "range_2", "attack_2", "cooldown_2", "blessing_2", "range_1", "attack_1", "cooldown_1", "blessing_1", "shield", "explosive_death_21", "explosive_death_3", "speed", "health", "regen", "yen"]

numDropDowns := 19
yStart := 50
ySpacing := 28

global dropDowns := []

For index, card in options {
    if (index > numDropDowns)
        Break
    yPos := yStart + ((index - 1) * ySpacing)
    PriorityCardSelector.Add("Text", Format("x38 y{} w30 h17 +0x200 cWhite", yPos), index)
    dropDown := PriorityCardSelector.Add("DropDownList", Format("x60 y{} w135 Choose{}", yPos, index), options)
    dropDowns.Push(dropDown)

    AttachDropDownEvent(dropDown, index)
}

DebuffGroupbox := PriorityCardSelector.Add("GroupBox", "x30 y610 w180 h120 cWhite", "Debuff Priority")
RadioRandom := PriorityCardSelector.Add("Radio", "x54 y630 w120 h23 cWhite Checked", "Random Tier")
RadioHighest := PriorityCardSelector.Add("Radio", "x54 y655 w120 h23 cWhite", "Highest Tier")
PriorityCardSelector.Add("Text", "x12 x54 y680 w180 cWhite +BackgroundTrans", "Random = Pick any")
PriorityCardSelector.Add("Text", "x12 x54 y700 w180 cWhite +BackgroundTrans", "Highest = Tier 3>2>1")

OpenPriorityPicker() {
    PriorityCardSelector.Show()
}

global priorityOrder := ["new_path", "range_3", "attack_3", "cooldown_3", "range_2", "attack_2", "cooldown_2", "blessing_2", "range_1", "attack_1", "cooldown_1", "blessing_1", "shield", "explosive_death_21", "explosive_death_3", "speed", "health", "regen", "yen"]

priority := []

AttachDropDownEvent(dropDown, index) {
    dropDown.OnEvent("Change", (*) => OnDropDownChange(dropDown, index))
}

RemoveEmptyStrings(array) {
    for index, value in array {
        if (value = "") {
            array.RemoveAt(index)
        }
    }
}

OnDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        priorityOrder[index] := ctrl.Text
        AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        RemoveEmptyStrings(priorityOrder)
    } else {
        AddToLog(Format("Invalid index {} for dropdown", index))
    }
}