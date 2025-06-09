---@diagnostic disable: undefined-field

SaveFileDirectory = "data.csv"



function SaveData()
    local data = {
        Grid = Grid,
        FilesCompleted = FilesCompleted,
        ClearGoal = ClearGoal,
        PinGrid = PinGrid,
        TrailSpawnInterval = TrailSpawnInterval, Trails = Trails,
        Rating = Rating, RatingSubtraction = RatingSubtraction,
        RewardsCollected = RewardsCollected,
        ConditionsCollected = ConditionsCollected,
        UseSpinners = UseSpinners, UseScreens = UseScreens,
        WonScreen = WonScreen, WonSpinner = WonSpinner,
        UseRoads = UseRoads,
        PlayedWheel = WonSpinner,
        CurrentDepartment = CurrentDepartment,
        RNEQueueAddInterval = RNEQueueAddInterval, RNEQueueList = RNEQueueList,
        TimeUntilCorruption = TimeUntilCorruption,
        StartedShift = StartedShift,
        CursorState = CursorState,
        DoIntroAnimation = DoIntroAnimation,
        ImmediatelyStartShift = ImmediatelyStartShift,
        Jumpscares = Jumpscares,
        MusicSetting = MusicSetting,
        TimeSpentOnShift = TimeSpentOnShift,
        UnlockedRNEQueue = UnlockedRNEQueue,
        InFullscreen = InFullscreen,
        HasNMeds = HasNMeds,
        PreciseDisplayScaling = PreciseDisplayScaling,
        ReduceScreenshake = ReduceScreenshake,
        AlarmInterval = AlarmInterval,
        UseCameraShots = UseCameraShots,
        EndingsCollected = EndingsCollected,
        DoNotDecreaseClearGoal = DoNotDecreaseClearGoal,
        other = {
            dialogueCharIntervalDefaultMax = Dialogue.playing.charInterval.defaultMax,
            nMedsEffectDuration = NMeds.effectDuration,
        },
    }

    local encoded = love.data.encode("string", "base64", lume.serialize(data))

    love.filesystem.write(SaveFileDirectory, encoded)
end

function LoadData()
    if not love.filesystem.getInfo(SaveFileDirectory) then return false end

    local data = lume.deserialize(love.data.decode("string", "base64", love.filesystem.read(SaveFileDirectory)))

    for key, value in pairs(data) do
        if key ~= "other" and value ~= nil and _G[key] ~= nil then
            _G[key] = value
        end
    end

    if data.other then
        Dialogue.playing.charInterval.defaultMax = zutil.nilcheck(data.other.dialogueCharIntervalDefaultMax, Dialogue.playing.charInterval.defaultMax)
        NMeds.effectDuration = zutil.nilcheck(data.other.nMedsEffectDuration, NMeds.effectDuration)
    end

    CalculateGridSize()
end

function ResetSaveData()
    assert(love.filesystem.remove(SaveFileDirectory), "Save data could not be removed. (love.filesystem.remove failed)")
    assert(not love.filesystem.getInfo(SaveFileDirectory), "Save data could not be removed. (save file persists after love.filesystem.remove passed)")


    FilesCompleted = 0
    CurrentDepartment = "A"
    HasNMeds = false
    if MusicPlaying.audio then MusicPlaying.audio:stop() end
    ConditionsCollected = 2
    Rating = 0
    GridGlobalData.introAnimation = { current = 0, max = 1, running = true }
    DoNotDecreaseClearGoal = false

    InitialiseButtons()
    ResetRNEs()
    InitialiseRewardsCollected()
    LoadMusic()
    InitialiseDialogue()

    love.load()
    LoadData()


    SaveData()
end