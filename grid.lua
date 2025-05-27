Grid = {}
PinGrid = {}

GridGlobalData = {
    width = 20, height = 20, -- in squares
    generationAnimation = {
        current = 0, max = 0.88*60, running = false,
        becauseWrong = false,
    },
    introAnimation = { current = 0, max = 1, running = true },
}
SquareGlobalData = {
    width = 30, height = 30,-- in px
    defaultWidth = 30, defaultHeight = 30,
}

ClearGoal = 0

TimeUntilCorruption = { current = 0, max = 8*60 }

Trails = {}
TrailUpdateInterval = { current = 0, max = .2*60 }
TrailSpawnInterval = { current = 0, max = 30*60 }

FilesCompleted = 0

ConditionsCollected = 2



function NewFile()
    CalculateGridSize()

    Trails = {}
    Grid = {}
    PinGrid = {}

    -- Dialogue.playing.running = false
    -- Dialogue.playing.textThusFar = ""

    for y = 1, GridGlobalData.height do
        Grid[y] = {}
        PinGrid[y] = {}
        for x = 1, GridGlobalData.width do
            Grid[y][x] = tonumber(zutil.weighted(DepartmentData[CurrentDepartment].squarePalette))
            PinGrid[y][x] = false
        end
    end
end

function UpdateFileGenerationAnimation()
    if not GridGlobalData.generationAnimation.running then return end

    GridGlobalData.generationAnimation = zutil.updatetimer(GridGlobalData.generationAnimation, function ()
        GridGlobalData.generationAnimation.running = false
        PlaceAnomalies()
        SaveData()
    end, 1, GlobalDT)

    if not GridGlobalData.generationAnimation.running then return end

    NewFile()
end

function CalculateGridSize()
    DepartmentData[CurrentDepartment].findGridWidthAndHeight()
end
function CalculateClearGoal()
    return math.floor((math.floor(FilesCompleted / 3) + 5)^2 / 20)
end

function DrawGrid()
    if Spinner.running or Screen.running or Road.running or Barcode.running or RNEPractice.wait.running then return end

    local anchorX, anchorY = GetGridAnchorCoords()
    local spacing = 10
    love.graphics.setColor(Colors[CurrentDepartment].fileBg)
    love.graphics.rectangle("fill", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)

    for rowIndex, row in ipairs(Grid) do
        for squareIndex, square in ipairs(row) do
            local x, y = GetSquareCoords(squareIndex, rowIndex)

            if square == 3 then
                love.graphics.setColor(Colors[CurrentDepartment].type3Square)
            else
                love.graphics.setColor(Colors[CurrentDepartment].squares[1],Colors[CurrentDepartment].squares[2],Colors[CurrentDepartment].squares[3], square/2)
            end

            love.graphics.rectangle("fill", x, y, SquareGlobalData.width, SquareGlobalData.height)
        end
    end

    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(1)
    for rowIndex, row in ipairs(PinGrid) do
        for squareIndex, pinned in ipairs(row) do
            if pinned then
                local x, y = GetSquareCoords(squareIndex, rowIndex)
                local padding = SquareGlobalData.width / 3
                -- love.graphics.draw(Sprites.pin, x - 11, y - 20)
                love.graphics.line(x + padding, y + padding, x + SquareGlobalData.width - padding, y + SquareGlobalData.height - padding)
                love.graphics.line(x + SquareGlobalData.width - padding, y + padding, x + padding, y + SquareGlobalData.height - padding)
            end
        end
    end

    love.graphics.setLineWidth(SquareGlobalData.width/6)
    love.graphics.setColor(Colors[CurrentDepartment].fileOutline)
    love.graphics.rectangle("line", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)

    if CurrentDepartment ~= "A" then
        local ratio = TimeUntilCorruption.current / TimeUntilCorruption.max
        local easing = zutil.easing.easeInExpo
        local width = (#Grid[1] * SquareGlobalData.width + spacing * 2) * easing(ratio)
        local height = 20

        love.graphics.setColor(Colors[CurrentDepartment].fileOutline[1],Colors[CurrentDepartment].fileOutline[2],Colors[CurrentDepartment].fileOutline[3], easing(ratio))
        love.graphics.rectangle("fill", anchorX - spacing, anchorY - spacing  +  #Grid * SquareGlobalData.height + spacing * 3, width, height)
    end
end

function GetGridAnchorCoords()
    return WINDOW.CENTER_X - #Grid[1] / 2 * SquareGlobalData.width, WINDOW.CENTER_Y - #Grid / 2 * SquareGlobalData.height
end
function GetSquareCoords(x, y)
    local anchorX, anchorY = GetGridAnchorCoords()
    return (x - 1) * SquareGlobalData.width + anchorX, (y - 1) * SquareGlobalData.height + anchorY
end

function UpdateGridIntroAnimation()
    if not GridGlobalData.introAnimation.running then return end

    zutil.updatetimer(GridGlobalData.introAnimation, function ()
        GridGlobalData.introAnimation.running = false
    end, .01, GlobalDT)

    if not GridGlobalData.introAnimation.running then
        SquareGlobalData.width = SquareGlobalData.defaultWidth
        SquareGlobalData.height = SquareGlobalData.defaultHeight
        return
    end

    local ratio = zutil.easing.easeOutExpo(GridGlobalData.introAnimation.current)
    SquareGlobalData.width = ratio * SquareGlobalData.defaultWidth
    SquareGlobalData.height = ratio * SquareGlobalData.defaultHeight
end

function CheckIsAnomaly(x, y)
    local focus = Grid[y][x]

    if focus == 0 then return false end

    local conditionsForAnomaly = {}
    for _, value in ipairs(Cards) do
        table.insert(conditionsForAnomaly, EvaluateCondition(x, y, value.condition))
    end

    local nToIgnore = zutil.relu(#conditionsForAnomaly - ConditionsCollected)
    local isAnomaly, conditionsMet = false, 0

    for index, condition in ipairs(conditionsForAnomaly) do
        if index > #conditionsForAnomaly - nToIgnore then break end
        if condition.output and not condition.notAnomaly then
            isAnomaly = true
            conditionsMet = conditionsMet + 1
        elseif not condition.output and condition.notAnomaly then
            return false, conditionsMet
        end
    end

    return isAnomaly, conditionsMet
end
function EvaluateCondition(x, y, condition)
    local conditionPartOutputs = {}
    local focus = Grid[y][x]

    for _, part in ipairs(condition.parts) do
        local shouldBe0 = false

        local targetRow = Grid[y + part.offset.y]
        local target

        if not targetRow then
            shouldBe0 = true
        else
            target = Grid[y + part.offset.y][x + part.offset.x]
            if not target then shouldBe0 = true end
        end

        if shouldBe0 then target = 0 end

        local result = target == (part.type == -1 and focus or part.type)
        if condition.isNot then result = not result end

        table.insert(conditionPartOutputs, result)
    end

    local howManyAreFalse = 0
    for _, output in ipairs(conditionPartOutputs) do
        if not output then
            howManyAreFalse = howManyAreFalse + 1
            if (condition.isNot and howManyAreFalse == #conditionPartOutputs) or not condition.isNot then
                return { output = false, notAnomaly = condition.isNot }
            end
        end
    end
    return { output = true, notAnomaly = condition.isNot }
end
function PlaceAnomalies()
    if CurrentDepartment ~= "A" then return end

    for _ = 1, ClearGoal do
        local positionX, positionY = math.random(3, #Grid[1] - 2), math.random(3, #Grid - 2) -- no anomalies placed within 2 squares of the edges of the grid
        Grid[positionY][positionX] = math.random(1,2)
        local focus = Grid[positionY][positionX]

        local funcs = {
            function ()
                Grid[positionY-1][positionX] = 0
                Grid[positionY+1][positionX] = 2
            end,
            function ()
                Grid[positionY][positionX-1] = 0
                Grid[positionY][positionX+1] = 2
            end,
            function ()
                Grid[positionY-2][positionX] = 0
                Grid[positionY+2][positionX] = 0
            end,
            function ()
                Grid[positionY-1][positionX] = focus
                Grid[positionY+1][positionX] = focus
            end,
            function ()
                Grid[positionY-1][positionX-1] = focus
                Grid[positionY+1][positionX+1] = focus
            end,
        }

        local viables = {}
        for i = 1, ConditionsCollected do
            table.insert(viables, funcs[i])
        end

        zutil.randomchoice(funcs)()
    end
end



function NewTrail()
    local alongHorizontal = zutil.randomchoice({true,false})

    local x = (alongHorizontal and math.random(#Grid[1]) or zutil.randomchoice({1, #Grid[1]}))
    local y = (alongHorizontal and zutil.randomchoice({1, #Grid}) or math.random(#Grid))

    local direction
    if alongHorizontal then
        direction = (y == 1 and "down" or "up")
    else
        direction = (x == 1 and "right" or "left")
    end

    table.insert(Trails, {
        x = x, y = y,
        direction = direction,
    })
end
function UpdateTrails()
    for _, self in ipairs(Trails) do
        Grid[self.y][self.x] = zutil.wrap(Grid[self.y][self.x] + zutil.randomchoice({-1,1}), 0, (CurrentDepartment ~= "A" and 3 or 2))

        if self.direction == "up" then
            self.y = self.y - 1
        elseif self.direction == "down" then
            self.y = self.y + 1
        elseif self.direction == "left" then
            self.x = self.x - 1
        elseif self.direction == "right" then
            self.x = self.x + 1
        end

        if self.x > #Grid[1] or self.x < 1 or self.y > #Grid or self.y < 1 then
            zutil.remove(Trails, self)
        end
    end
end
function UpdateTrailUpdateInterval()
    zutil.updatetimer(TrailUpdateInterval, UpdateTrails, 1, GlobalDT)
end
function UpdateTrailSpawnInterval()
    TrailSpawnInterval.max = zutil.nilcheck(DepartmentData[CurrentDepartment].trailSpawnInterval, DepartmentData[CurrentDepartment].trailSpawnInterval, TrailSpawnInterval.max)
    zutil.updatetimer(TrailSpawnInterval, NewTrail, 1, GlobalDT)
end



function UpdateTimeUntilCorruption()
    if true or CurrentDepartment == "A" or Spinner.running or Screen.running or Road.running or GridGlobalData.generationAnimation.running or DepartmentTransition.running or RNEPractice.wait.running then return end
    if EndOfContent.showing then return end
    zutil.updatetimer(TimeUntilCorruption, function ()
        Wrong()
    end, 1, GlobalDT)
end