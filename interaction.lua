SquareSelected = { x = nil, y = nil } -- the square the mouse is hovering over

function UpdateSelectedSquare()
    if Spinner.running or Screen.running or Road.running or Barcode.running then return end

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
        local color = {0,0,0}
        if Grid[y][x] == 3 then
            color = {Colors[CurrentDepartment].type3Square[1],Colors[CurrentDepartment].type3Square[2],Colors[CurrentDepartment].type3Square[3]}
        elseif Grid[y][x] == 2 then
            color = {Colors[CurrentDepartment].squares[1],Colors[CurrentDepartment].squares[2],Colors[CurrentDepartment].squares[3]}
        elseif Grid[y][x] == 1 then
            for i = 1, 3 do
                color[i] = (Colors[CurrentDepartment].squares[i] + Colors[CurrentDepartment].fileBg[i]) / 2
            end
        end
        table.insert(Particles, NewParticle(squareX+SquareGlobalData.width/2, squareY+SquareGlobalData.height/2, math.random()*8+2, color, math.random(6,15), math.random(360), 0, math.random(20,50), function (self)
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

    TimeUntilCorruption.current = 0

    if not DoNotDecreaseClearGoal then ClearGoal = ClearGoal - 1 end

    if ClearGoal <= 0 then
        if FilesCompleted < (DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted and DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted or 30) then CompleteFile()
        else
            StartDepartmentTransition()
        end
    else
        AdjustRating("anomaly found", conditionsMet)
    end

    SaveData()
end

function love.mousepressed(mx, my, button)
    if EndingDialoguePlaying.running and button == 1 then
        if EndingDialoguePlaying.running then
            if Dialogue.playing.running then
                Dialogue.playing.running = false
                Dialogue.playing.textThusFar = Dialogue.playing.targetText
            else
                EndingDialoguePlaying.dialogueIndex = EndingDialoguePlaying.dialogueIndex + 1

                if EndingDialoguePlaying.dialogueIndex > #Endings[EndingDialoguePlaying.endingIndex].dialogue then
                    EndingDialoguePlaying.running = false
                    GameState = "ending collected"

                    WakeUpTextAlpha.running = true
                    EndingDialoguePlaying.imageShowing = false

                    zutil.playsfx(SFX.endingCollected, .4, 1)
                    MainTheme:play()
                else
                    StartEndingDialogue(Endings[EndingDialoguePlaying.endingIndex].dialogue[EndingDialoguePlaying.dialogueIndex])

                    if Endings[EndingDialoguePlaying.endingIndex].dialogue[EndingDialoguePlaying.dialogueIndex].showImage ~= nil then
                        EndingDialoguePlaying.imageShowing = Endings[EndingDialoguePlaying.endingIndex].dialogue[EndingDialoguePlaying.dialogueIndex].showImage
                        if EndingDialoguePlaying.imageShowing then EndingDialoguePlaying.imageAlpha.running = true end
                    end
                end
            end
        end

        goto skipInteraction
    end
    if GameState == "ending collected" and button == 1 then
        GameState = "menu"
        MainTheme:stop()
        ResetSaveData()

        goto skipInteraction
    end

    if DepartmentTransition.running and #DepartmentTree[CurrentDepartment] == 1 then return end
    if EndOfContent.showing then return end
    if GridGlobalData.generationAnimation.running or GameState == "menu" or (DepartmentTransition.running and #DepartmentTree[CurrentDepartment] > 1) then goto skipInteraction end

    if not Handbook.showing and not Spinner.running and not Screen.running and not Road.running and not Barcode.running and not RNEPractice.wait.running then
        if button == 1 and SquareSelected.x ~= nil and SquareSelected.y ~= nil and Grid[SquareSelected.y][SquareSelected.x] > 0 then
            UpdateSelectedSquare()

            local isAnomaly, conditionsMet = CheckIsAnomaly(SquareSelected.x, SquareSelected.y)

            if isAnomaly then
                local choices = {}
                local deptData = DepartmentData[CurrentDepartment]
                if UseSpinners and deptData.rnes.spinners then table.insert(choices, "Wheel") end
                if UseScreens and deptData.rnes.screens then table.insert(choices, "Screen") end
                if UseRoads and deptData.rnes.roads then table.insert(choices, "Road") end
                if UseBarcodes and deptData.rnes.barcodes then table.insert(choices, "Barcode") end

                if (zutil.weightedbool(deptData.rnePercentChance)) and #choices > 0 then
                    _G["Start" .. zutil.randomchoice(choices)](conditionsMet)
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
    elseif Spinner.running and button == 1 then
        local nHit = 0
        local hitSomething = false

        for _, self in ipairs(Spinner.windows) do
            if self.hit then nHit = nHit + 1
            elseif Spinner.pointerDegrees >= self.degrees and Spinner.pointerDegrees <= self.degrees + Spinner.windowDegreeWidth then
                self.hit = true
                zutil.playsfx(SFX.wheelHit, .3, 1 + nHit)
                hitSomething = true
                if not RNEPractice.running then AdjustRating("hit arc") end
            end
        end

        local x = math.sin(math.rad(Spinner.pointerDegrees)) * (Spinner.radius + Spinner.radiusPop.radiusAddition) + WINDOW.CENTER_X
        local y = math.cos(math.rad(Spinner.pointerDegrees)) * (Spinner.radius + Spinner.radiusPop.radiusAddition) + WINDOW.CENTER_Y
        local color

        if hitSomething then
            table.insert(Spinner.goodClicks, Spinner.pointerDegrees)

            color = {0,1,0}
        else
            table.insert(Spinner.badClicks, Spinner.pointerDegrees)
            zutil.playsfx(SFX.badClick, .5, 1)
            ShakeIntensity = 5
            Spinner.pointerSpeed = Spinner.pointerSpeed * 3
            Spinner.stoppingPoints = {}
            Spinner.shake = 5

            color = {1,0,0}
        end

        for _ = 1, 30 do
            table.insert(Particles, NewParticle(x, y, math.random()*3+2, color, math.random()*9+3, Spinner.pointerDegrees + zutil.jitter(30), .03, math.random(300,600)))
        end

        Spinner.radiusPop.current = 1
        Spinner.radiusPop.running = true
    elseif Screen.running and Screen.shutterDone and button == 1 then
        local hit = false
        for _, self in ipairs(Screen.dots) do
            if not self.hit and zutil.distance(self.x + Screen.x, self.y + Screen.y, mx, my) <= Screen.maxError then
                self.hit = true
                zutil.playsfx(SFX.screenDot, .3, math.random() * 2 + 2)

                table.insert(Particles, NewParticle(self.x + Screen.x, self.y + Screen.y, Screen.dotRadius, {Colors[CurrentDepartment].screenDots[1],Colors[CurrentDepartment].screenDots[2],Colors[CurrentDepartment].screenDots[3]}, 4, math.random(90,270), 0.1, 400))

                hit = true
            end
        end

        if not hit then
            if RNEPractice.running then
                zutil.playsfx(SFX.rnePracticeFail, .3, 1)
                if RNEQueue.doing then NewRNEQueueItem() end
            else Wrong() end
            Screen.running = false
            RNEPractice.running = false
            RNEQueue.doing = false
        end
    elseif Barcode.running and button == 1 then
        CheckClickOnBarcode(mx, my)
    end

    ::skipInteraction::

    CheckButtonsClicked(button)
end

function love.wheelmoved(_, y)
    if Handbook.showing then
        Handbook.scrollYOffset = zutil.clamp(Handbook.scrollYOffset + y * 7 * (love.system.getOS() == "OS X" and 1 or 5), -Handbook.pageSprites[1]:getHeight() + WINDOW.HEIGHT - Handbook.yOffset * 2, 0)
    elseif not GridGlobalData.introAnimation.running then
        SquareGlobalData.width = zutil.clamp(SquareGlobalData.width + y, 5, 30)

        SquareGlobalData.height = SquareGlobalData.width
    end
end

function love.keypressed(key)
    if Handbook.showing then
        local pageBefore = Handbook.page

        if key == "left" then
            Handbook.page = Handbook.page - 1
        elseif key == "right" then
            Handbook.page = Handbook.page + 1
        end

        local pagesAllowed = 1
        if UseSpinners then pagesAllowed = pagesAllowed + 1 end
        if UseScreens then pagesAllowed = pagesAllowed + 1 end
        if UseRoads then pagesAllowed = pagesAllowed + 1 end

        Handbook.page = zutil.clamp(Handbook.page, 1, pagesAllowed)

        if pageBefore ~= Handbook.page then
            Handbook.scrollYOffset = 0
        end
    elseif Road.running then
        local moved = false
        if (key == "left" or key == "a") and Road.playerColumn > 1 then moved = true
            Road.playerColumn = Road.playerColumn - 1
        elseif (key == "right" or key == "d") and Road.playerColumn < Road.columns then moved = true
            Road.playerColumn = Road.playerColumn + 1
        end

        if moved then
            zutil.playsfx(SFX.roadMove, .3, 1)
        end
    elseif Spinner.running then
        love.mousepressed(0, 0, 1)
    end
end

function Wrong()
    zutil.playsfx(SFX["notAnAnomaly" .. (Jumpscares and "" or "Calm")], .8, 1)

    StartDialogue("list", "wrong")

    AdjustRating("not an anomaly")

    CalculateGridSize()
    ClearGoal = zutil.clamp(ClearGoal + 5, 0, CalculateClearGoal())
    GridGlobalData.generationAnimation.running = true
    GridGlobalData.generationAnimation.max = 0.22*60
    GridGlobalData.generationAnimation.becauseWrong = true

    TimeUntilCorruption.current = 0

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

    if not Dialogue.playing then
        Dialogue.textThusFar = ""
    end

    for _, value in pairs(Animations) do
        value.running = false
    end

    if not Dialogue.playing.running then Dialogue.playing.textThusFar = "" end

    StartDialogue("list", "completeFile")

    AdjustRating("completed file")

    GridGlobalData.generationAnimation.running = true
    GridGlobalData.generationAnimation.max = 0.88*60
    GridGlobalData.generationAnimation.becauseWrong = false
end