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
TimeLeft = { current = 4, max = 4 } -- in seconds

Trails = {}
TrailUpdateInterval = { current = 0, max = .2*60 }
TrailSpawnInterval = { current = 0, max = 30*60 }

FilesCompleted = 0



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
        SaveData()
    end, 1, GlobalDT)

    if not GridGlobalData.generationAnimation.running then return end

    NewFile()
end

function CalculateGridSize()
    GridGlobalData.width = FilesCompleted + 5
    GridGlobalData.height = GridGlobalData.width
end
function CalculateClearGoal()
    local concluded = math.floor(GridGlobalData.width * GridGlobalData.height / 20)
    return (concluded > 0 and concluded or 1)
end

function DrawGrid()
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
                local spacing = 10
                -- love.graphics.draw(Sprites.pin, x - 11, y - 20)
                love.graphics.line(x + spacing, y + spacing, x + SquareGlobalData.width - spacing, y + SquareGlobalData.height - spacing)
                love.graphics.line(x + SquareGlobalData.width - spacing, y + spacing, x + spacing, y + SquareGlobalData.height - spacing)
            end
        end
    end

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)
end

function love.wheelmoved(_, y)
    SquareGlobalData.width = zutil.clamp(SquareGlobalData.width + y, 5, 30)

    SquareGlobalData.height = SquareGlobalData.width
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
        Grid[zutil.clamp(y-1,1,#Grid)][x] == focus and Grid[zutil.clamp(y+1,1,#Grid)][x] == focus,
        Grid[y][zutil.clamp(x-1,1,#Grid[1])] == 0 and Grid[y][zutil.clamp(x+1,1,#Grid[1])] == 2,
        Grid[zutil.clamp(y-1,1,#Grid[1])][x] == 0 and Grid[zutil.clamp(y+1,1,#Grid[1])][x] == 2,
        Grid[zutil.clamp(y-2,1,#Grid)][x] == 0 and Grid[zutil.clamp(y+2,1,#Grid)][x] == 0,
        Grid[zutil.clamp(y+1,1,#Grid)][zutil.clamp(x+1,1,#Grid[1])] == focus and Grid[zutil.clamp(y-1,1,#Grid)][zutil.clamp(x-1,1,#Grid[1])] == focus,
    }

    local conditionsForNotAnomaly = {
        Grid[zutil.clamp(y-2,1,#Grid)][x] == 1 and Grid[zutil.clamp(y+2,1,#Grid)][x] == 1,
        Grid[y][zutil.clamp(x-2,1,#Grid)] == 0 and Grid[y][zutil.clamp(x+2,1,#Grid)] == 0,
    }

    for _, condition in ipairs(conditionsForNotAnomaly) do
        if condition then
            return false, nil
        end
    end

    local isAnomaly, conditionsMet = false, 0

    for _, condition in ipairs(conditionsForAnomaly) do
        if condition then
            isAnomaly = true
            conditionsMet = conditionsMet + 1
        end
    end

    return isAnomaly, conditionsMet
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