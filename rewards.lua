Rewards = {
    { name = "sticker_50", requirement = function ()
        return Rating >= 50
    end },
    { name = "sticker_100", requirement = function ()
        return Rating >= 100
    end },
    { name = "sticker_200", requirement = function ()
        return Rating >= 200
    end },
    { name = "filescompleted_10", requirement = function ()
        return FilesCompleted >= 10
    end },
    { name = "filescompleted_20", requirement = function ()
        return FilesCompleted >= 20
    end },
    { name = "filescompleted_30", requirement = function ()
        return FilesCompleted >= 30
    end },
    { name = "filescompleted_70", requirement = function ()
        return FilesCompleted >= 70
    end },
    { name = "filescompleted_100", requirement = function ()
        return FilesCompleted >= 100
    end },
}

RewardsCollected = {}
for _, data in ipairs(Rewards) do
    RewardsCollected[data.name] = false
    data.sprite = love.graphics.newImage("assets/sprites/" .. data.name .. ".png", {dpiscale=7})
end



function CheckToGrantRewards()
    local got = false

    local i = 1
    for index, data in ipairs(Rewards) do
        if RewardsCollected[data.name] then i = i + 1 end

        if not RewardsCollected[data.name] and data.requirement() then
            RewardsCollected[data.name] = true
            StartDialogue("list", "gain_" .. data.name, "gainSticker")
            zutil.playsfx(SFX.reward, .3, 1)
            got = true

            local x, y = GetRewardCoords(index, i)
            x, y = x + data.sprite:getWidth()/2, y + data.sprite:getHeight()/2
            for _ = 1, 200 do
                local color = {0,0,0}
                color[math.random(#color)] = 1  ;  color[math.random(#color)] = 1
                table.insert(Particles, NewParticle(x, y, math.random()*3+2, color, math.random()*7, math.random(360), .01, math.random(300,600)))
            end

            i = i + 1
        end
    end

    if got then
        SaveData()
    end
end

function DrawRewards()
    love.graphics.setColor(1,1,1)
    local i = 1
    for index, data in ipairs(Rewards) do
        if RewardsCollected[data.name] then
            local x, y = GetRewardCoords(index, i)
            love.graphics.draw(data.sprite, x, y)
            i = i + 1
        end
    end
end

function GetRewardCoords(rewardIndex, i)
    local anchorCenterX, anchorY = WINDOW.WIDTH - 70, 80
    return anchorCenterX - Rewards[rewardIndex].sprite:getWidth() / 2, anchorY + (i - 1) * 105
end