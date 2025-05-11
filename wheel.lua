Wheel = {
    pointerDegrees = 0, pointerSpeed = 0,
    windows = {}, windowDegreeWidth = 25,
    badClicks = {},
    goodClicks = {},
    stoppingPoints = {},
    running = false,

    radius = 200,

    conditionsMetWhenStarted = 0,
}


function StartWheel(conditionsMet)
    Wheel.pointerDegrees = 360
    Wheel.conditionsMetWhenStarted = conditionsMet
    Wheel.pointerSpeed = 0
    Wheel.goodClicks = {}
    Wheel.badClicks = {}
    Wheel.running = true

    zutil.playsfx(SFX.wheelStart, .4, 1)

    -- new windows
    Wheel.windows = {}
    local lastOne = 0
    for _ = 1, math.random(zutil.clamp(FilesCompleted/10+1, 1, 5)) do
        local new = lastOne + zutil.clamp(math.random(Wheel.windowDegreeWidth + 5, 90), 0, 360 - Wheel.windowDegreeWidth)
        lastOne = new
        table.insert(Wheel.windows, { hit = false, degrees = 360 - new})
    end

    -- new stopping points
    Wheel.stoppingPoints = {}
    for _ = 1, math.random(0, zutil.clamp(FilesCompleted/10+1, 1, 2)) do
        table.insert(Wheel.stoppingPoints, { hit = false, degrees = math.random(360) })
    end
end

function UpdateWheel()
    if not Wheel.running then return end

    Wheel.pointerDegrees = Wheel.pointerDegrees - Wheel.pointerSpeed * GlobalDT
    Wheel.pointerSpeed = Wheel.pointerSpeed + .04 * GlobalDT

    for _, self in ipairs(Wheel.stoppingPoints) do
        if not self.hit and Wheel.pointerDegrees <= self.degrees then
            self.hit = true
            Wheel.pointerSpeed = zutil.relu(Wheel.pointerSpeed - math.random(2,4))
        end
    end

    if Wheel.pointerDegrees <= 0 then
        Wheel.running = false

        local hit = 0
        for _, data in ipairs(Wheel.windows) do
            if data.hit then hit = hit + 1 end
        end

        if hit < #Wheel.windows or #Wheel.badClicks > 0 then
            Wrong()
        else
            PopSquare(SquareSelected.x, SquareSelected.y, Wheel.conditionsMetWhenStarted)
        end
    end
end

function DrawWheel()
    if not Wheel.running then return end

    love.graphics.setColor(1,1,1)
    love.graphics.circle("fill", WINDOW.CENTER_X, WINDOW.CENTER_Y, Wheel.radius, 1000)

    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", WINDOW.CENTER_X, WINDOW.CENTER_Y, Wheel.radius, 1000)


    love.graphics.setColor(0,0,0, (1 - Wheel.pointerDegrees / 360) / 2)
    love.graphics.setLineWidth(2)
    love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y,   WINDOW.CENTER_X, WINDOW.CENTER_Y + Wheel.radius)

    -- pointer
    local lineEndX = math.sin(math.rad(Wheel.pointerDegrees)) * Wheel.radius + WINDOW.CENTER_X
    local lineEndY = math.cos(math.rad(Wheel.pointerDegrees)) * Wheel.radius + WINDOW.CENTER_Y
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(5)
    love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y,   lineEndX, lineEndY)
    love.graphics.circle("fill", WINDOW.CENTER_X, WINDOW.CENTER_Y, 2.5)

    -- stopping points
    love.graphics.setLineWidth(3)
    for _, self in ipairs(Wheel.stoppingPoints) do
        if self.hit then goto continue end
        local x, y = math.sin(math.rad(self.degrees)) * Wheel.radius, math.cos(math.rad(self.degrees)) * Wheel.radius
        love.graphics.setColor(0,0,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
        ::continue::
    end

    -- windows
    love.graphics.setLineWidth(10)
    for _, self in ipairs(Wheel.windows) do
        love.graphics.setColor((self.hit and {0,1,0} or {1,0,0}))
        love.graphics.arc("line", "open", WINDOW.CENTER_X, WINDOW.CENTER_Y, Wheel.radius, math.rad(360 - (self.degrees + 90) + 180), math.rad(360 - (self.degrees + Wheel.windowDegreeWidth + 90) + 180), 1000)

        -- love.graphics.print(self.degrees, love.mouse.getX() + 100 * i, love.mouse.getY())
    end

    -- bad clicks
    love.graphics.setLineWidth(1)
    for _, self in ipairs(Wheel.badClicks) do
        local x, y = math.sin(math.rad(self)) * Wheel.radius, math.cos(math.rad(self)) * Wheel.radius
        love.graphics.setColor(1,0,0)
        love.graphics.circle("fill", x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y, 5)

        x, y = x * 10, y * 10
        love.graphics.setColor(1,0,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
    end

    -- good clicks
    for _, self in ipairs(Wheel.goodClicks) do
        local x, y = math.sin(math.rad(self)) * Wheel.radius, math.cos(math.rad(self)) * Wheel.radius
        x, y = x * 10, y * 10
        love.graphics.setColor(0,1,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
    end
end