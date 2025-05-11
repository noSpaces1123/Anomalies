Grid = {}
PinGrid = {}

GridGlobalData = {
    width = 20, height = 20, -- in squares
    generationAnimation = {
        current = 0, max = 0.88*60, running = false,
        becauseWrong = false,
    },
}
SquareGlobalData = {
    width = 30, height = 30,-- in px
}

ClearGoal = 0

Trails = {}
TrailUpdateInterval = { current = 0, max = .2*60 }
TrailSpawnInterval = { current = 0, max = 30*60 }

FilesCompleted = 0

ConditionsCollected = 2



function NewFile()
    CalculateGridSize()

    for y = 1, GridGlobalData.height do
        Grid[y] = {}
        PinGrid[y] = {}
        for x = 1, GridGlobalData.width do
            Grid[y][x] = math.random(0,2)
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
    GridGlobalData.width = math.floor(FilesCompleted / 3) + 5
    GridGlobalData.height = GridGlobalData.width
end
function CalculateClearGoal()
    return math.floor(GridGlobalData.width * GridGlobalData.height / 20)
end

function DrawGrid()
    if Wheel.running then return end

    local anchorX, anchorY = GetGridAnchorCoords()
    local spacing = 10
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)

    for rowIndex, row in ipairs(Grid) do
        for squareIndex, square in ipairs(row) do
            local x, y = GetSquareCoords(squareIndex, rowIndex)
            love.graphics.setColor(0,0,0, square/2)
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

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)
end

function GetGridAnchorCoords()
    return WINDOW.CENTER_X - #Grid[1] / 2 * SquareGlobalData.width, WINDOW.CENTER_Y - #Grid / 2 * SquareGlobalData.height
end
function GetSquareCoords(x, y)
    local anchorX, anchorY = GetGridAnchorCoords()
    return (x - 1) * SquareGlobalData.width + anchorX, (y - 1) * SquareGlobalData.height + anchorY
end

function CheckIsAnomaly(x, y)
    local focus = Grid[y][x]

    if focus == 0 then return false end

    local conditionsForAnomaly = {
        Grid[zutil.clamp(y-1,1,#Grid[1])][x] == 0 and Grid[zutil.clamp(y+1,1,#Grid[1])][x] == 2,
        Grid[y][zutil.clamp(x-1,1,#Grid[1])] == 0 and Grid[y][zutil.clamp(x+1,1,#Grid[1])] == 2,
        Grid[zutil.clamp(y-2,1,#Grid)][x] == 0 and Grid[zutil.clamp(y+2,1,#Grid)][x] == 0,
        Grid[zutil.clamp(y-1,1,#Grid)][x] == focus and Grid[zutil.clamp(y+1,1,#Grid)][x] == focus,
        Grid[zutil.clamp(y+1,1,#Grid)][zutil.clamp(x+1,1,#Grid[1])] == focus and Grid[zutil.clamp(y-1,1,#Grid)][zutil.clamp(x-1,1,#Grid[1])] == focus,
    }

    local conditionsForNotAnomaly = {
        Grid[zutil.clamp(y-2,1,#Grid)][x] == 1 and Grid[zutil.clamp(y+2,1,#Grid)][x] == 1,
    }

    if ConditionsCollected > #conditionsForAnomaly then
        local nToIgnore = #conditionsForNotAnomaly - (ConditionsCollected - #conditionsForAnomaly)

        for index, condition in ipairs(conditionsForNotAnomaly) do
            if index > #conditionsForNotAnomaly - nToIgnore then break end
            if condition then
                return false, nil
            end
        end
    end

    local nToIgnore = zutil.relu(#conditionsForAnomaly - ConditionsCollected)
    local isAnomaly, conditionsMet = false, 0

    for index, condition in ipairs(conditionsForAnomaly) do
        if index > #conditionsForAnomaly - nToIgnore then break end
        if condition then
            isAnomaly = true
            conditionsMet = conditionsMet + 1
        end
    end

    return isAnomaly, conditionsMet
end
function PlaceAnomalies()
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
        Grid[self.y][self.x] = zutil.wrap(Grid[self.y][self.x] + zutil.randomchoice({-1,1}), 0, 2)

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
    zutil.updatetimer(TrailSpawnInterval, NewTrail, 1, GlobalDT)
end