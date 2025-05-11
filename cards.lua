Cards = {}
local directory = "assets/sprites/cards"
for _, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
    if fileName ~= ".DS_Store" then
        table.insert(Cards, love.graphics.newImage(directory.."/"..fileName, {dpiscale = 5}))
    end
end

NewCardIndicator = {
    on = false,
    bounce = { current = 0, max = 360 },
    sprite = love.graphics.newImage("assets/sprites/new card.png", {dpiscale=4})
}



function DrawCards()
    local maxDistance = 40
    local distance = zutil.distance(love.mouse.getX(), love.mouse.getY(), love.mouse.getX(), WINDOW.HEIGHT)
    local ratio = distance/maxDistance
    local alpha = 1 - (Handbook.showing and 1 or zutil.clamp(ratio, 0, 1))
    if distance <= maxDistance then NewCardIndicator.on = false end -- turn of new card indicator thing

    local spacing = 10
    local spacingBetweenCards = 5
    local anchorX, anchorY = WINDOW.CENTER_X - ConditionsCollected / 2 * Cards[1]:getWidth(), WINDOW.HEIGHT - spacing - Cards[1]:getHeight() + (1 - alpha) * Cards[1]:getWidth()

    spacing = 300
    love.graphics.setColor(0,0,0, 1 - alpha)
    love.graphics.setLineWidth(1)
    local y = WINDOW.HEIGHT - 10
    love.graphics.line(spacing, y, WINDOW.WIDTH - spacing, y)

    love.graphics.setColor(1,1,1, alpha)
    for index, card in ipairs(Cards) do
        if index > ConditionsCollected then break end
        love.graphics.draw(card, anchorX + (index - 1) * (card:getWidth() + spacingBetweenCards), anchorY)
    end

    DrawNewCardIndicator()
end

function UpdateNewCardIndicator()
    zutil.updatetimer(NewCardIndicator.bounce, nil, 2, GlobalDT)
end
function DrawNewCardIndicator()
    if not NewCardIndicator.on then return end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(NewCardIndicator.sprite, WINDOW.CENTER_X - NewCardIndicator.sprite:getWidth()/2, WINDOW.HEIGHT - 50 - math.abs(math.sin(math.rad(NewCardIndicator.bounce.current))) * 10)
end