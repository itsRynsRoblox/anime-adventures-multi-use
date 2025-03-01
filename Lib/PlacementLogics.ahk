#Requires AutoHotkey v2.0

; circle coordinates
GenerateCirclePoints() {
    points := []
    
; Define each circle's radius
radius1 := 45    ; First circle 
radius2 := 90    ; Second circle 
radius3 := 135   ; Third circle 
radius4 := 180   ; Fourth circle 

; Angles for 8 evenly spaced points (in degrees)
angles := [0, 45, 90, 135, 180, 225, 270, 315]

; First circle points
for angle in angles {
    radians := angle * 3.14159 / 180
    x := centerX + radius1 * Cos(radians)
    y := centerY + radius1 * Sin(radians)
    points.Push({ x: Round(x), y: Round(y) })
}

; Second circle points with more angles
angles2 := [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5]
for angle in angles2 {
    radians := angle * 3.14159 / 180
    x := centerX + radius2 * Cos(radians)
    y := centerY + radius2 * Sin(radians)
    points.Push({ x: Round(x), y: Round(y) })
}
    
    ; third circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius3 * Cos(radians)
        y := centerY + radius3 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ;  fourth circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius4 * Cos(radians)
        y := centerY + radius4 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points row by row
    Loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)
        
        ; Generate each point in the current row
        Loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

GenerateMoreGridPoints(gridWidth := 5) {  ; Adjust grid width (must be an odd number)
    points := []
    gridSize := 30  ; Space between points

    centerX := GetWindowCenter(rblxID).x
    centerY := GetWindowCenter(rblxID).y

    directions := [[1, 0], [0, 1], [-1, 0], [0, -1]]  ; Right, Down, Left, Up (1-based index)

    x := centerX
    y := centerY
    step := 1
    dirIndex := 1  ; Start at index 1 (AutoHotkey is 1-based)
    moves := 0
    stepsTaken := 0

    points.Push({x: x, y: y})  ; Start at center

    Loop (gridWidth * gridWidth - 1) {  ; Fill remaining slots
        dx := directions[dirIndex][1] * gridSize
        dy := directions[dirIndex][2] * gridSize
        x += dx
        y += dy
        points.Push({x: x, y: y})

        moves++
        stepsTaken++

        if (moves = step) {  ; Change direction
            moves := 0
            dirIndex := (dirIndex = 4) ? 1 : dirIndex + 1  ; Rotate through 1-4

            if (stepsTaken // 2 = step) {  ; Expand step after two full cycles
                step++
                stepsTaken := 0
            }
        }
    }

    return points
}

Generate3x3GridPoints() {
    points := []
    gridSize := 30  ; Space between points
    gridSizeHalf := gridSize // 2
    
    ; Center point coordinates
    centerX := GetWindowCenter(rblxID).x - 30
    centerY := GetWindowCenter(rblxID).y - 30
    
    ; Define movement directions: right, down, left, up
    directions := [[1, 0], [0, 1], [-1, 0], [0, -1]]
    
    ; Spiral logic for a 3x3 grid
    x := centerX
    y := centerY
    step := 1  ; Number of steps in the current direction
    dirIndex := 0  ; Current direction index
    moves := 0  ; Move count to switch direction
    
    points.Push({x: x, y: y})  ; Start at center
    
    Loop 8 {  ; Fill remaining 8 spots (3x3 grid has 9 total)
        dx := directions[dirIndex + 1][1] * gridSize
        dy := directions[dirIndex + 1][2] * gridSize
        x += dx
        y += dy
        points.Push({x: x, y: y})
        
        moves++
        if (moves = step) {  ; Change direction
            moves := 0
            dirIndex := Mod(dirIndex + 1, 4)  ; Rotate through 4 directions
            if (dirIndex = 0 || dirIndex = 2) {
                step++  ; Increase step size after every two direction changes
            }
        }
    }
    
    return points
}

GenerateMore3x3GridPoints() {
    static points := []  ; Persistently store generated points
    static centerX := GetWindowCenter(rblxID).x - 30
    static centerY := GetWindowCenter(rblxID).y - 30
    static gridOffsetX := 0
    static gridOffsetY := 0
    
    gridSize := 30  ; Space between points
    
    ; Generate a new 3x3 grid when needed
    if (points.Length = 0 || Mod(points.Length, 9) = 0) {
        newGrid := []
        
        ; Update the center for the next grid
        centerX += 3 * gridSize * (gridOffsetX := Mod(gridOffsetX + 1, 2))
        centerY += 3 * gridSize * (gridOffsetX = 0 ? ++gridOffsetY : gridOffsetY)

        ; Generate new 3x3 grid
        Loop 3 {
            rowY := centerY + (A_Index - 2) * gridSize
            Loop 3 {
                colX := centerX + (A_Index - 2) * gridSize
                newGrid.Push({x: colX, y: rowY})
            }
        }
        
        ; Add new grid points to the main list
        points.Push(newGrid*)
    }
    
    return points  ; Return all points accumulated
}

; Spiral coordinates (restricted to a rectangle)
GenerateSpiralPoints(rectX := 4, rectY := 123, rectWidth := 795, rectHeight := 433) {
    points := []
    
    ; Calculate center of the rectangle
    centerX := GetWindowCenter(rblxID).x - 30
    centerY := GetWindowCenter(rblxID).y - 30
    
    ; Angle increment per step (in degrees)
    angleStep := 30
    ; Distance increment per step (tighter spacing)
    radiusStep := 10
    ; Initial radius
    radius := 20
    
    ; Maximum radius allowed (smallest distance from center to edge)
    maxRadiusX := (rectWidth // 2) - 1
    maxRadiusY := (rectHeight // 2) - 1
    maxRadius := Min(maxRadiusX, maxRadiusY)

    ; Generate spiral points until reaching max boundary
    Loop {
        ; Stop if the radius exceeds the max boundary
        if (radius > maxRadius)
            break
        
        angle := A_Index * angleStep
        radians := angle * 3.14159 / 180
        x := centerX + radius * Cos(radians)
        y := centerY + radius * Sin(radians)
        
        ; Check if point is inside the rectangle
        if (x < rectX || x > rectX + rectWidth || y < rectY || y > rectY + rectHeight)
            break ; Stop if a point goes out of bounds
        
        points.Push({ x: Round(x), y: Round(y) })
        
        ; Increase radius for next point
        radius += radiusStep
    }
    
    return points
}

GenerateUpandDownPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points column by column (left to right)
    Loop squaresPerSide {
        currentColumn := A_Index
        x := startX + ((currentColumn - 1) * gridSize)
        
        ; Generate each point in the current column
        Loop squaresPerSide {
            y := startY + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary
    
    ; Generate 40 random points
    Loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)
        
        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x)**2 + (y - existingPoint.y)**2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }
        
        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({x: x, y: y})
    }
    
    ; Always add center point last (so it's used last)
    points.Push({x: centerX, y: centerY})
    
    return points
}

;---------LEGACY PLACEMENT CODE---------;
rect1 := { x: 37, y: 45, width: 254, height: 69 }
rect2 := { x: 591, y: 45, width: 243, height: 47 }
rect3 := { x: 36, y: 594, width: 105, height: 51 }

isInsideRect(rect, x, y) {
    return (x >= rect.x and x <= rect.x + rect.width and y >= rect.y and y <= rect.y + rect.height)
}

global startX := 200, startY := 500, endX := 700, endY := 350
global startY2 := 200, endY2 := 350
global step := 50 ; Step size for grid traversal

;By @keirahela
;Modified by @Haie (smaller steps, centered start)
SpiralPlacement(gridPlacement := false) {
    global startX, startY, endX, endY, step, successfulCoordinates, maxedCoordinates
    successfulCoordinates := [] ; Reset successfulCoordinates for each run
    maxedCoordinates := []
    savedPlacements := Map()

    centerX := GetWindowCenter(rblxID).x - 30
    centerY := GetWindowCenter(rblxID).y - 30
    radius := step
    direction := [[1, 0], [0, 1], [-1, 0], [0, -1]]
    dirIndex := 0
    directionCount := 0

    ; Iterate through all slots (1 to 6)
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "Enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        placements := "Placement" slotNum
        placements := %placements%
        placements := placements.Text

        ; Skip if the slot is not enabled
        if !(enabled = 1) {
            continue
        }

        AddToLog("Starting placements for Slot " slotNum " with " placements " placements.")

        placementCount := 0
        currentX := centerX
        currentY := centerY
        steps := 30
        maxSteps := 5

        while (placementCount < placements) {
            for index, stepSize in [steps] {

                if PlaceUnit(currentX, currentY, slotNum) {
                    placementCount++
                    successfulCoordinates.Push({ x: currentX, y: currentY, slot: "slot_" slotNum }) ; Track successful placements
					
					try {
                        if savedPlacements.Get("slot_" slotNum) {
                            savedPlacements.Set("slot_" slotNum, savedPlacements.Get("slot_" slotNum) + 1)
                        }
                    } catch {
                        savedPlacements.Set("slot_" slotNum, 1)
                    }

                    if placementCount >= placements {
                        break
                    }
		
                    if (gridPlacement) {
                        PlaceInGrid(currentX, currentY, slotNum, &placementCount, &successfulCoordinates, & savedPlacements, &placements)
                    }

                }
		

                CheckForCardSelection()
                
				FixClick(284, 400) ; next
				FixClick(60, 450) ; move mouse
                if CheckForXp() {
                    return MonitorStage()
                }
                Reconnect()

                currentX += direction[dirIndex + 1][1] * steps
                currentY += direction[dirIndex + 1][2] * steps

                currentX += Random(-15, 15)
                currentY += Random(-15, 15)

                if isInsideRect(rect1, currentX, currentY) or isInsideRect(rect2, currentX, currentY) or isInsideRect(
                    rect3, currentX, currentY) {
                    steps := 30
                    currentX := centerX
                    currentY := centerY
                }

                if currentX > 635 or currentY > 520 or currentX <= 190 or currentY < 150 {
                    steps := 30
                    currentX := centerX
                    currentY := centerY
                }
            }

            directionCount++

            if directionCount == 2 {
                steps += 30
                directionCount := 0
            }

            dirIndex := Mod(dirIndex + 1, 4)
            if CheckForXp() {
                return MonitorStage()
            }
            Reconnect()
            CheckEndAndRoute()
        }

        AddToLog("Completed " placementCount " placements for Slot " slotNum ".")
    }

    UpgradeUnits()
    AddToLog("Upgrade Units 1")

    AddToLog("All slot placements and upgrades completed.")
    MonitorStage()
}

PlaceInGrid(startX, startY, slotNum, &placementCount, &successfulCoordinates, &savedPlacements, &placements) {
    ; Places untis in a 2x2 grid, starting from the top left where the initial unit is placed (as dictated by startX and startY)
    gridOffsets := [
    [30, 0],  ; Row 1, Column 0
    [0, 30],  ; Row 0, Column 1
    [30, 30],   ; Row 1, Column 1
	[-30, -30],
	[-30, 30],
	[-30, 0],
	[0, -30],
	[30, -30]
    ]
    for index, offset in gridOffsets {

        ; Adds the value that's stored in the array at the current index to either x or y's starting location
        gridX := startX + offset[2] ; Move horizontally by 'step' from the initial start location
        gridY := startY + offset[1] ; Move vertically by 'step' from the initial start location
		
        ; Handle card picker and related logic during grid placement
		if (ok := FindText(&cardX, &cardY, 196, 204, 568, 278, 0, 0, pick_card)) {
			cardSelector()
		}
        FixClick(284, 400) ; next
        FixClick(60, 450) ; move mouse
        if CheckForXp() {
            return MonitorStage()
        }
        Reconnect()

        if PlaceUnit(gridX, gridY, slotNum) {
            placementCount++ ; Increment the placement count
            successfulCoordinates.Push({ x: gridX, y: gridY, slot: "slot_" slotNum }) ; Track the placement
            AddToLog("Placed unit at (" gridX ", " gridY ") in 3x3 grid.")

            ; Update or initialize saved placements for the current slot
            try {
                if savedPlacements.Get("slot_" slotNum) {
                    savedPlacements.Set("slot_" slotNum, savedPlacements.Get("slot_" slotNum) + 1)
                }
            } catch {
                savedPlacements.Set("slot_" slotNum, 1)
            }
            ; Check if placement limit is reached
            if placementCount >= placements {
                break
            }

        }

    }

}