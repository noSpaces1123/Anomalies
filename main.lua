zutil = require "zutil"
lume = require "lume"

love.window.setMode(0, 0, {highdpi=true, msaa=4})
love.window.setFullscreen(love.system.getOS() == "OS X")

WINDOW = {
    WIDTH = love.graphics.getWidth(),
    HEIGHT = love.graphics.getHeight(),
}
WINDOW.CENTER_X = WINDOW.WIDTH / 2
WINDOW.CENTER_Y = WINDOW.HEIGHT / 2

require "grid"
require "interaction"
require "particle"
require "cards"
require "data_management"
require "dialogue"
require "rating"
require "rewards"
require "button"
require "handbook"
require "wheel"
require "screen"



function love.load()
    GameName = "Anomalies"

    zutil.alwaysrandom()



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

    Buttons = {}

    UseSpinners = false

    NewFile()
    ClearGoal = CalculateClearGoal()
    PlaceAnomalies()

    LoadData()

    InitialiseButtons()

    StartDialogue("list", "greeting")

    ClickedWithMouse = false

    ShakeIntensity = 0

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    UpdateSelectedSquare()
    UpdateParticles()
    UpdateFileGenerationAnimation()
    UpdateDialogue()
    SearchForDueEventualDialogue()
    UpdateTrailUpdateInterval()
    UpdateTrailSpawnInterval()
    CheckToGrantRewards()
    UpdateButtons()
    UpdateNewCardIndicator()
    UpdateWheel()
    UpdateScreen()
    UpdateShake()

    SpawnBGParticle()

    for _, self in ipairs(BGParticles) do
        self:update()
    end

    UpdateRatingSubtraction()
    ReluRating()
end

function love.draw()
    love.graphics.origin()
    love.graphics.translate(zutil.jitter(ShakeIntensity), zutil.jitter(ShakeIntensity))

    if GridGlobalData.generationAnimation.running and GridGlobalData.generationAnimation.becauseWrong then
        love.graphics.setBackgroundColor(1,0,0)
    else
        love.graphics.setBackgroundColor(1,1,1)
    end

    for _, self in ipairs(BGParticles) do
        self:draw()
    end

    DrawGrid()
    DrawWheel()
    DrawScreen()
    DrawDisplays()
    DrawParticles()
    DrawCards()
    DrawDialogue()
    DrawRewards()
    DrawHandbook()
    DrawButtons()
end



function DrawDisplays()
    local spacing = 10

    if CalculateClearGoal() > 1 then
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(Fonts.cleargoal)
        love.graphics.print("CLEAR " .. ClearGoal .. " MORE ANOMAL" .. (ClearGoal == 1 and "Y" or "IES"), spacing, spacing)

        love.graphics.setLineWidth(1)
        love.graphics.line(spacing + Fonts.cleargoal:getWidth("CLEAR "), spacing + Fonts.cleargoal:getHeight(), spacing + Fonts.cleargoal:getWidth("CLEAR " .. ClearGoal), spacing + Fonts.cleargoal:getHeight())
    end

    if FilesCompleted >= 3 then
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf(FilesCompleted .. " completed files", 0, spacing, WINDOW.WIDTH - spacing, "right")

        love.graphics.setFont(Fonts.rating)
        love.graphics.printf("RATING: " .. math.floor(Rating), 0, spacing * 2 + Fonts.normal:getHeight(), WINDOW.WIDTH - spacing, "right")
    end
end

function SpawnBGParticle()
    local x, y = math.random(0, WINDOW.WIDTH), math.random(0, WINDOW.HEIGHT)

    table.insert(BGParticles, NewParticle(x, y, math.random()*3+1, {0,0,0,1}, math.random()/4, math.deg(zutil.anglebetween(x, y, WINDOW.CENTER_X, WINDOW.CENTER_Y)), 0,
    math.random(100, 300), function (self)
        if self.lifespan >= self.startingLifespan - 100 then
            self.color[4] = (self.startingLifespan - self.lifespan) / 100 * .2
        end
    end))
end

function UpdateShake()
    if ShakeIntensity > 0 then
        ShakeIntensity = zutil.relu(ShakeIntensity - 0.2 * GlobalDT)
    end
end