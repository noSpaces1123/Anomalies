Handbook = {
    showing = false,
    yOffset = 100,
    scrollYOffset = 0,
    page = 1,
    pageSprites = {},
}

local directory = "assets/sprites/handbook"
for _, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
    table.insert(Handbook.pageSprites, love.graphics.newImage(directory.."/"..fileName, {dpiscale=3}))
end



function DrawHandbook()
    if not Handbook.showing then return end

    zutil.overlay({0,0,0,.7})

    local sprite = Handbook.pageSprites[Handbook.page]
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprite, WINDOW.CENTER_X - sprite:getWidth() / 2, Handbook.yOffset + Handbook.scrollYOffset)

    love.graphics.setFont(Fonts.handbook)
    love.graphics.printf("Use the arrow keys to switch pages.", 0, Handbook.yOffset + Handbook.scrollYOffset + sprite:getHeight() + 20, WINDOW.WIDTH, "center")
end

function love.keypressed(key)
    if Handbook.showing then
        if key == "left" then
            Handbook.page = Handbook.page - 1
            Handbook.scrollYOffset = 0
        elseif key == "right" then
            Handbook.page = Handbook.page + 1
            Handbook.scrollYOffset = 0
        end

        local pagesAllowed = 1
        if UseSpinners then pagesAllowed = pagesAllowed + 1 end
        if UseScreens then pagesAllowed = pagesAllowed + 1 end

        Handbook.page = zutil.clamp(Handbook.page, 1, pagesAllowed)
    end
end