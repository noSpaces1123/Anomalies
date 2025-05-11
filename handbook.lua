Handbook = {
    showing = false,
    yOffset = 100,
    scollYOffset = 0,
    page = 1,
    pageSprites = {
        love.graphics.newImage("assets/sprites/cleanser's handbook.png", {dpiscale=3}),
    },
}



function DrawHandbook()
    if not Handbook.showing then return end

    zutil.overlay({0,0,0,.7})

    local sprite = Handbook.pageSprites[Handbook.page]
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprite, WINDOW.CENTER_X - sprite:getWidth() / 2, Handbook.yOffset + Handbook.scollYOffset)
end