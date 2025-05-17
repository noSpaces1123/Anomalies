zutil = require "zutil"
lume = require "lume"

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
require "department"
require "cards"
require "data_management"
require "dialogue"
require "rating"
require "rewards"
require "button"
require "handbook"
require "wheel"
require "screen"
require "info"
require "rnepractice"



function love.load()
    GameName = "Anomalies"

    zutil.alwaysrandom()



    SFX = zutil.loadsfx("assets/sfx", {}, "wav")

    Sprites = {
        pin = love.graphics.newImage("assets/sprites/pin.png", {dpiscale=6}),
    }

    Cursors = {
        normal = love.graphics.newImage("assets/sprites/cursor/normal.png", {dpiscale=3}),
        clicked = love.graphics.newImage("assets/sprites/cursor/clicked.png", {dpiscale=3}),
        disallowed = love.graphics.newImage("assets/sprites/cursor/disallowed.png", {dpiscale=3}),
    }
    CursorState = "normal"

    Fonts = {
        cleargoal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_SemiExpanded-Light.ttf", 30),
        rating = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 22),
        normal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Light.ttf", 16),
        handbook = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Bold.ttf", 16),
        small = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Regular.ttf", 10),
        big = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 50),
        dialogue = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 16),
    }

    MusicPlaying = nil



    Particles = {}
    BGParticles = {}

    Buttons = {}

    NewFile()
    ClearGoal = CalculateClearGoal()
    PlaceAnomalies()

    LoadData()

    -- FilesCompleted = 34
    -- ConditionsCollected = 6

    LoadCards()

    LoadMusic()
    StartMusic(zutil.randomchoice(Music))

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
    UpdateMusic()
    UpdateDepartmentTransition()
    UpdateTimeUntilCorruption()
    UpdateRNEPracticeWait()

    SpawnBGParticle()

    for _, self in ipairs(BGParticles) do
        self:update()
    end

    UpdateRatingSubtraction()
    ReluRating()

    UpdateCursor()
end

function love.draw()
    if DepartmentTransition.running then
        love.graphics.setBackgroundColor(0,0,0)
    elseif GridGlobalData.generationAnimation.running and GridGlobalData.generationAnimation.becauseWrong then
        love.graphics.setBackgroundColor(1,0,0)
    else
        love.graphics.setBackgroundColor(Colors[CurrentDepartment].bg)
    end

    DrawFrame()
end
function DrawFrame()
    love.graphics.origin()

    DrawBG()

    love.graphics.translate(zutil.jitter(ShakeIntensity), zutil.jitter(ShakeIntensity))

    if not DepartmentTransition.running then
        for _, self in ipairs(BGParticles) do
            self:draw()
        end

        DrawGrid()
        DrawWheel()
        DrawScreen()
        DrawDisplays()
        DrawParticles()
        DrawCards()
        DrawRewards()
    end

    DrawDialogue()
    DrawRNEPracticeWaitScreen()

    if not DepartmentTransition.running then
        DrawHandbook()
        DrawInfo()
        DrawButtons()
    end

    DrawCursor()
end



function DrawDisplays()
    local spacing = 10

    love.graphics.setColor(Colors[CurrentDepartment].text)

    if CalculateClearGoal() > 1 then
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

    local color = {Colors[CurrentDepartment].bgParticles[1],Colors[CurrentDepartment].bgParticles[2],Colors[CurrentDepartment].bgParticles[3]}

    table.insert(BGParticles, NewParticle(x, y, math.random()*3+1, color, math.random()/4, math.deg(zutil.anglebetween(x, y, WINDOW.CENTER_X, WINDOW.CENTER_Y)), 0,
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

function LoadMusic()
    Music = {}
    local directory = "assets/music/department " .. CurrentDepartment
    for _, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
        if fileName ~= ".DS_Store" then
            table.insert(Music, love.audio.newSource(directory .. "/" .. fileName, "stream"))
        end
    end
end
function StartMusic(music)
    MusicPlaying = music
    MusicPlaying:setVolume(.2)
    MusicPlaying:play()
end
function UpdateMusic()
    if DepartmentTransition.running then return end

---@diagnostic disable-next-line: undefined-field
    if not MusicPlaying:isPlaying() then
        local viable = {}
        for _, value in ipairs(Music) do
            if value ~= MusicPlaying then
                table.insert(viable, value)
            end
        end

        if #viable > 0 then
            StartMusic(zutil.randomchoice(viable))
        else
            StartMusic(MusicPlaying)
        end
    end
end

function UpdateCursor()
    if love.mouse.isVisible() then
        love.mouse.setVisible(false)
    end

    CursorState = "normal"

    if Screen.running and not Screen.shutterDone then
        CursorState = "disallowed"
    elseif GridGlobalData.generationAnimation.running then
        CursorState = "disallowed"
    elseif Spinner.running or DepartmentTransition.running then
        CursorState = "invisible"
    elseif love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3) then
        CursorState = "clicked"
    end
end
function DrawCursor()
    local sprite = Cursors[CursorState]
    if CursorState == "invisible" then return end
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprite, love.mouse.getX() - sprite:getWidth() / 2, love.mouse.getY() - sprite:getHeight() / 2)
end