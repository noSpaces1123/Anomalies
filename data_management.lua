function SaveData()
    local data = {
        Grid = Grid,
        FilesCompleted = FilesCompleted,
        ClearGoal = ClearGoal,
        PinGrid = PinGrid,
        TrailSpawnInterval = TrailSpawnInterval, Trails = Trails,
        Rating = Rating, RatingSubtraction = RatingSubtraction,
        RewardsCollected = RewardsCollected,
    }

    local encoded = love.data.encode("string", "base64", lume.serialize(data))

    love.filesystem.write("data.csv", encoded)
end

function LoadData()
    if not love.filesystem.getInfo("data.csv") then return false end

    local data = lume.deserialize(love.data.decode("string", "base64", love.filesystem.read("data.csv")))

    for key, value in pairs(data) do
        if value ~= nil and _G[key] ~= nil then
            _G[key] = value
        end
    end

    CalculateGridSize()
end