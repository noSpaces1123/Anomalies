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
        other = {
            dialogueCharIntervalDefaultMax = Dialogue.playing.charInterval.defaultMax,
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
        Dialogue.playing.charInterval.defaultMax = zutil.nilcheck(data.other.dialogueCharIntervalDefaultMax, data.other.dialogueCharIntervalDefaultMax, Dialogue.playing.charInterval.defaultMax)
    end

    CalculateGridSize()
end