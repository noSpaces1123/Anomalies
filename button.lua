function NewButton(text, x, y, width, height, alignMode, lineColor, fillColor, mouseOverFillColor, textColor, font, lineWidth, roundX, roundY, func, passive, enable)
    table.insert(Buttons, {
        x = x, y = y, width = width, height = height, text = text,
        lineColor = lineColor, fillColor = fillColor, mouseOverFillColor = mouseOverFillColor, textColor = textColor, font = font,
        func = func, mouseOver = false, enable = enable, passive = passive,
        sizeEasing = 0,
        draw = function (self)
            if self.enable(self) then

                local applyFunc = (self.mouseOver and zutil.easing.easeOutQuint or zutil.easing.easeInQuint)

                local amplitude = 20
                local buttonX = self.x - applyFunc(self.sizeEasing) * amplitude
                local buttonWidth = self.width + 2 * applyFunc(self.sizeEasing) * amplitude

                love.graphics.setColor((self.mouseOver and self.mouseOverFillColor or self.fillColor))
                love.graphics.rectangle("fill", buttonX, self.y, buttonWidth, self.height, roundX, roundY)

                if lineWidth > 0 then
                    love.graphics.setColor(self.lineColor)
                    love.graphics.setLineWidth(lineWidth)
                    love.graphics.rectangle("line", buttonX, self.y, buttonWidth, self.height, roundX, roundY)
                end

                local obj = love.graphics.newText(self.font, self.text)
                love.graphics.setColor(self.textColor)
                love.graphics.setFont(self.font)

                local xpos = buttonX + buttonWidth / 2 - obj:getWidth() / 2
                local spacing = 20
                if alignMode == "left" then
                    xpos = buttonX + spacing
                elseif alignMode == "right" then
                    xpos = buttonX + buttonWidth - obj:getWidth() - spacing
                end

                love.graphics.draw(obj, xpos, self.y + self.height / 2 - obj:getHeight() / 2)

            end
        end,
        update = function (self)
            local before = self.mouseOver
            self.mouseOver = zutil.touching(love.mouse.getX(), love.mouse.getY(), 0, 0, self.x, self.y, self.width, self.height)

            if self.enable(self) then

                if not self.grayedOut then
                    if not before and self.mouseOver then
                        -- zutil.playsfx(SFX.hover, 0.6, 1)

                        self.sizeEasing = zutil.easing.easeInQuint(self.sizeEasing)
                    elseif before and not self.mouseOver then
                        self.sizeEasing = zutil.easing.easeOutQuint(self.sizeEasing)
                    end

                    local speed = 1/60
                    if self.mouseOver and self.sizeEasing < 1 then
                        self.sizeEasing = self.sizeEasing + speed * GlobalDT
                        if self.sizeEasing > 1 then self.sizeEasing = 1 end
                    elseif not self.mouseOver and self.sizeEasing > 0 then
                        self.sizeEasing = self.sizeEasing - speed * GlobalDT
                        if self.sizeEasing < 0 then self.sizeEasing = 0 end
                    end
                end

                if self.passive ~= nil then self.passive(self) end

            end
        end,
        mouseClick = function (self, key)
            if self.mouseOver and self.enable() and not ClickedWithMouse and not self.grayedOut then
                self.func(self)
                ClickedWithMouse = true
                zutil.playsfx(SFX.click, .2, 1)
            end
        end
    })
end
function UpdateButtons()
    for _, button in ipairs(Buttons) do
        button:update(button)
    end
end
function DrawButtons()
    for _, button in ipairs(Buttons) do
        button:draw(button)
    end
end
function CheckButtonsClicked(key)
    for _, button in ipairs(Buttons) do
        button:mouseClick(button, key)
    end
end
function love.mousereleased()
    ClickedWithMouse = false
end



function InitialiseButtons()
    Buttons = {}

    -- game

    local function correctFill (self)
        self.fillColor = Colors[CurrentDepartment].buttonFill
        self.mouseOverFillColor = {Colors[CurrentDepartment].buttonFill[1]*.9,Colors[CurrentDepartment].buttonFill[2]*.9,Colors[CurrentDepartment].buttonFill[3]*.9}
    end
    local function setProperColors(self)
        self.textColor = {Colors[CurrentDepartment].text[1],Colors[CurrentDepartment].text[2],Colors[CurrentDepartment].text[3]}
        self.mouseOverFillColor = {Colors[CurrentDepartment].text[1],Colors[CurrentDepartment].text[2],Colors[CurrentDepartment].text[3], .2}
        return self
    end

    local spacing, width, height = 10, 130, 40
    NewButton("", spacing + 20, WINDOW.HEIGHT - height - spacing, width, height, "left", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        Handbook.showing = not Handbook.showing
    end, function (self)
        self.text = (Handbook.showing and "Close" or "Handbook")
        correctFill (self)
    end, function ()
        return GameState == "game" and not RNEPractice.wait.running and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    height = 30
    NewButton("Menu", WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height - spacing, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function ()
        GameState = "menu"
        SaveData()
    end, function (self)
        correctFill (self)
    end, function ()
        return GameState == "game" and not RNEPractice.wait.running and not Handbook.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    NewButton("Spinner Practice", WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height * 2 - spacing * 2, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function ()
        StartRNEPractice()
    end, function (self)
        correctFill (self)
    end, function ()
        return GameState == "game" and not RNEPractice.wait.running and UseSpinners and WonSpinner and not Handbook.showing and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    local bx, by = WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height * 3 - spacing * 3
    NewButton("", bx, by, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function (self)
        StartRNEFromQueue()
    end, function (self)
        self.text = "RNE Queue ("..#RNEQueueList..")"

        local amp = zutil.relu(#RNEQueueList - 2)
        self.x, self.y = bx + zutil.jitter(amp), by + zutil.jitter(amp)

        correctFill (self)
    end, function ()
        return GameState == "game" and not RNEPractice.wait.running and UnlockedRNEQueue and not Handbook.showing and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    NewButton("Consume", NMeds.x, NMeds.y + NMeds.sprite:getHeight() + 10, NMeds.sprite:getWidth(), 20, "center", {0,0,0}, {1,1,1,0}, {0,0,0}, {0,0,0}, Fonts.smallBold, 0, 5, 5, function (self)
        TakeNMeds()
    end, function (self)
        setProperColors(self)
    end, function ()
        return GameState == "game" and HasNMeds and not RNEPractice.wait.running and not Handbook.showing and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    -- main menu

    local yAnchor = WINDOW.CENTER_Y + 100
    width = 300   height = 40
    NewButton("", WINDOW.CENTER_X - width/2, yAnchor, width, height, "center", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        GameState = "game"
        StartedShift = true
        SaveData()
    end, function (self)
        self.text = (StartedShift and "Continue" or "Start") .. " Shift"
        correctFill (self)
    end, function ()
        return GameState == "menu"
    end)
    NewButton("Options", WINDOW.CENTER_X - width/2, yAnchor + (height + spacing) * 1, width, height, "center", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        GameState = "options"
        StartDialogue("list", "enterOptionsMenu")
    end, function (self)
        correctFill (self)
    end, function ()
        return GameState == "menu"
    end)
    NewButton("Quit", WINDOW.CENTER_X - width/2, yAnchor + (height + spacing) * 2, width, height, "center", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        love.event.quit()
    end, function (self)
        correctFill (self)
    end, function ()
        return GameState == "menu"
    end)

    -- options
    local red, green = {.6,0,0}, {0,.5,0}
    local widthIncrease = 20
    yAnchor = 10 + widthIncrease
    height = 20
    width = 400
    NewButton("Reset save data", spacing + widthIncrease, yAnchor + (height + spacing) * 0, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        if not self.confirmation then
            if love.filesystem.getInfo(SaveFileDirectory) then
                if true then
                    self.text = "This feature has yet to be implemented properly. Sorry!"
                else
                    self.confirmation = 1
                    self.text = "Shift-click to erase your data. This cannot be undone."
                    self.mouseOverFillColor = {1,0,0}
                end
            else
                self.text = "No data to erase!"
            end
        elseif self.confirmation == 1 and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            assert(love.filesystem.remove(SaveFileDirectory))
            LoadModules()
            SaveData()
            love.load()
        end
    end, function (self)
        self = setProperColors(self)
    end, function ()
        return GameState == "options"
    end)
    NewButton("Dialogue speed: ", spacing + widthIncrease, yAnchor + (height + spacing) * 1, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        Dialogue.playing.charInterval.defaultMax = zutil.wrap(Dialogue.playing.charInterval.defaultMax - .5, Dialogue.playing.charInterval.minMax, Dialogue.playing.charInterval.maxMax)
        StartDialogue("list", "changeDialogueSpeed")
        SaveData()
    end, function (self)
        self.text = "Dialogue speed: " .. Dialogue.playing.charInterval.maxMax - Dialogue.playing.charInterval.defaultMax + Dialogue.playing.charInterval.minMax
        self = setProperColors(self)
    end, function ()
        return GameState == "options"
    end)
    NewButton("", spacing + widthIncrease, yAnchor + (height + spacing) * 2, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        CursorState = (CursorState == "regular cursor" and "normal" or "regular cursor")
        SaveData()
    end, function (self)
        self.text = "Cleanser's cursor: " .. (CursorState == "regular cursor" and "OFF" or "ON")
        self = setProperColors(self)
        self.textColor = (CursorState == "regular cursor" and red or green)
    end, function ()
        return GameState == "options"
    end)
    NewButton("", spacing + widthIncrease, yAnchor + (height + spacing) * 3, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        DoIntroAnimation = not DoIntroAnimation
        SaveData()
    end, function (self)
        self.text = "Do intro animation: " .. (DoIntroAnimation and "ON" or "OFF")
        self = setProperColors(self)
        self.textColor = (DoIntroAnimation and green or red)
    end, function ()
        return GameState == "options"
    end)
    NewButton("", spacing + widthIncrease, yAnchor + (height + spacing) * 4, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        ImmediatelyStartShift = not ImmediatelyStartShift
        SaveData()
    end, function (self)
        self.text = "Immediately start shift: " .. (ImmediatelyStartShift and "ON" or "OFF")
        self = setProperColors(self)
        self.textColor = (ImmediatelyStartShift and green or red)
    end, function ()
        return GameState == "options"
    end)
    NewButton("", spacing + widthIncrease, yAnchor + (height + spacing) * 5, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        Jumpscares = not Jumpscares
        SaveData()
    end, function (self)
        self.text = "Jumpscares: " .. (Jumpscares and "ON" or "OFF")
        self = setProperColors(self)
        self.textColor = (Jumpscares and green or red)
    end, function ()
        return GameState == "options"
    end)
    NewButton("", spacing + widthIncrease, yAnchor + (height + spacing) * 6, width, height, "left", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.small, 0, 5, 5, function (self)
        MusicSetting = zutil.wrap(MusicSetting + 1, -1, 2)
        SaveData()

        if MusicSetting == 1 then
            StartMusic(zutil.randomchoice(Music))
            SFX.brownNoise:stop()
        elseif MusicSetting == 2 then
---@diagnostic disable-next-line: undefined-field
            MusicPlaying.audio:stop()
            StartBrownNoise()
        elseif MusicSetting == 0 then
            SFX.brownNoise:stop()
        end
    end, function (self)
        self.text = "BG Audio: "
        if MusicSetting == 1 then self.text = self.text .. "MUSIC"
        elseif MusicSetting == 2 then self.text = self.text .. "BROWN NOISE"
        elseif MusicSetting == 0 then self.text = self.text .. "SILENCE" end
        self = setProperColors(self)
        if MusicSetting == 1 then self.textColor = green end
    end, function ()
        return GameState == "options"
    end)

    width = 100
    NewButton("Back to menu", WINDOW.WIDTH - spacing - widthIncrease - width, WINDOW.HEIGHT - spacing - height, width, height, "right", {0,0,0}, {1,1,1,0}, {.9,.9,.9}, {0,0,0}, Fonts.smallBold, 0, 5, 5, function ()
        GameState = "menu"
    end, function (self)
        self = setProperColors(self)
    end, function ()
        return GameState == "options"
    end)
end