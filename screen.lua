Screen = {
    x = 0, y = 0, width = 400, height = 500,
    dots = {}, dotRadius = 4, maxError = 40,
    shutter = 0, shutterSpeed = 0, shutterDone = false,
    conditionsMetWhenStarted = 0,
    running = false,
}
Screen.shutterSpeed = Screen.height / (4 * 60)
Screen.x = WINDOW.CENTER_X - Screen.width / 2
Screen.y = WINDOW.CENTER_Y - Screen.height / 2



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
end

function UpdateScreen()
    if not Screen.running then return end

    if not Screen.shutterDone then
        Screen.shutter = Screen.shutter + Screen.shutterSpeed * GlobalDT
        if Screen.shutter >= Screen.height then
            Screen.shutterDone = true
        end
    end

    local hit = 0
    for _, self in ipairs(Screen.dots) do
        if self.hit then
            hit = hit + 1
        elseif self.revealed then
            if self.alpha > 0 then
                self.alpha = zutil.relu(self.alpha - .02 * GlobalDT)
            end
        elseif self.y <= Screen.shutter then
            self.revealed = true
            zutil.playsfx(SFX.screenDot, .3, math.random() + 1)
        end
    end

    if hit == #Screen.dots then
        PopSquare(SquareSelected.x, SquareSelected.y, Screen.conditionsMetWhenStarted)
        Screen.running = false
    end
end

function DrawScreen()
    if not Screen.running then return end

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", Screen.x, Screen.y, Screen.width, Screen.height)

    -- grid
    love.graphics.setLineWidth(1)
    love.graphics.setColor(.9,.9,.9)
    for y = Screen.y, Screen.y + Screen.height, 20 do
        love.graphics.line(Screen.x, y, Screen.x + Screen.width, y)
    end
    for x = Screen.x, Screen.x + Screen.width, 20 do
        love.graphics.line(x, Screen.y, x, Screen.y + Screen.height)
    end

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", Screen.x, Screen.y, Screen.width, Screen.height)

    -- dots
    for _, self in ipairs(Screen.dots) do
        if not self.revealed then goto continue end
        love.graphics.setColor(0,0,0, self.alpha)
        love.graphics.circle("fill", self.x + Screen.x, self.y + Screen.y, Screen.dotRadius, 500)
        ::continue::
    end

    -- shutter
    if not Screen.shutterDone then
        love.graphics.setColor(0,0,0)
        love.graphics.setLineWidth(1)
        love.graphics.line(Screen.x, Screen.y + Screen.shutter, Screen.x + Screen.width, Screen.y + Screen.shutter)
    end
end