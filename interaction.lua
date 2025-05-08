SquareSelected = { x = nil, y = nil } -- the square the mouse is hovering over

function UpdateSelectedSquare()
    local mx, my = love.mouse.getPosition()

    for rowIndex, row in ipairs(Grid) do
        for squareIndex, square in ipairs(row) do
            local x, y = GetSquareCoords(squareIndex, rowIndex)
            if zutil.touching(mx, my, 0, 0, x, y, SquareGlobalData.width, SquareGlobalData.height) then
                SquareSelected.x, SquareSelected.y = squareIndex, rowIndex
                return
            end
        end
    end

    SquareSelected.x, SquareSelected.y = nil, nil
end

function PopSquare(x, y)
    local squareX, squareY = GetSquareCoords(x, y)
    for _ = 1, 30 do
        local rgb = 1-Grid[y][x]/2
        table.insert(Particles, NewParticle(squareX+SquareGlobalData.width/2, squareY+SquareGlobalData.height/2, math.random()*8+2, {rgb,rgb,rgb}, math.random(6,15), math.random(360), 0, math.random(20,50), function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.3 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end

    Grid[y][x] = 0
    zutil.playsfx(SFX.pop, .4, 1)
    zutil.playsfx(SFX.collect, .4, (CalculateClearGoal()-ClearGoal)/CalculateClearGoal()+1)

    ClearGoal = ClearGoal - 1

    if ClearGoal <= 0 then
        FilesCompleted = FilesCompleted + 1
        ClearGoal = CalculateClearGoal()
        zutil.playsfx(SFX.fileComplete, .6, 1)

        GridGlobalData.generationAnimation.running = true
        GridGlobalData.generationAnimation.max = 0.88*60
        GridGlobalData.generationAnimation.becauseWrong = false
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and SquareSelected.x ~= nil and SquareSelected.y ~= nil then
        UpdateSelectedSquare()

        if CheckIsAnomaly(SquareSelected.x, SquareSelected.y) then
            PopSquare(SquareSelected.x, SquareSelected.y)
        else
            zutil.playsfx(SFX.notAnAnomaly, .8, 1)

            ClearGoal = CalculateClearGoal()
            GridGlobalData.generationAnimation.running = true
            GridGlobalData.generationAnimation.max = 0.22*60
            GridGlobalData.generationAnimation.becauseWrong = true
        end
    end
end