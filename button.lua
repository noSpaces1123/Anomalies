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

                love.graphics.setColor(self.lineColor)
                love.graphics.setLineWidth(lineWidth)
                love.graphics.rectangle("line", buttonX, self.y, buttonWidth, self.height, roundX, roundY)

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

    local spacing, width, height = 10, 130, 40
    NewButton("", spacing + 20, WINDOW.HEIGHT - height - spacing, width, height, "left", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        Handbook.showing = not Handbook.showing
    end, function (self)
        self.text = (Handbook.showing and "Close" or "Handbook")
    end, function ()
        return GameState == "game" and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    height = 30
    NewButton("Menu", WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height - spacing, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function ()
        GameState = "menu"
        SaveData()
    end, nil, function ()
        return GameState == "game" and not Handbook.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    NewButton("Spinner Practice", WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height * 2 - spacing * 2, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function ()
        StartRNEPractice()
    end, nil, function ()
        return GameState == "game" and UseSpinners and WonSpinner and not Handbook.showing and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)

    local bx, by = WINDOW.WIDTH - spacing - 20 - width, WINDOW.HEIGHT - height * 3 - spacing * 3
    NewButton("", bx, by, width, height, "right", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.small, 1, 5, 5, function (self)
        StartRNEFromQueue()
    end, function (self)
        self.text = "RNE Queue ("..#RNEQueueList..")"

        local amp = zutil.relu(#RNEQueueList - 2)
        self.x, self.y = bx + zutil.jitter(amp), by + zutil.jitter(amp)
    end, function ()
        return GameState == "game" and CurrentDepartment == "B" and UseSpinners and WonSpinner and UseScreens and not Handbook.showing and not Info.showing and not Spinner.running and not Screen.running and not Road.running and not EndOfContent.showing
    end)



    local yAnchor = WINDOW.CENTER_Y + 100
    width = 300   height = 40
    NewButton("", WINDOW.CENTER_X - width/2, yAnchor, width, height, "center", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        GameState = "game"
        StartedShift = true
        SaveData()
    end, function (self)
        self.text = (StartedShift and "Continue" or "Start") .. " Shift"
    end, function ()
        return GameState == "menu"
    end)
    NewButton("Quit", WINDOW.CENTER_X - width/2, yAnchor + (height + spacing) * 1, width, height, "center", {0,0,0}, {1,1,1}, {.9,.9,.9}, {0,0,0}, Fonts.normal, 1, 5, 5, function ()
        love.event.quit()
    end, nil, function ()
        return GameState == "menu"
    end)
end