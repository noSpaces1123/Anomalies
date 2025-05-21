SpriteSheets = {
    greeting = love.graphics.newImage("assets/spritesheets/greeting.png", {dpiscale = 4}),
}

Animations = {
    greeting = {}
}
Animations.greeting.frameWidth = 84/2
Animations.greeting.frameHeight = 126/2
Animations.greeting.grid = anim8.newGrid(Animations.greeting.frameWidth, Animations.greeting.frameHeight, SpriteSheets.greeting:getWidth(), SpriteSheets.greeting:getHeight())
Animations.greeting = { animation = anim8.newAnimation( Animations.greeting.grid("1-2",1), .6 ), running = false }



function UpdateAnimations()
    for _, animation in pairs(Animations) do
        animation.animation:update(love.timer.getDelta())
    end
end

function DrawGreetingAnimation()
    if not Animations.greeting.running then return end

    Animations.greeting.frameWidth = 84/4
    Animations.greeting.frameHeight = 126/4

    local gx, _ = GetGridAnchorCoords()
    love.graphics.setColor(1,1,1)
    Animations.greeting.animation:draw(SpriteSheets.greeting, gx + #Grid[1]/2 * SquareGlobalData.width - Animations.greeting.frameWidth / 2, GetDialogueY() - Animations.greeting.frameHeight - 7, nil, .5, .5)
end