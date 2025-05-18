Road = {
    running = false,
    playerColumn = 2, playerY = 20,
    width = 350, height = 550,
    columns = 3,
    speed = 3,
    obstacles = {}, obstacleInterval = { current = 0, max = .4*60 },
    obstaclesLeftToSpawn = 0,
}
Road.x = WINDOW.CENTER_X - Road.width / 2
Road.y = WINDOW.CENTER_Y - Road.height / 2



function StartRoad()
    Road.obstacles = {}
    Road.playerColumn = 2
    Road.running = true
    Road.obstacles = {}
    Road.obstacleInterval.current = 0
    Road.obstaclesLeftToSpawn = math.random(7, 12)
end
function UpdateRoadObstacleSpawnInterval()
    if not Road.running then return end

    zutil.updatetimer(Road.obstacleInterval, function ()
        table.insert(Road.obstacles, { y = Road.height, column = math.random(Road.columns) })
        Road.obstaclesLeftToSpawn = Road.obstaclesLeftToSpawn - 1
    end, 1, GlobalDT)
end
function UpdateRoad()
    for _, self in ipairs(Road.obstacles) do
        self.y = self.y - Road.speed * GlobalDT
        if self.y <= 0 then
            zutil.remove(Road.obstacles, self)
        end
    end
end
function DrawRoad()
    if not Road.running then return end

    love.graphics.setColor(Colors[CurrentDepartment].roadBg)
    love.graphics.rectangle("fill", Road.x, Road.y, Road.width, Road.height)

    for _, self in ipairs(Road.obstacles) do
        love.graphics.line()
    end
end