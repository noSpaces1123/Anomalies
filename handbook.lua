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

function love.keypressed(key)
    if Handbook.showing then
        local pageBefore = Handbook.page

        if key == "left" then
            Handbook.page = Handbook.page - 1
        elseif key == "right" then
            Handbook.page = Handbook.page + 1
        end

        local pagesAllowed = 1
        if UseSpinners then pagesAllowed = pagesAllowed + 1 end
        if UseScreens then pagesAllowed = pagesAllowed + 1 end

        Handbook.page = zutil.clamp(Handbook.page, 1, pagesAllowed)

        if pageBefore ~= Handbook.page then
            Handbook.scrollYOffset = 0
        end
    end
end