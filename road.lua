Road = {
    conditionsMetWhenStarted = nil,
    running = false,
    playerColumn = 2, playerY = 20, playerRadius = 8,
    width = 200, height = 550,
    columns = 3,
    speed = 10,
    obstacles = {}, obstacleInterval = { current = 0, max = .4*60 },
    obstaclesLeftToSpawn = 0,
}
Road.x = WINDOW.CENTER_X - Road.width / 2
Road.y = WINDOW.CENTER_Y - Road.height / 2

UseRoads = false



function StartRoad(conditionsMetWhenStarted)
    Road.obstacles = {}
    Road.playerColumn = 2
    Road.running = true
    Road.obstacles = {}
    Road.obstacleInterval.current = 0
    Road.obstaclesLeftToSpawn = math.random(10, 17)

    Road.conditionsMetWhenStarted = conditionsMetWhenStarted
end
function UpdateRoadObstacleSpawnInterval()
    if not Road.running then return end

    zutil.updatetimer(Road.obstacleInterval, function ()
        if Road.obstaclesLeftToSpawn <= 0 then return end

        for _ = 1, (zutil.weightedbool(33) and 2 or 1) do
            table.insert(Road.obstacles, { y = Road.height, column = math.random(Road.columns), tend = math.random(0,30)/10 })
        end
        Road.obstaclesLeftToSpawn = Road.obstaclesLeftToSpawn - 1
    end, 1, GlobalDT)
end
function UpdateRoad()
    if not Road.running then return end

    for _, self in ipairs(Road.obstacles) do
        local limit = 10
        for _ = 1, limit do
            self.y = self.y - Road.speed * GlobalDT / limit + self.tend * GlobalDT / limit
            if self.y <= 0 then
                zutil.remove(Road.obstacles, self)
            end

            local startX = Road.x + Road.width/Road.columns*(self.column - 1)
            if zutil.touching(startX, self.y + Road.y, Road.width/Road.columns, 0,   Road.x + Road.width/Road.columns*(Road.playerColumn-1+.5) - Road.playerRadius, Road.y + Road.playerY - Road.playerRadius, Road.playerRadius*2, Road.playerRadius*2) then
                if RNEPractice.running then
                    zutil.playsfx(SFX.rnePracticeFail, .3, 1)
                    if RNEQueue.doing then NewRNEQueueItem() end
                else Wrong() end
                RNEPractice.running = false
                RNEQueue.doing = false
                Road.running = false

                return
            end
        end
    end

    if #Road.obstacles <= 0 and Road.obstaclesLeftToSpawn <= 0 then
        zutil.playsfx(SFX.rneComplete, .4, 1)
        PerhapsPlayVoicedAffirmationSFX()

        if RNEPractice.running then
            if RNEQueue.doing then AdjustRating("did rne queue") end
        else
            PopSquare(SquareSelected.x, SquareSelected.y, Road.conditionsMetWhenStarted)
        end

        RNEPractice.running = false
        RNEQueue.doing = false
        Road.running = false
    end
end
function DrawRoad()
    if not Road.running then return end

    love.graphics.setColor(Colors[CurrentDepartment].roadBg)
    love.graphics.rectangle("fill", Road.x, Road.y, Road.width, Road.height)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(Colors[CurrentDepartment].roadOutline)
    for _, self in ipairs(Road.obstacles) do
        local startX = Road.x + Road.width/Road.columns*(self.column - 1)
        love.graphics.line(startX, self.y + Road.y, startX+Road.width/Road.columns, self.y + Road.y)
    end

    love.graphics.setColor(Colors[CurrentDepartment].roadPlayer)
    love.graphics.circle("fill", Road.x + Road.width/Road.columns*(Road.playerColumn-1+.5), Road.y + Road.playerY, Road.playerRadius, 500)

    love.graphics.setLineWidth(5)
    love.graphics.setColor(Colors[CurrentDepartment].roadOutline)
    love.graphics.rectangle("line", Road.x, Road.y, Road.width, Road.height)
end