Cards = {}
local directory = "assets/sprites/cards"
for _, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
    if fileName ~= ".DS_Store" then
        table.insert(Cards, love.graphics.newImage(directory.."/"..fileName, {dpiscale = 5}))
    end
end

function DrawCards()
    local maxDistance = 40
    local alpha = 1 - zutil.clamp(zutil.distance(love.mouse.getX(), love.mouse.getY(), love.mouse.getX(), WINDOW.HEIGHT)/maxDistance, 0, 1)

    local spacing = 10
    local spacingBetweenCards = 5
    local anchorX, anchorY = WINDOW.CENTER_X - #Cards / 2 * Cards[1]:getWidth(), WINDOW.HEIGHT - spacing - Cards[1]:getHeight() + (1 - alpha) * Cards[1]:getWidth()

    spacing = 300
    love.graphics.setColor(0,0,0, 1 - alpha)
    love.graphics.setLineWidth(1)
    local y = WINDOW.HEIGHT - 10
    love.graphics.line(spacing, y, WINDOW.WIDTH - spacing, y)

    love.graphics.setColor(1,1,1, alpha)
    for index, card in ipairs(Cards) do
        love.graphics.draw(card, anchorX + (index - 1) * (card:getWidth() + spacingBetweenCards), anchorY)
    end
end