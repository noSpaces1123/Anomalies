SquareSelected = { x = nil, y = nil } -- the square the mouse is hovering over

function UpdateSelectedSquare()
    if Wheel.running or Screen.running then return end

    local mx, my = love.mouse.getPosition()

    for rowIndex, row in ipairs(Grid) do
        for squareIndex, square in ipairs(row) do
            local x, y = GetSquareCoords(squareIndex, rowIndex)
            if zutil.touching(mx, my, 0, 0, x, y, SquareGlobalData.width, SquareGlobalData.height) then
                SquareSelected.x, SquareSelected.y = squareIndex, rowIndex
                goto continue
            end
        end
    end

    SquareSelected.x, SquareSelected.y = nil, nil

    ::continue::
end

function PopSquare(x, y, conditionsMet)
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
    zutil.playsfx(SFX.collect, .4, zutil.relu((CalculateClearGoal()-ClearGoal)/CalculateClearGoal())+1)

    ClearGoal = ClearGoal - 1

    if ClearGoal <= 0 then
        CompleteFile()
    else
        AdjustRating("anomaly found", conditionsMet)
    end

    SaveData()
end

function love.mousepressed(mx, my, button)
    if not Handbook.showing and not Wheel.running and not Screen.running then
        if button == 1 and SquareSelected.x ~= nil and SquareSelected.y ~= nil and Grid[SquareSelected.y][SquareSelected.x] > 0 then
            UpdateSelectedSquare()

            local isAnomaly, conditionsMet = CheckIsAnomaly(SquareSelected.x, SquareSelected.y)

            if isAnomaly then
                if zutil.weightedbool(100/6) then
                    _G["Start" .. zutil.randomchoice({"Wheel", "Screen"})](conditionsMet)
                else
                    PopSquare(SquareSelected.x, SquareSelected.y, conditionsMet)
                end
            else
                Wrong()
            end
        elseif button == 2 and SquareSelected.x ~= nil and SquareSelected.y ~= nil and Grid[SquareSelected.y][SquareSelected.x] > 0 then
            UpdateSelectedSquare()

            PinGrid[SquareSelected.y][SquareSelected.x] = not PinGrid[SquareSelected.y][SquareSelected.x]
            if PinGrid[SquareSelected.y][SquareSelected.x] then
                zutil.playsfx(SFX.pin, .1, 1)
            else
                zutil.playsfx(SFX.removePin, .1, 1)
            end

            zutil.playsfx(SFX.pop, .4, 1)

            SaveData()
        end

        -- pressing rewards >v<
        if button == 1 then
            local i = 1
            for index, data in ipairs(Rewards) do
                if RewardsCollected[data.name] then
                    local rx, ry = GetRewardCoords(index, i)
                    rx, ry = rx + data.sprite:getWidth()/2, ry + data.sprite:getHeight()/2
                    if zutil.distance(love.mouse.getX(), love.mouse.getY(), rx, ry) <= data.sprite:getWidth()/1.5 then
                        zutil.playsfx(SFX.stickerPress, .2, math.random()*3+2)

                        for _ = 1, 10 do
                            local color = {0,0,0}
                            color[math.random(#color)] = 1  ;  color[math.random(#color)] = 1
                            table.insert(Particles, NewParticle(rx, ry, math.random()*4+3, color, math.random()*3+1, math.random(360), .03, math.random(60,100)))
                        end
                    end

                    i = i + 1
                end
            end
        end
    elseif Wheel.running and button == 1 then
        local nHit = 0
        local hitSomething = false

        for _, self in ipairs(Wheel.windows) do
            if self.hit then nHit = nHit + 1
            elseif Wheel.pointerDegrees >= self.degrees and Wheel.pointerDegrees <= self.degrees + Wheel.windowDegreeWidth then
                self.hit = true
                zutil.playsfx(SFX.wheelHit, .3, 1 + nHit)
                hitSomething = true
                AdjustRating("hit arc")
            end
        end

        if hitSomething then
            table.insert(Wheel.goodClicks, Wheel.pointerDegrees)
        else
            table.insert(Wheel.badClicks, Wheel.pointerDegrees)
            zutil.playsfx(SFX.badClick, .5, 1)
            ShakeIntensity = 5
        end
    elseif Screen.running and Screen.shutterDone and button == 1 then
        local hit = false
        for _, self in ipairs(Screen.dots) do
            if not self.hit and zutil.distance(self.x + Screen.x, self.y + Screen.y, mx, my) <= Screen.maxError then
                self.hit = true
                zutil.playsfx(SFX.screenDot, .3, math.random() * 2 + 2)

                table.insert(Particles, NewParticle(self.x + Screen.x, self.y + Screen.y, Screen.dotRadius, {0,0,0}, 4, math.random(90,270), 0.1, 400))

                hit = true
            end
        end

        if not hit then
            Wrong()
            Screen.running = false
        end
    end

    CheckButtonsClicked(button)
end

function love.wheelmoved(_, y)
    if Handbook.showing then
        Handbook.scollYOffset = zutil.clamp(Handbook.scollYOffset + y * 7, -Handbook.pageSprites[1]:getHeight() + WINDOW.HEIGHT - Handbook.yOffset * 2, 0)
    else
        SquareGlobalData.width = zutil.clamp(SquareGlobalData.width + y, 5, 30)

        SquareGlobalData.height = SquareGlobalData.width
    end
end

function Wrong()
    zutil.playsfx(SFX.notAnAnomaly, .8, 1)

    StartDialogue("list", "wrong")

    AdjustRating("not an anomaly")

    CalculateGridSize()
    ClearGoal = zutil.clamp(ClearGoal + 5, 0, CalculateClearGoal())
    GridGlobalData.generationAnimation.running = true
    GridGlobalData.generationAnimation.max = 0.22*60
    GridGlobalData.generationAnimation.becauseWrong = true

    ShakeIntensity = 8
end
function CompleteFile()
    FilesCompleted = FilesCompleted + 1
    ClearGoal = CalculateClearGoal()

    local sfx = SFX.fileComplete
    if zutil.weightedbool(12) then
        sfx = SFX["fileComplete" .. math.random(2,3)]
    end
    zutil.playsfx(sfx, .6, 1)

    StartDialogue("list", "completeFile")

    AdjustRating("completed file")

    GridGlobalData.generationAnimation.running = true
    GridGlobalData.generationAnimation.max = 0.88*60
    GridGlobalData.generationAnimation.becauseWrong = false
end