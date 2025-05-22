CurrentDepartment = "A"

Colors = {
    A = {
        bg = {1,1,1},
        bgParticles = {0,0,0},
        fileBg = {1,1,1},
        fileOutline = {0,0,0},
        text = {0,0,0},
        type3Square = {0,1,1},
        squares = {0,0,0},
        screenBg = {1,1,1},
        screenOutline = {0,0,0},
        screenDots = {0,0,0},
        screenGrid = {.95,.95,.95},
    },

    B = {
        bg = {1/255, 4/255, 0},
        bgParticles = {232/255, 238/255, 242/255},
        fileBg = {232/255, 238/255, 242/255},
        fileOutline = {232/255, 238/255, 242/255},
        text = {232/255, 238/255, 242/255},
        type3Square = {221/255, 45/255, 74/255},
        squares = {1/255, 4/255, 0},
        screenBg = {1/255, 4/255, 0},
        screenOutline = {221/255, 45/255, 74/255},
        screenDots = {232/255, 238/255, 242/255},
        screenGrid = {221/255/2, 45/255/2, 74/255/2},
        roadBg = {232/255, 238/255, 242/255},
        roadOutline = {1/255, 4/255, 0},
        roadPlayer = {221/255, 45/255, 74/255},
    },

    -- X = {
    --     bg = {1/255, 4/255, 0},
    --     bgParticles = {232/255, 238/255, 242/255},
    --     fileBg = {232/255, 238/255, 242/255},
    --     fileOutline = {232/255, 238/255, 242/255},
    --     text = {232/255, 238/255, 242/255},
    --     type3Square = {221/255, 45/255, 74/255},
    --     squares = {1/255, 4/255, 0},
    --     screenBg = {1/255, 4/255, 0},
    --     screenOutline = {221/255, 45/255, 74/255},
    --     screenDots = {232/255, 238/255, 242/255},
    --     screenGrid = {221/255/2, 45/255/2, 74/255/2},
    --     roadBg = {232/255, 238/255, 242/255},
    --     roadOutline = {1/255, 4/255, 0},
    --     roadPlayer = {221/255, 45/255, 74/255},
    -- },
}

DepartmentData = {
    A = {
        squarePalette = { ["0"] = 1, ["1"] = 1, ["2"] = 1 },
        shutterSpeed = 2,
        screenDotAlphaDecreaseSpeed = .02,
        pointerAcceleration = .04,
        findGridWidthAndHeight = function ()
            GridGlobalData.width = math.floor(FilesCompleted / 3) + 5
            GridGlobalData.height = GridGlobalData.width
        end,
    },

    B = {
        squarePalette = { ["0"] = 6, ["1"] = 1, ["2"] = 1, ["3"] = 1 },
        shutterSpeed = 4,
        screenDotAlphaDecreaseSpeed = .04,
        pointerAcceleration = .07,
        findGridWidthAndHeight = function ()
            local find = function ()
                return zutil.clamp(math.floor(FilesCompleted / 3) + 9 + math.random(-3, 4), 4, math.huge)
            end

            GridGlobalData.width = find()
            GridGlobalData.height = find()
        end,
    },
}

DepartmentTransition = {
    running = false,
    phases = {
        { current = 0, max = 1*60 },
        { current = 0, max = 1*60, onlyRunIf = function ()
            return not Dialogue.playing.running
        end, completeFunction = function ()
            CurrentDepartment = "B"
            FilesCompleted = 0
            ConditionsCollected = 2
            Rating = 0

            UseSpinners = true
            UseScreens = true

            NewFile()
            ClearGoal = CalculateClearGoal()
            PlaceAnomalies()

            ShakeIntensity = 5

            LoadCards()

            LoadMusic()
            StartMusic(zutil.randomchoice(Music))
            SaveData()

            zutil.playsfx(SFX.departmentB, .5, 1)
        end },
    },
    currentPhase = 1,
}



function StartDepartmentTransition()
    DepartmentTransition.running = true
    DepartmentTransition.currentPhase = 1
    Dialogue.playing.textThusFar = ""
    Dialogue.playing.running = false

---@diagnostic disable-next-line: undefined-field
    MusicPlaying.audio:stop()
end
function UpdateDepartmentTransition()
    if not DepartmentTransition.running then return end

    local timer = DepartmentTransition.phases[DepartmentTransition.currentPhase]
    if (not timer.onlyRunIf) or timer.onlyRunIf() then
        zutil.updatetimer(timer, function()
            if timer.completeFunction then timer.completeFunction() end
            DepartmentTransition.currentPhase = DepartmentTransition.currentPhase + 1
        end , 1, GlobalDT)
    end

    if DepartmentTransition.currentPhase > #DepartmentTransition.phases then
        DepartmentTransition.running = false
    end
end

function DrawBG()
    if CurrentDepartment == "B" then
        local width = 30
        local maxDistance = 400
        local colorType = (Screen.running and "screenOutline" or "fileOutline")

        for y = 0, WINDOW.HEIGHT, width do
            for x = 0, WINDOW.WIDTH, width do
                local mx, my = love.mouse.getPosition()
                if Spinner.running then mx, my = WINDOW.CENTER_X, WINDOW.CENTER_Y end
                local distance = zutil.distance(mx, my, x + width/2, y + width/2)
                local ratio = zutil.relu(1 - distance/maxDistance)

                love.graphics.setColor(Colors[CurrentDepartment][colorType][1],Colors[CurrentDepartment][colorType][2],Colors[CurrentDepartment][colorType][3], ratio * .2 - math.random() / 100)
                love.graphics.rectangle("fill", x, y, width, width)
            end
        end
    end
end