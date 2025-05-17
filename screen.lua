Screen = {
    x = 0, y = 0, width = 400, height = 500,
    dots = {}, dotRadius = 4, maxError = 50,
    shutter = 0, shutterDone = false,
    conditionsMetWhenStarted = 0,
    running = false,
}
Screen.x = WINDOW.CENTER_X - Screen.width / 2
Screen.y = WINDOW.CENTER_Y - Screen.height / 2

WonScreen = false
UseScreens = false



function StartScreen(conditionsMet)
    Screen.running = true
    Screen.shutter = 0
    Screen.shutterDone = false
    Screen.conditionsMetWhenStarted = conditionsMet

    -- new dots
    local spacingFromEdges = 20
    Screen.dots = {}
    for _ = 1, math.random(3, 5) do
        table.insert(Screen.dots, {
            x = math.random(spacingFromEdges, Screen.width - spacingFromEdges), y = math.random(spacingFromEdges, Screen.height - spacingFromEdges),
            revealed = false,
            hit = false,
            alpha = 1,
        })
    end

    SFX.shutter:setLooping(true)
    zutil.playsfx(SFX.shutter, .1, math.random()/10+.9)

    zutil.playsfx(SFX.screenStart, .3, 1)
end

function UpdateScreen()
    if not Screen.running then return end

    if not Screen.shutterDone then
        Screen.shutter = Screen.shutter + DepartmentData[CurrentDepartment].shutterSpeed * GlobalDT
        if Screen.shutter >= Screen.height then
            Screen.shutterDone = true
            SFX.shutter:stop()
        end
    end

    local hit = 0
    for _, self in ipairs(Screen.dots) do
        if self.hit then
            hit = hit + 1
        elseif self.revealed then
            if self.alpha > 0 then
                self.alpha = zutil.relu(self.alpha - DepartmentData[CurrentDepartment].screenDotAlphaDecreaseSpeed * GlobalDT)
            end
        elseif self.y <= Screen.shutter then
            self.revealed = true
            zutil.playsfx(SFX.screenDot, .3, math.random() + 1)
        end
    end

    if hit == #Screen.dots then
        if not RNEPractice.running then PopSquare(SquareSelected.x, SquareSelected.y, Screen.conditionsMetWhenStarted) end
        Screen.running = false
        RNEPractice.running = false
        zutil.playsfx(SFX.rneComplete, .4, 1)
    end
end

function DrawScreen()
    if not Screen.running then return end

    love.graphics.setColor(Colors[CurrentDepartment].screenBg)
    love.graphics.rectangle("fill", Screen.x, Screen.y, Screen.width, Screen.height)

    -- grid
    love.graphics.setLineWidth(1)

    love.graphics.setColor(Colors[CurrentDepartment].screenGrid[1],Colors[CurrentDepartment].screenGrid[2],Colors[CurrentDepartment].screenGrid[3], (Screen.shutterDone and 1 or math.random()))

    local limit = (Screen.shutterDone and 20 or zutil.randomchoice({20,40}))

    local screenX = Screen.x + (Screen.shutterDone and 0 or zutil.jitter(2))

    for y = Screen.y, Screen.y + Screen.height, limit do
        love.graphics.line(screenX, y, screenX + Screen.width, y)
    end
    for x = screenX, screenX + Screen.width, limit do
        love.graphics.line(x, Screen.y, x, Screen.y + Screen.height)
    end

    love.graphics.setLineWidth(5)
    love.graphics.setColor(Colors[CurrentDepartment].screenOutline)
    love.graphics.rectangle("line", Screen.x, Screen.y, Screen.width, Screen.height)

    -- dots
    for _, self in ipairs(Screen.dots) do
        if self.hit then
            love.graphics.setColor(Colors[CurrentDepartment].screenDots)
            for _ = 1, 3 do
                love.graphics.rectangle("fill", self.x + zutil.jitter(5) + Screen.x, self.y + zutil.jitter(5) + Screen.y, math.random(3,6), math.random(3,6))
            end
        else
            if not self.revealed then goto continue end
            love.graphics.setColor(Colors[CurrentDepartment].screenDots[1],Colors[CurrentDepartment].screenDots[2],Colors[CurrentDepartment].screenDots[3], self.alpha)
            love.graphics.circle("fill", self.x + Screen.x, self.y + Screen.y, Screen.dotRadius, 500)
        end
        ::continue::
    end

    -- shutter
    if not Screen.shutterDone then
        love.graphics.setColor(Colors[CurrentDepartment].screenOutline)
        love.graphics.setLineWidth(1)

        local y = Screen.y + Screen.shutter + (zutil.jitter(2))
        love.graphics.line(Screen.x, y, Screen.x + Screen.width, y)

        -- random numbers on the sides
        local makeNumbers = function ()
            local text = ""
            for _ = 1, Screen.height / Fonts.small:getHeight() do
                text = text .. zutil.floor(math.random() * 100, -2) .. "\n"
            end
            return text
        end

        local text1 = makeNumbers()
        local text2 = makeNumbers()

        local spacing = 5

        love.graphics.setFont(Fonts.small)
        love.graphics.print(text1, Screen.x + Screen.width + spacing, Screen.y + spacing)
        love.graphics.printf(text2, 0, Screen.y + spacing, Screen.x - spacing, "right")
    end
end