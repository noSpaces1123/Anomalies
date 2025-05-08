Cards = {}
local directory = "assets/sprites/cards"
for index, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
    if fileName ~= ".DS_Store" then
        table.insert(Cards, love.graphics.newImage(directory.."/"..fileName, {dpiscale = 7}))
    end
end

function DrawCards()
    local spacing = 10
    local spacingBetweenCards = 5
    local anchorX, anchorY = spacing, WINDOW.HEIGHT - spacing - Cards[1]:getHeight()

    love.graphics.setColor(1,1,1)
    for index, card in ipairs(Cards) do
        love.graphics.draw(card, anchorX + (index - 1) * (card:getWidth() + spacingBetweenCards), anchorY)
    end
end