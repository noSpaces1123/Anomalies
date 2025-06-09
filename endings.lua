---@diagnostic disable: need-check-nil, undefined-field

Endings = {
    {
        name = "coma", checkIfToBeCollected = function (departmentCompleted)
            return CurrentDepartment == "D" and departmentCompleted
        end,
        dialogue = {
            { text = "Where am I? Am I alive?" },
            { text = "... It's 2025?", showImage = true },
            { text = "Where is my family?" },
            { text = "... Oh.", showImage = false },
        }
    },
    {
        name = "betrayal", checkIfToBeCollected = function (departmentCompleted)
            return CurrentDepartment == "R" and departmentCompleted
        end,
        dialogue = {
            { text = "What?" },
            { text = "Where is the rebellion? Where are the people?" },
            { text = "... Is that you, Mr Fo", dialogueEndFunc = function ()
                zutil.playsfx(SFX.pistol, .7, 1)
                Dialogue.playing.textThusFar = ""
            end },
        }
    },
    {
        name = "dream", checkIfToBeCollected = function (departmentCompleted)
            local cond = CurrentDepartment == "X" and FilesCompleted == DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted and NMeds.effectDuration.running
            if cond then NMeds.effectDuration.running = false ; TimeMultiplier = 1 end
            return cond
        end,
        dialogue = {
            { text = "Oh wow... Those N-Meds sure work..." },
            { text = "But... This hallucination is different than before." },
            { text = "Where am I?", showImage = true },
        }
    },
    {
        name = "cowardly", checkIfToBeCollected = function (departmentCompleted)
            return CurrentDepartment == "X" and FilesCompleted == DepartmentData[CurrentDepartment].departmentEndAtXFilesCompleted and ClearGoal == 1
        end,
        dialogue = {
            { text = "I asked for it." },
        }
    },
}

for _, ending in ipairs(Endings) do
    local directory = "assets/sprites/ending images/" .. ending.name .. ".png"
    if love.filesystem.getInfo(directory) then ending.image = love.graphics.newImage(directory, {dpiscale = 4}) end
end

EndingDialoguePlaying = {
    running = false,
    dialogueIndex = 1,
    endingIndex = 1,
    imageShowing = false,
    imageAlpha = { current = 0, max = 1, running = false },
    collectedEndingName = "",
}

EndingsCollected = {}

WakeUpTextAlpha = { current = 0, max = 1, running = false }



function CollectEndings()
    for theoryIndex, ending in ipairs(Endings) do
        if ending.checkIfToBeCollected() then
            EndingDialoguePlaying.endingIndex = theoryIndex
            EndingDialoguePlaying.dialogueIndex = 1
            EndingDialoguePlaying.imageShowing = false
            EndingDialoguePlaying.imageAlpha.current = 0
            EndingDialoguePlaying.running = true
            EndingDialoguePlaying.collectedEndingName = ending.name

            WakeUpTextAlpha.current = 0

            TimeMultiplier = 1

            Dialogue.playing.preliminaryWait.max = Dialogue.playing.preliminaryWait.max * 1.5

            GameState = "ending"
            if MusicPlaying.audio then MusicPlaying.audio:stop() end

            StartEndingDialogue(ending.dialogue[1])

            if not zutil.search(EndingsCollected, ending.name) then table.insert(EndingsCollected, ending.name) end

            SaveData()

            return true
        end
    end

    return false
end

function DrawEndingImage()
    if not EndingDialoguePlaying.running or not EndingDialoguePlaying.imageShowing then return end

    local sprite = Endings[EndingDialoguePlaying.endingIndex].image
    love.graphics.setColor(1,1,1, (EndingDialoguePlaying.imageAlpha.running and EndingDialoguePlaying.imageAlpha.current or 1))
    love.graphics.draw(sprite, WINDOW.CENTER_X - sprite:getWidth() / 2, WINDOW.CENTER_Y - sprite:getHeight() / 2)

    zutil.updatetimer(EndingDialoguePlaying.imageAlpha, function ()
        EndingDialoguePlaying.imageAlpha.running = false
    end, 0.01, GlobalDT)
end