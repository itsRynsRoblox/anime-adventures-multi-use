#Include %A_ScriptDir%\Lib\gui.ahk
#Include %A_ScriptDir%\Main.ahk
#Include %A_ScriptDir%\Lib\PriorityPicker.ahk

SaveWinterConfig(*) {
    SaveWinterLocal
    return
}

LoadWinterConfig(*) {
    LoadWinterLocal
    return
}

SaveWinterConfigToFile(filePath) {
    global PlacementPatternDropdown
    directory := "Settings"

    if !DirExist(directory) {
        DirCreate(directory)
    }
    if !FileExist(filePath) {
        FileAppend("", filePath)
    }

    File := FileOpen(filePath, "w")
    if !File {
        AddToLog("Failed to save the winter configuration.")
        return
    }

    File.WriteLine("[CardPriority]")
    for index, dropDown in dropDowns
    {
        File.WriteLine(Format("Card{}={}", index+1, dropDown.Text))
    }

    File.Close()
    AddToLog("Winter configuration saved successfully to " filePath ".`n")
}

LoadWinterConfigFromFile(filePath) {
    global dropDowns

    if !FileExist(filePath) {
        AddToLog("No winter configuration file found. Creating new local configuration.")
	SaveWinterLocal
    } else {
        ; Open file for reading
        file := FileOpen(filePath, "r", "UTF-8")
        if !file {
            AddToLog("Failed to load the configuration.")
            return
        }

        section := ""
        ; Read settings from the file
        while !file.AtEOF {
            line := file.ReadLine()

            ; Detect section headers
            if RegExMatch(line, "^\[(.*)\]$", &match) {
                section := match.1
                continue
            }

            ; Process the lines based on the section
            if (section = "CardPriority") {
                if RegExMatch(line, "Card(\d+)=(\w+)", &match) {
                    slot := match.1
                    value := match.2

                    priorityOrder[slot - 1] := value

                    dropDown := dropDowns[slot - 1]

                    if (dropDown) {
                        dropDown.Text := value
                    }
		    
                }
            }
        }
        file.Close()
        AddToLog("Winter configuration loaded successfully.")
    }
}


SaveWinterLocal(*) {
    SaveWinterConfigToFile("Settings\CardPriority.txt")
}

LoadWinterLocal(*) {
    LoadWinterConfigFromFile("Settings\CardPriority.txt")
}