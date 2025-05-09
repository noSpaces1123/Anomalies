Rewards = {
    { name = "sticker_50", requirement = function ()
        return Rating >= 50
    end },
    { name = "sticker_100", requirement = function ()
        return Rating >= 100
    end },
    { name = "filescompleted_10", requirement = function ()
        return FilesCompleted >= 10
    end },
    { name = "filescompleted_20", requirement = function ()
        return FilesCompleted >= 20
    end },
}

RewardsCollected = {}
for _, data in ipairs(Rewards) do
    RewardsCollected[data.name] = false
    data.sprite = love.graphics.newImage("assets/sprites/" .. data.name .. ".png", {dpiscale=6})
end



function CheckToGrantRewards()
    local got = false

    for index, data in ipairs(Rewards) do
        if not RewardsCollected[data.name] and data.requirement() then
            RewardsCollected[data.name] = true
            StartDialogue("gain_" .. data.name)
            zutil.playsfx(SFX.reward, .3, 1)
            got = true
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
    return anchorCenterX - Rewards[rewardIndex].sprite:getWidth() / 2, anchorY + (i - 1) * 120
end