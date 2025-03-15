#Include %A_ScriptDir%\Lib\gui.ahk
#Include %A_ScriptDir%\Main.ahk
#Include %A_ScriptDir%\Lib\PriorityPicker.ahk

SaveDungeonConfig(*) {
    SaveDungeonLocal
    return
}

LoadDungeonConfig(*) {
    LoadDungeonLocal
    return
}

SaveDungeonConfigToFile(filePath) {
    directory := "Settings"

    if !DirExist(directory) {
        DirCreate(directory)
    }
    if !FileExist(filePath) {
        FileAppend("", filePath)
    }

    File := FileOpen(filePath, "w")
    if !File {
        AddToLog("Failed to save the dungeon configuration.")
        return
    }

    File.WriteLine("[RoutePriority]")
    for index, dropDown in routeDropDowns
    {
        File.WriteLine(Format("Room{}={}", index+1, dropDown.Text))
    }

    File.Close()
    if (debugMessages) {
        AddToLog("Dungeon configuration saved successfully to " filePath ".`n")
    }
}

LoadDungeonConfigFromFile(filePath) {
    global routeDropDowns

    if !FileExist(filePath) {
        AddToLog("No dungeon configuration file found. Creating new local configuration.")
	SaveDungeonLocal
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
            if (section = "RoutePriority") {
                if RegExMatch(line, "Room(\d+)=(\w+)", &match) {
                    slot := match.1
                    value := match.2

                    priorityOrder[slot - 1] := value

                    dropDown := routeDropDowns[slot - 1]

                    if (dropDown) {
                        dropDown.Text := value
                    }
		    
                }
            }
        }
        file.Close()
        if (debugMessages) {
            AddToLog("Dungeon configuration loaded successfully.")
        }
    }
}


SaveDungeonLocal(*) {
    SaveDungeonConfigToFile("Settings\RoutePriority.txt")
}

LoadDungeonLocal(*) {
    LoadDungeonConfigFromFile("Settings\RoutePriority.txt")
}