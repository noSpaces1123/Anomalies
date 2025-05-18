Handbook = {
    showing = false,
    yOffset = 100,
    scrollYOffset = 0,
    page = 1,
    pageSprites = {},
}

local directory = "assets/sprites/handbook"
for _, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
    if fileName ~= ".DS_Store" then
        table.insert(Handbook.pageSprites, love.graphics.newImage(directory.."/"..fileName, {dpiscale=3}))
    end
end



function DrawHandbook()
    if not Handbook.showing then return end

    zutil.overlay({0,0,0,.7})

    local sprite = Handbook.pageSprites[Handbook.page]
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprite, WINDOW.CENTER_X - sprite:getWidth() / 2, Handbook.yOffset + Handbook.scrollYOffset)

    if UseSpinners or UseScreens then
        love.graphics.setFont(Fonts.handbook)
        love.graphics.printf("Use the arrow keys to switch pages.", 0, Handbook.yOffset + Handbook.scrollYOffset + sprite:getHeight() + 20, WINDOW.WIDTH, "center")
    end
end