Spinner = {
    pointerDegrees = 0, pointerSpeed = 0,
    windows = {}, windowDegreeWidth = 25,
    badClicks = {},
    goodClicks = {},
    stoppingPoints = {},
    running = false,

    radius = 200,

    conditionsMetWhenStarted = 0,
}

WonSpinner = false
UseSpinners = false


function StartWheel(conditionsMet)
    Spinner.pointerDegrees = 360
    Spinner.conditionsMetWhenStarted = conditionsMet
    Spinner.pointerSpeed = 0
    Spinner.goodClicks = {}
    Spinner.badClicks = {}
    Spinner.running = true

    zutil.playsfx(SFX.wheelStart, .4, 1)

    -- new windows
    Spinner.windows = {}
    local lastOne = 0
    for _ = 1, math.random(zutil.clamp(FilesCompleted/10+1, 1, 5)) do
        local new = lastOne + zutil.clamp(math.random(Spinner.windowDegreeWidth + 5, 90), 0, 360 - Spinner.windowDegreeWidth)
        lastOne = new
        table.insert(Spinner.windows, { hit = false, degrees = 360 - new})
    end

    -- new stopping points
    Spinner.stoppingPoints = {}
    for _ = 1, math.random(0, zutil.clamp(FilesCompleted/10+1, 1, 2)) do
        table.insert(Spinner.stoppingPoints, { hit = false, degrees = math.random(360) })
    end
end

function UpdateWheel()
    if not Spinner.running then return end

    Spinner.pointerDegrees = Spinner.pointerDegrees - Spinner.pointerSpeed * GlobalDT
    Spinner.pointerSpeed = Spinner.pointerSpeed + .04 * GlobalDT * (WonSpinner and 1 or .03)

    for _, self in ipairs(Spinner.stoppingPoints) do
        if not self.hit and Spinner.pointerDegrees <= self.degrees then
            self.hit = true
            Spinner.pointerSpeed = zutil.relu(Spinner.pointerSpeed - math.random(2,4))
        end
    end

    if Spinner.pointerDegrees <= 0 then
        Spinner.running = false

        local hit = 0
        for _, data in ipairs(Spinner.windows) do
            if data.hit then hit = hit + 1 end
        end

        if hit < #Spinner.windows or #Spinner.badClicks > 0 then
            Wrong()
        else
            WonSpinner = true
            PopSquare(SquareSelected.x, SquareSelected.y, Spinner.conditionsMetWhenStarted)
        end
    end
end

function DrawWheel()
    if not Spinner.running then return end

    love.graphics.setColor(1,1,1)
    love.graphics.circle("fill", WINDOW.CENTER_X, WINDOW.CENTER_Y, Spinner.radius, 1000)

    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", WINDOW.CENTER_X, WINDOW.CENTER_Y, Spinner.radius, 1000)


    love.graphics.setColor(0,0,0, (1 - Spinner.pointerDegrees / 360) / 2)
    love.graphics.setLineWidth(2)
    love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y,   WINDOW.CENTER_X, WINDOW.CENTER_Y + Spinner.radius)

    -- pointer
    local lineEndX = math.sin(math.rad(Spinner.pointerDegrees)) * Spinner.radius + WINDOW.CENTER_X
    local lineEndY = math.cos(math.rad(Spinner.pointerDegrees)) * Spinner.radius + WINDOW.CENTER_Y
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(5)
    love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y,   lineEndX, lineEndY)
    love.graphics.circle("fill", WINDOW.CENTER_X, WINDOW.CENTER_Y, 2.5)

    -- stopping points
    love.graphics.setLineWidth(3)
    for _, self in ipairs(Spinner.stoppingPoints) do
        if self.hit then goto continue end
        local x, y = math.sin(math.rad(self.degrees)) * Spinner.radius, math.cos(math.rad(self.degrees)) * Spinner.radius
        love.graphics.setColor(0,0,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
        ::continue::
    end

    -- windows
    love.graphics.setLineWidth(10)
    for _, self in ipairs(Spinner.windows) do
        love.graphics.setColor((self.hit and {0,1,0} or {1,0,0}))
        love.graphics.arc("line", "open", WINDOW.CENTER_X, WINDOW.CENTER_Y, Spinner.radius, math.rad(360 - (self.degrees + 90) + 180), math.rad(360 - (self.degrees + Spinner.windowDegreeWidth + 90) + 180), 1000)

        -- love.graphics.print(self.degrees, love.mouse.getX() + 100 * i, love.mouse.getY())
    end

    -- bad clicks
    love.graphics.setLineWidth(1)
    for _, self in ipairs(Spinner.badClicks) do
        local x, y = math.sin(math.rad(self)) * Spinner.radius, math.cos(math.rad(self)) * Spinner.radius
        love.graphics.setColor(1,0,0)
        love.graphics.circle("fill", x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y, 5)

        x, y = x * 10, y * 10
        love.graphics.setColor(1,0,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
    end

    -- good clicks
    for _, self in ipairs(Spinner.goodClicks) do
        local x, y = math.sin(math.rad(self)) * Spinner.radius, math.cos(math.rad(self)) * Spinner.radius
        x, y = x * 10, y * 10
        love.graphics.setColor(0,1,0,.3)
        love.graphics.line(WINDOW.CENTER_X, WINDOW.CENTER_Y, x + WINDOW.CENTER_X, y + WINDOW.CENTER_Y)
    end
end