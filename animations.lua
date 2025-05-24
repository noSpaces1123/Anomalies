SpriteSheets = {
    greeting = love.graphics.newImage("assets/spritesheets/greeting.png", {dpiscale = 4}),
    newCard = love.graphics.newImage("assets/spritesheets/new card.png", {dpiscale = 2}),
    gainSticker = love.graphics.newImage("assets/spritesheets/gain sticker.png", {dpiscale = 4}),
}

Animations = {
    greeting = {}, newCard = {}, gainSticker = {}
}

AnimationFrameSizes = {
    greeting = { 84/2, 126/2 },
    newCard = { 74/2, 74/2 },
    gainSticker = { 66, 48 }
}

Animations.greeting.frameWidth = AnimationFrameSizes.greeting[1]
Animations.greeting.frameHeight = AnimationFrameSizes.greeting[2]
Animations.greeting.grid = anim8.newGrid(Animations.greeting.frameWidth, Animations.greeting.frameHeight, SpriteSheets.greeting:getWidth(), SpriteSheets.greeting:getHeight())
Animations.greeting = { animation = anim8.newAnimation( Animations.greeting.grid("1-2",1), .6 ), running = false }

Animations.newCard.frameWidth = AnimationFrameSizes.newCard[1]
Animations.newCard.frameHeight = AnimationFrameSizes.newCard[2]
Animations.newCard.grid = anim8.newGrid(Animations.newCard.frameWidth, Animations.newCard.frameHeight, SpriteSheets.newCard:getWidth(), SpriteSheets.newCard:getHeight())
Animations.newCard = { animation = anim8.newAnimation( Animations.newCard.grid("1-2",1), .6 ), running = false }

Animations.gainSticker.frameWidth = AnimationFrameSizes.gainSticker[1]
Animations.gainSticker.frameHeight = AnimationFrameSizes.gainSticker[2]
Animations.gainSticker.grid = anim8.newGrid(Animations.gainSticker.frameWidth, Animations.gainSticker.frameHeight, SpriteSheets.gainSticker:getWidth(), SpriteSheets.gainSticker:getHeight())
Animations.gainSticker = { animation = anim8.newAnimation( Animations.gainSticker.grid("1-2",1), .6 ), running = false }



function UpdateAnimations()
    for _, animation in pairs(Animations) do
        animation.animation:update(love.timer.getDelta())
    end
end

function DrawAnimation(animation)
    if not Animations[animation].running then return end

    Animations[animation].frameWidth = AnimationFrameSizes[animation][1]
    Animations[animation].frameHeight = AnimationFrameSizes[animation][2]

    local gx, _ = GetGridAnchorCoords()
    love.graphics.setColor(Dialogue.playing.color)

    local _, wrappedText = Fonts.dialogue:getWrap(Dialogue.playing.textThusFar, Dialogue.playing.limit)
    local y = GetDialogueY() - Animations[animation].frameHeight / 2 - 7 - (#wrappedText - 1) * Fonts.dialogue:getHeight()

    Animations[animation].animation:draw(SpriteSheets[animation], gx + #Grid[1]/2 * SquareGlobalData.width - Animations[animation].frameWidth / 4, y, nil, .5, .5)
end