Grid = {}

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

FilesCompleted = 0



function NewFile()
    CalculateGridSize()

    for y = 1, GridGlobalData.height do
        Grid[y] = {}
        for x = 1, GridGlobalData.width do
            Grid[y][x] = math.random(0,2)
        end
    end
end

function UpdateFileGenerationAnimation()
    if not GridGlobalData.generationAnimation.running then return end

    GridGlobalData.generationAnimation = zutil.updatetimer(GridGlobalData.generationAnimation, function ()
        GridGlobalData.generationAnimation.running = false
    end, 1, GlobalDT)
    NewFile()
end

function CalculateGridSize()
    GridGlobalData.width = FilesCompleted + 5
    GridGlobalData.height = GridGlobalData.width
end
function CalculateClearGoal()
    return math.floor(GridGlobalData.width * GridGlobalData.height / 15)
end

function DrawGrid()
    for rowIndex, row in ipairs(Grid) do
        for squareIndex, square in ipairs(row) do
            local x, y = GetSquareCoords(squareIndex, rowIndex)
            love.graphics.setColor(0,0,0, square/2)
            love.graphics.rectangle("fill", x, y, SquareGlobalData.width, SquareGlobalData.height)
        end
    end

    local anchorX, anchorY = GetGridAnchorCoords()
    local spacing = 10
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", anchorX - spacing, anchorY - spacing, #Grid[1] * SquareGlobalData.width + spacing * 2, #Grid * SquareGlobalData.height + spacing * 2)
end
function DrawClearGoal()
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(Fonts.cleargoal)
    love.graphics.print("CLEAR " .. ClearGoal .. " MORE ANOMALIES", 10, 10)
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
            return false
        end
    end

    for _, condition in ipairs(conditionsForAnomaly) do
        if condition then
            return true
        end
    end

    return false
end