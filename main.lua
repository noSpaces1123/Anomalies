zutil = require "zutil"
lume = require "lume"
require "grid"
require "interaction"
require "particle"
require "cards"
require "data_management"
require "dialogue"
require "rating"
require "rewards"



function love.load()
    GameName = "Anomalies"

    zutil.alwaysrandom()



    love.window.setMode(0, 0, {highdpi=true, msaa=4})
    love.window.setFullscreen(love.system.getOS() == "OS X")

    WINDOW = {
        WIDTH = love.graphics.getWidth(),
        HEIGHT = love.graphics.getHeight(),
    }
    WINDOW.CENTER_X = WINDOW.WIDTH / 2
    WINDOW.CENTER_Y = WINDOW.HEIGHT / 2

    love.window.setTitle(GameName)
    love.filesystem.setIdentity(GameName)

    love.graphics.setBackgroundColor(1,1,1,1)



    SFX = zutil.loadsfx("assets/sfx", {}, "wav")

    Sprites = {
        pin = love.graphics.newImage("assets/sprites/pin.png", {dpiscale=6}),
    }

    Fonts = {
        cleargoal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_SemiExpanded-Light.ttf", 30),
        rating = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 22),
        normal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 16),
        small = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 8),
        big = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 50),
        dialogue = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 16),
    }

    Music = love.audio.newSource("assets/music/Anomalies.wav", "stream")
    Music:setLooping(true)
    Music:setVolume(.2)
    Music:play()

    Particles = {}
    BGParticles = {}

    NewFile()
    ClearGoal = CalculateClearGoal()

    LoadData()

    StartDialogue("greeting")

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    UpdateSelectedSquare()
    UpdateParticles()
    UpdateFileGenerationAnimation()
    UpdateDialogue()
    UpdateTrailUpdateInterval()
    UpdateTrailSpawnInterval()
    CheckToGrantRewards()

    SpawnBGParticle()

    for _, self in ipairs(BGParticles) do
        self:update()
    end

    UpdateRatingSubtraction()
    ReluRating()
end

function love.draw()
    if GridGlobalData.generationAnimation.running and GridGlobalData.generationAnimation.becauseWrong then
        love.graphics.setBackgroundColor(1,0,0)
    else
        love.graphics.setBackgroundColor(1,1,1)
    end

    for _, self in ipairs(BGParticles) do
        self:draw()
    end

    DrawGrid()
    DrawDisplays()
    DrawParticles()

    DrawCards()

    DrawDialogue()

    DrawRewards()
end



function DrawDisplays()
    local spacing = 10
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(Fonts.cleargoal)
    love.graphics.print("CLEAR " .. ClearGoal .. " MORE ANOMAL" .. (ClearGoal == 1 and "Y" or "IES"), spacing, spacing)

    love.graphics.setLineWidth(1)
    love.graphics.line(spacing + Fonts.cleargoal:getWidth("CLEAR "), spacing + Fonts.cleargoal:getHeight(), spacing + Fonts.cleargoal:getWidth("CLEAR " .. ClearGoal), spacing + Fonts.cleargoal:getHeight())


    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(FilesCompleted .. " completed files", 0, spacing, WINDOW.WIDTH - spacing, "right")

    love.graphics.setFont(Fonts.rating)
    love.graphics.printf("RATING: " .. Rating, 0, spacing * 2 + Fonts.normal:getHeight(), WINDOW.WIDTH - spacing, "right")
end

function SpawnBGParticle()
    local x, y = math.random(0, WINDOW.WIDTH), math.random(0, WINDOW.HEIGHT)

    table.insert(BGParticles, NewParticle(x, y, math.random()*3+1, {0,0,0,1}, math.random()/7, math.deg(zutil.anglebetween(x, y, WINDOW.CENTER_X, WINDOW.CENTER_Y)), 0,
    math.random(100, 300), function (self)
        if self.lifespan >= self.startingLifespan - 100 then
            self.color[4] = (self.startingLifespan - self.lifespan) / 100 * .2
        end
    end))
end