zutil = require "zutil"
lume = require "lume"
anim8 = require "anim8"


love.window.setFullscreen(true)

WINDOW = {
    DEFAULT_WIDTH = 1440, DEFAULT_HEIGHT = 900,
    WIDTH = love.graphics.getWidth(),
    HEIGHT = love.graphics.getHeight(),
}
WINDOW.CENTER_X = WINDOW.DEFAULT_WIDTH / 2
WINDOW.CENTER_Y = WINDOW.DEFAULT_HEIGHT / 2
WINDOW.SCALEFACTOR = (WINDOW.HEIGHT / WINDOW.DEFAULT_HEIGHT)
WINDOW.WIDTH, WINDOW.HEIGHT = WINDOW.DEFAULT_WIDTH, WINDOW.DEFAULT_HEIGHT

love.window.setMode(WINDOW.DEFAULT_WIDTH, WINDOW.DEFAULT_HEIGHT, {highdpi=true})



-- love.graphics.setDefaultFilter("nearest", "nearest")

function LoadModules()
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
    require "road"
    require "info"
    require "rne"
    require "animations"
    require "barcode"
    require "nmeds"
    require "cameraShot"
    require "endings"
end

LoadModules()



function love.load()
    NameOfTheGame = "Anomalies"

    zutil.alwaysrandom()



    SFX = zutil.loadsfx("assets/sfx", {}, "wav")

    Sprites = {
        pin = love.graphics.newImage("assets/sprites/pin.png", {dpiscale=6}),
        title = love.graphics.newImage("assets/sprites/Anomalies title.png", {dpiscale=3}),
        frazyfrazy = love.graphics.newImage("assets/sprites/frazyfrazy.png", {dpiscale=10}),
        musicSymbol = love.graphics.newImage("assets/sprites/music symbol.png", {dpiscale=7}),
    }

    TitleFade = { current = 0, max = 1, running = true }
    TitleColor = {
        lerpT = 0, lerpTSpeed = 1/(10*60),
        lerpEnds = {},
        lerpEnd2Index = 2,
    }

    IntroOpeningBars = {
        running = false,
        y = { current = 0, actual = 0, max = WINDOW.CENTER_Y },
        speed = 1,
    }
    DoIntroAnimation = true

    Cursors = {
        normal = love.graphics.newImage("assets/sprites/cursor/normal.png", {dpiscale=3}),
        clicked = love.graphics.newImage("assets/sprites/cursor/clicked.png", {dpiscale=3}),
        disallowed = love.graphics.newImage("assets/sprites/cursor/disallowed.png", {dpiscale=3}),
        barcodeScanner = love.graphics.newImage("assets/sprites/cursor/barcodeScanner.png", {dpiscale=2.5}),
    }
    CursorState = "normal"

    Fonts = {
        cleargoal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_SemiExpanded-Light.ttf", 30),
        rating = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 22),
        normal = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Light.ttf", 16),
        handbook = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Bold.ttf", 16),
        small = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Regular.ttf", 10),
        smallBold = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-Bold.ttf", 10),
        smallBoldExpanded = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Expanded-Bold.ttf", 10),
        big = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata-ExtraLight.ttf", 50),
        dialogue = love.graphics.newFont("assets/fonts/Inconsolata/static/Inconsolata_Condensed-Medium.ttf", 16),
    }

    MusicPlaying = { name = nil, audio = nil }
    MusicSetting = 1

    MainTheme = love.audio.newSource("assets/music/Sanctuary (Anomalies Main Theme).wav", "stream")
    MainTheme:setVolume(.3)
    TenseMusic = love.audio.newSource("assets/music/Fence.wav", "stream")
    TenseMusic:setVolume(.3)
    TenseMusic:setLooping(true)

    ImmediatelyStartShift = false
    Jumpscares = true
    InFullscreen = true
    PreciseDisplayScaling = true
    ReduceScreenshake = false

    StartedShift = false
    TimeSpentOnShift = 0

    FocusedOnWindow = true

    DoNotDecreaseClearGoal = false

    Flash = { current = 0, max = 1, running = false }



    Particles = {}
    BGParticles = {}

    NewFile()
    ClearGoal = CalculateClearGoal()
    PlaceAnomalies()

    LoadData()

    IntroOpeningBars.running = DoIntroAnimation
    TitleFade.running = DoIntroAnimation

    love.window.setFullscreen(InFullscreen)

    -- FilesCompleted = 24
    -- ConditionsCollected = 0
    -- CurrentDepartment = "X"
    -- ClearGoal = 2
    -- WonSpinner = true
    -- UseScreens = true
    -- UseRoads = true
    -- HasNMeds = false

    LoadCards()

    LoadMusic()

    if HasNMeds then
    elseif MusicSetting == 1 then
        StartMusic((StartedShift and zutil.randomchoice(Music) or Music[1]))
    elseif MusicSetting == 2 then
        StartBrownNoise()
    end

    InitialiseButtons()

    StartDialogue("list", (StartedShift and "greeting" or "firstEverGreeting"), "greeting")

    ClickedWithMouse = false

    ShakeIntensity = 0

    EndOfContent = {
        reached = function ()
            return false
        end,
        showing = false,
    }

    GameState = "menu"

    love.graphics.setBackgroundColor(Colors[CurrentDepartment].bg)

    TimeMultiplier = 1
    GlobalUnalteredDT = 0
    GlobalDT = 0
end

function love.update(dt)
    GlobalUnalteredDT = dt * 60
    GlobalDT = GlobalUnalteredDT * TimeMultiplier

    if InFullscreen then WINDOW.SCALEFACTOR = (not PreciseDisplayScaling and math.floor or function (x) return x end)(love.graphics.getHeight() / WINDOW.DEFAULT_HEIGHT) end

    if GameState == "game" then
        CollectEndings()
        UpdateSelectedSquare()
        UpdateFileGenerationAnimation()
        SearchForDueEventualDialogue()
        UpdateTrailUpdateInterval()
        UpdateTrailSpawnInterval()
        CheckToGrantRewards()
        UpdateNewCardIndicator()
        UpdateWheel()
        UpdateScreen()
        UpdateRoad()
        UpdateRoadObstacleSpawnInterval()
        UpdateDepartmentTransition()
        ApplyDepartmentEvents()
        UpdateRNEPracticeWait()
        UpdateRNEQueue()
        CheckForEndOfContent()
        UpdateRatingSubtraction()
        ReluRating()
        UpdateGridIntroAnimation()
        UpdateTimeSpentOnShift()
        UpdateNMedsEffectDelay()
        UpdateNMedsDuration()
        UpdateBarcodeConclusionDelay()
        UpdateAlarmInterval()
        UpdateAlarmDelay()
        UpdateCameraShotOverlay()
    elseif GameState == "menu" then
        if TitleFade.running then
            zutil.updatetimer(TitleFade, function ()
                TitleFade.running = false
            end, .004, GlobalDT)
        end
    end

    UpdateShake()
    UpdateDialogue()
    UpdateParticles()
    UpdateButtons()
    UpdateMusic()
    SpawnBGParticle()
    UpdateAnimations()
    UpdateTitleColor()
    UpdateFlash()

    UpdateIntroOpeningBars()

    if not HasNMeds then
        for _, self in ipairs(BGParticles) do
            self:update()
        end
    end

    UpdateCursor()
    ConfineMouse()
end

function love.draw()
    local offsetX, offsetY = (love.graphics.getWidth() - WINDOW.WIDTH * WINDOW.SCALEFACTOR) / 2, (love.graphics.getHeight() - WINDOW.HEIGHT * WINDOW.SCALEFACTOR) / 2
    love.graphics.translate(offsetX, offsetY)

    local shake = ShakeIntensity / (ReduceScreenshake and 2 or 1)
    love.graphics.translate(zutil.jitter(shake), zutil.jitter(shake))

    if InFullscreen then love.graphics.scale(WINDOW.SCALEFACTOR, WINDOW.SCALEFACTOR) end

    love.graphics.push()

    if NMeds.effectDuration.running then
        local function find()
            return zutil.jitter(CalculateNMedsEffectIntensity())^5 * 2
        end

        love.graphics.translate(find(), find())
    elseif CurrentDepartment == "D" and FilesCompleted + 1 == DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted then
        local function find()
            return zutil.jitter(1)^7 * 1.2
        end

        love.graphics.translate(find(), find())
    end



    if GameState == "game" then
        if DepartmentTransition.running then
            love.graphics.setBackgroundColor(0,0,0)
        elseif GridGlobalData.generationAnimation.running and GridGlobalData.generationAnimation.becauseWrong then
            love.graphics.setBackgroundColor(1,0,0)
        else
            love.graphics.setBackgroundColor(Colors[CurrentDepartment].bg)
        end

        DrawGameFrame()
    elseif GameState == "ending" then
        love.graphics.setBackgroundColor(0,0,0)

        DrawEndingImage()
        DrawDialogue()
    elseif GameState == "ending collected" then
        love.graphics.setBackgroundColor(0,0,0)

        love.graphics.setFont(Fonts.big)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(string.upper(EndingDialoguePlaying.collectedEndingName) .. " ENDING", 0, WINDOW.CENTER_Y - Fonts.big:getHeight() / 2, WINDOW.WIDTH, "center")

        love.graphics.setFont(Fonts.normal)
        love.graphics.printf(#EndingsCollected .. " / " .. #Endings, 0, WINDOW.CENTER_Y + Fonts.big:getHeight() / 2 + 10, WINDOW.WIDTH, "center")


        -- wake up text
        if WakeUpTextAlpha.running then
            zutil.updatetimer(WakeUpTextAlpha, function ()
                WakeUpTextAlpha.running = false
            end, 0.001, GlobalDT)
        end

        love.graphics.setFont(Fonts.small)
        love.graphics.setColor(1,1,1, (WakeUpTextAlpha.running and WakeUpTextAlpha.current or 1) * .8)
        love.graphics.printf("Left-click to wake up.", 0, WINDOW.HEIGHT - Fonts.small:getHeight() - 10, WINDOW.WIDTH, "center")
    else
        love.graphics.setBackgroundColor(Colors[CurrentDepartment].bg)

        for _, self in ipairs(BGParticles) do
            self:draw()
        end

        DrawParticles()
        DrawDialogue()
        DrawButtons()

        if GameState == "menu" then
            love.graphics.setColor(SetTitleColor())
            love.graphics.draw(Sprites.title, WINDOW.CENTER_X - Sprites.title:getWidth()/2, 160)

            if StartedShift then
                love.graphics.setFont(Fonts.smallBoldExpanded)
                love.graphics.print("DEPARTMENT "..CurrentDepartment, 635, 250)
            end

---@diagnostic disable-next-line: undefined-field
            if StartedShift and MusicPlaying.audio and MusicPlaying.audio:isPlaying() then
                local spacing = 10
                love.graphics.setColor(Colors[CurrentDepartment].text)
                love.graphics.setFont(Fonts.normal)
                love.graphics.printf(MusicPlaying.name .. " - Anti-Hat", 0, WINDOW.HEIGHT - Fonts.normal:getHeight() - spacing, WINDOW.WIDTH - spacing * 2 - Sprites.musicSymbol:getWidth(), "right")

                love.graphics.draw(Sprites.musicSymbol, WINDOW.WIDTH - spacing - Sprites.musicSymbol:getWidth(), WINDOW.HEIGHT - Sprites.musicSymbol:getHeight() - spacing)
            end

            DisplayTimeSpentOnShift()

            DrawInfo()
        end

        DrawIntroOpeningBars()
    end



    DrawCursor()

    love.graphics.pop()

    DrawNMedsEffectOverlay()
    DrawCameraShotOverlay()

    love.graphics.origin()

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, 0, offsetX, love.graphics.getHeight())
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), offsetY)
    love.graphics.rectangle("fill", offsetX + WINDOW.WIDTH * WINDOW.SCALEFACTOR, 0, offsetX, love.graphics.getHeight())
    love.graphics.rectangle("fill", 0, offsetY + WINDOW.HEIGHT * WINDOW.SCALEFACTOR, love.graphics.getWidth(), offsetY)

    DrawFlash()
end
function DrawGameFrame()
    DrawBG()

    if not DepartmentTransition.running then
        for _, self in ipairs(BGParticles) do
            self:draw()
        end

        DrawGrid()
        DrawWheel()
        DrawScreen()
        DrawRoad()
        DrawBarcode()
        DrawNMeds()
        DrawGameDisplays()
        DrawParticles()
        DrawCards()
        DrawRewards()
    end

    DrawDialogue()
    DrawRNEPracticeWaitScreen()
    DrawRNEQueueSourcePerson()

    if not DepartmentTransition.running then
        DrawHandbook()
    end

    DrawButtons()

    DrawEndOfContentScreen()
end

function love.quit()
    SaveData()
end

function love.focus(focused)
    FocusedOnWindow = focused

    if not focused and GameState == "game" then
        StartDialogue("list", "notFocusedOnWindow")
    end
end



function DrawGameDisplays()
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
    if HasNMeds then return end

    local x, y = math.random(0, WINDOW.WIDTH), math.random(0, WINDOW.HEIGHT)

    local color = {Colors[CurrentDepartment].bgParticles[1],Colors[CurrentDepartment].bgParticles[2],Colors[CurrentDepartment].bgParticles[3]}

    table.insert(BGParticles, NewParticle(x, y, math.random()*3+1, color, math.random()/4, 0, 0,
    math.random(100, 300), function (self)
        if self.lifespan >= self.startingLifespan - 100 then
            self.color[4] = (self.startingLifespan - self.lifespan) / 100 * .2
        end
        self.degrees = math.deg(zutil.anglebetween(self.x, self.y, love.mouse.getX(), love.mouse.getY()))
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
            table.insert(Music, { name = zutil.split(fileName, ".")[1], audio = love.audio.newSource(directory .. "/" .. fileName, "stream") })
        end
    end
end
function StartMusic(music)
    if MusicSetting ~= 1 then return end

    MusicPlaying.audio = music.audio
    MusicPlaying.name = music.name

---@diagnostic disable-next-line: undefined-field
MusicPlaying.audio:setVolume(.2)
---@diagnostic disable-next-line: undefined-field
    MusicPlaying.audio:play()
end
function UpdateMusic()
    if DepartmentTransition.running or MusicSetting ~= 1 or HasNMeds or Barcode.conclusionDelay.running or AlarmDelay.running or GameState == "ending" or GameState == "ending collected" then return end
    if NMeds.effectDelay.running and CurrentDepartment == "X" and FilesCompleted == DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted then return end

---@diagnostic disable-next-line: undefined-field
    if not MusicPlaying.audio:isPlaying() then
        local viable = {}
        for _, value in ipairs(Music) do
            if value.name ~= MusicPlaying.name then
                table.insert(viable, value)
            end
        end

        if #viable > 0 then
            StartMusic(zutil.randomchoice(viable))
        else
            StartMusic(MusicPlaying)
        end
    elseif MusicPlaying.audio then
---@diagnostic disable-next-line: undefined-field
        MusicPlaying.audio:setPitch(TimeMultiplier)
    end
end

function StartBrownNoise()
    SFX.brownNoise:setLooping(true)
    zutil.playsfx(SFX.brownNoise, .1, 1)
end

function UpdateCursor()
    if CursorState == "regular cursor" then
        love.mouse.setVisible(true)
        return
    end

    if love.mouse.isVisible() then
        love.mouse.setVisible(false)
    end

    CursorState = "normal"

    if Screen.running and not Screen.shutterDone then
        CursorState = "disallowed"
    elseif GridGlobalData.generationAnimation.running then
        CursorState = "disallowed"
    elseif Barcode.running then
        CursorState = (Barcode.conclusionDelay.running and "disallowed" or "barcodeScanner")
    elseif Spinner.running or (DepartmentTransition.running and #DepartmentTree[CurrentDepartment] == 1) or EndingDialoguePlaying.running then
        CursorState = "invisible"
    elseif love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3) then
        CursorState = "clicked"
    end
end
function DrawCursor()
    if CursorState == "regular cursor" then return end
    local sprite = Cursors[CursorState]
    if CursorState == "invisible" then return end
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprite, love.mouse.getX() - sprite:getWidth() / 2, love.mouse.getY() - sprite:getHeight() / 2)
end

function CheckForEndOfContent()
    if EndOfContent.reached() and not EndOfContent.showing then
        EndOfContent.showing = true
    end
end
function DrawEndOfContentScreen()
    if not EndOfContent.showing then return end

    love.graphics.overlay(0,0,0)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("You've reached the end of Anomalies- for now.\n\nNew updates will be out soon. Stay tuned~", 0, WINDOW.CENTER_Y - Fonts.normal:getHeight()/2, WINDOW.WIDTH, "center")
end

function UpdateIntroOpeningBars()
    if not IntroOpeningBars.running then return end

    zutil.updatetimer(IntroOpeningBars.y, function ()
        IntroOpeningBars.running = false
    end, 1.5, GlobalDT)
    IntroOpeningBars.y.actual = zutil.lerp(WINDOW.CENTER_Y, 0, zutil.easing.easeOutExpo(zutil.reverselerp(0, IntroOpeningBars.y.max, IntroOpeningBars.y.current)))
end
function DrawIntroOpeningBars()
    if not IntroOpeningBars.running then return end
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", 0, 0, WINDOW.WIDTH, IntroOpeningBars.y.actual)
    love.graphics.rectangle("fill", 0, WINDOW.HEIGHT - IntroOpeningBars.y.actual, WINDOW.WIDTH, IntroOpeningBars.y.actual)
    zutil.overlay({0,0,0, 1-IntroOpeningBars.y.current/IntroOpeningBars.y.max})
end

function UpdateTimeSpentOnShift()
    TimeSpentOnShift = TimeSpentOnShift + love.timer.getDelta()
end
function DisplayTimeSpentOnShift()
    if not StartedShift then return end
    love.graphics.setFont(Fonts.smallBold)
    love.graphics.setColor(Colors[CurrentDepartment].text)
    love.graphics.printf(TimeInSecondsToStupidHumanFormat(TimeSpentOnShift) .. " spent on shift", 0, WINDOW.HEIGHT - Fonts.smallBold:getHeight() - 10, WINDOW.WIDTH, "center")
end
function TimeInSecondsToStupidHumanFormat(time)
    local seconds = tostring(math.floor(time % 60))
    local minutes = tostring(math.floor(time / 60 % 60))
    local hours = tostring(math.floor(time / 60 / 60))
    return hours .. " : " .. (#minutes == 1 and "0" or "") .. minutes .. " : " .. (#seconds == 1 and "0" or "") .. seconds
end

function UpdateTitleColor()
    if #Colors[CurrentDepartment].titleColors > 1 then
        if TitleColor.lerpT >= 1 or #TitleColor.lerpEnds == 0 then
            TitleColor.lerpEnd2Index = zutil.wrap(TitleColor.lerpEnd2Index + (#TitleColor.lerpEnds > 0 and 1 or 0), 0, #Colors[CurrentDepartment].titleColors)
            TitleColor.lerpEnds = {Colors[CurrentDepartment].titleColors[zutil.wrap(TitleColor.lerpEnd2Index-1, 1, #Colors[CurrentDepartment].titleColors + 1)], Colors[CurrentDepartment].titleColors[TitleColor.lerpEnd2Index]}
            TitleColor.lerpT = 0
        end

        TitleColor.lerpT = TitleColor.lerpT + TitleColor.lerpTSpeed * GlobalDT
    end
end
function SetTitleColor()
    if #Colors[CurrentDepartment].titleColors == 1 then
        love.graphics.setColor(Colors[CurrentDepartment].titleColors[1])
        return Colors[CurrentDepartment].titleColors[1][1], Colors[CurrentDepartment].titleColors[1][2], Colors[CurrentDepartment].titleColors[1][3]
    else
        local color = {}
        for i = 1, 3 do
            table.insert(color, zutil.lerp(TitleColor.lerpEnds[1][i], TitleColor.lerpEnds[2][i], TitleColor.lerpT))
        end
        table.insert(color, (TitleFade.running and TitleFade.current or 1))

        return color[1], color[2], color[3], color[4]
    end
end

function ConfineMouse()
    local mx, my = love.mouse.getPosition()
    if mx > WINDOW.WIDTH then love.mouse.setPosition(WINDOW.WIDTH, my) end
    mx, my = love.mouse.getPosition()
    if my > WINDOW.HEIGHT then love.mouse.setPosition(mx, WINDOW.HEIGHT) end
end

function StartFlash(durationSeconds)
    Flash.max = durationSeconds * 60
    Flash.running = true
end
function UpdateFlash()
    if not Flash.running then return end

    zutil.updatetimer(Flash, function ()
        Flash.running = false
    end, 1, GlobalDT)
end
function DrawFlash()
    if not Flash.running then return end
    zutil.overlay({1,1,1})
end