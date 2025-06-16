LizardGlobalData = {
    sprite = love.graphics.newImage("assets/sprites/lizard.png", {dpiscale = 6}),
    colors = {
        {216, 140, 154},
        {153, 193, 185},
        {142, 125, 190},
    },
    particleInterval = { current = 0, max = 10 },
}

Lizards = {}



function NewLizard()
    table.insert(Lizards, {
        x = math.random(0, WINDOW.WIDTH), y = math.random(0, WINDOW.HEIGHT),
        velocity = 0,
        width = LizardGlobalData.sprite:getWidth(), height = LizardGlobalData.sprite:getHeight(),
        color = zutil.randomchoice(LizardGlobalData.colors),
        direction = zutil.randomchoice({1,-1}),
    })
end
function SpawnLizards()
    Lizards = {}
    for _ = 1, 50 do
        NewLizard()
    end
end

function DrawLizards()
    if not DepartmentData[CurrentDepartment].lizards then return end

    for _, lizard in ipairs(Lizards) do
        love.graphics.setColor(love.math.colorFromBytes(lizard.color))
        love.graphics.draw(LizardGlobalData.sprite, lizard.x + (lizard.direction == -1 and lizard.width or 0), lizard.y, 0, lizard.direction, 1)
    end
end

function UpdateLizards()
    if not DepartmentData[CurrentDepartment].lizards then return end

    for _, lizard in ipairs(Lizards) do
        local mx, my = love.mouse.getX(), love.mouse.getY()
        local lizardCenterX, lizardCenterY = lizard.x + lizard.width / 2, lizard.y + lizard.height / 2

        local angle = zutil.anglebetween(mx, my, lizardCenterX, lizardCenterY)
        local maxDistance = 700
        local distanceToMouse = zutil.distance(mx, my, lizardCenterX, lizardCenterY)

        lizard.velocity = lizard.velocity + ((1 - zutil.clamp(distanceToMouse / maxDistance, 0, 1)) / 2 - .2) * GlobalDT

        local applyVelocity = function ()
            lizard.x = lizard.x + math.sin(angle) * lizard.velocity * GlobalDT
            lizard.y = lizard.y + math.cos(angle) * lizard.velocity * GlobalDT
        end

        if distanceToMouse > 100 then
            applyVelocity()
        else
            lizard.velocity = 5
        end

        lizard.direction = (mx > lizardCenterX and -1 or 1)

        if not zutil.touching(0, 0, WINDOW.WIDTH, WINDOW.HEIGHT, lizard.x, lizard.y, lizard.width, lizard.height) then
            lizard.velocity = -lizard.velocity
            applyVelocity()
        end
    end

    zutil.updatetimer(LizardGlobalData.particleInterval, function ()
        for _, lizard in ipairs(Lizards) do
            local r, g, b = love.math.colorFromBytes(lizard.color)
            local color = {r,g,b}
            table.insert(Particles, NewParticle(lizard.x + lizard.width / 2, lizard.y + lizard.height / 2, 4, color, 0, 0, 0, 200))
        end
    end, 1, GlobalDT)
end