function SaveData()
    -- local eventualDialoguesTriggered = {}
    -- for _, data in ipairs(Dialogue.eventual) do
    --     table.insert(eventualDialoguesTriggered, data.triggered == true)
    -- end

    local data = {
        Grid = Grid,
        FilesCompleted = FilesCompleted,
        ClearGoal = ClearGoal,
        PinGrid = PinGrid,
        TrailSpawnInterval = TrailSpawnInterval, Trails = Trails,
        Rating = Rating, RatingSubtraction = RatingSubtraction,
        RewardsCollected = RewardsCollected,
        -- eventualDialoguesTriggered = eventualDialoguesTriggered,
        ConditionsCollected = ConditionsCollected,
        UseSpinners = UseSpinners, UseScreens = UseScreens,
        WonScreen = WonScreen, WonSpinner = WonSpinner,
        PlayedWheel = WonSpinner,
    }

    local encoded = love.data.encode("string", "base64", lume.serialize(data))

    love.filesystem.write("data.csv", encoded)
end

function LoadData()
    if not love.filesystem.getInfo("data.csv") then return false end

    local data = lume.deserialize(love.data.decode("string", "base64", love.filesystem.read("data.csv")))

    -- eventualDialoguesTriggered = nil

    for key, value in pairs(data) do
        if value ~= nil and _G[key] ~= nil then
            _G[key] = value
        end
    end

    -- if eventualDialoguesTriggered then
    --     for index, triggered in ipairs(eventualDialoguesTriggered) do
    --         Dialogue.eventual[index].triggered = triggered
    --         if triggered then error() end
    --     end
    -- end

    CalculateGridSize()
end