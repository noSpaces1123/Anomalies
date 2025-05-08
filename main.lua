zutil = require "zutil"
require "grid"
require "interaction"
require "particle"
require "cards"

function love.load()
    zutil.alwaysrandom()
    zutil.stdinit(1440, 900, "Anomalies")

    love.window.setFullscreen(true)

    love.graphics.setBackgroundColor(1,1,1,1)

    SFX = zutil.loadsfx("assets/sfx", {}, "wav")

    Fonts = {
        cleargoal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 30),
        normal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 16),
        small = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 8),
        big = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 50),
    }

    Particles = {}

    NewFile()
    ClearGoal = CalculateClearGoal()

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    UpdateSelectedSquare()
    UpdateParticles()
    UpdateFileGenerationAnimation()
end

function love.draw()
    if GridGlobalData.generationAnimation.running and GridGlobalData.generationAnimation.becauseWrong then
        love.graphics.setBackgroundColor(1,0,0)
    else
        love.graphics.setBackgroundColor(1,1,1)
    end

    DrawGrid()
    DrawClearGoal()
    DrawParticles()

    DrawCards()
end