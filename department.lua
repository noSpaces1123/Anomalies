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
        buttonFill = {1,1,1},
        titleColors = { {1,1,1} }
    },

    B = {
        bg = {3/255, 3/255, 3/355},
        bgParticles = {232/255, 238/255, 242/255},
        fileBg = {232/255, 238/255, 242/255},
        fileOutline = {232/255, 238/255, 242/255},
        text = {232/255, 238/255, 242/255},
        type3Square = {221/255, 45/255, 74/255},
        squares = {3/255, 3/255, 3/355},
        screenBg = {3/255, 3/255, 3/355},
        screenOutline = {221/255, 45/255, 74/255},
        screenDots = {232/255, 238/255, 242/255},
        screenGrid = {221/255/2, 45/255/2, 74/255/2},
        roadBg = {232/255, 238/255, 242/255},
        roadOutline = {3/255, 3/255, 3/355},
        roadPlayer = {221/255, 45/255, 74/255},
        buttonFill = {232/255, 238/255, 242/255},
        titleColors = { {232/255, 238/255, 242/255}, {221/255, 45/255, 74/255} }
    },

    X = {
        bg = {13/255, 21/255, 26/255},
        bgParticles = {167/255, 190/255, 211/255},
        fileBg = {167/255, 190/255, 211/255},
        fileOutline = {129/255, 173/255, 200/255},
        text = {129/255, 173/255, 200/255},
        type3Square = {104/255, 139/255, 88/255},
        squares = {13/255, 21/255, 26/255},
        screenBg = {13/255, 21/255, 26/255},
        screenOutline = {167/255, 190/255, 211/255},
        screenDots = {167/255, 190/255, 211/255},
        screenGrid = {13*1.2/255, 21*1.2/255, 26*1.2/255},
        roadBg = {13/255, 21/255, 26/255},
        roadOutline = {167/255, 190/255, 211/255},
        roadPlayer = {212/255, 213/255, 124/255},
        buttonFill = {167/255, 190/255, 211/255},
        barcodeOutline = {167/255, 190/255, 211/255},
        barcodeHoveringOutline = {129/255, 173/255, 200/255},
        titleColors = { {167/255, 190/255, 211/255}, {104/255, 139/255, 88/255}, {166/255, 52/255, 70/255} }
    },
}

DepartmentData = {
    A = {
        squarePalette = { ["0"] = 1, ["1"] = 1, ["2"] = 1 },
        shutterSpeed = 2,
        screenDotAlphaDecreaseSpeed = .02,
        pointerAcceleration = .04, windowDegreeWidth = 25,
        rnePercentChance = 17,
        rnes = { spinners = true, screens = true, roads = false, barcodes = false },
        findGridWidthAndHeight = function ()
            GridGlobalData.width = math.floor(FilesCompleted / 3) + 5
            GridGlobalData.height = GridGlobalData.width
        end,
    },

    B = {
        squarePalette = { ["0"] = 6, ["1"] = 1, ["2"] = 1, ["3"] = 1 },
        shutterSpeed = 4,
        screenDotAlphaDecreaseSpeed = .04,
        pointerAcceleration = .07, windowDegreeWidth = 25,
        rnePercentChance = 20,
        rnes = { spinners = true, screens = true, roads = true, barcodes = false },
        findGridWidthAndHeight = function ()
            local find = function ()
                return zutil.clamp(math.floor(FilesCompleted / 3) + 9 + math.random(-3, 4), 4, math.huge)
            end

            GridGlobalData.width = find()
            GridGlobalData.height = find()
        end,
    },

    X = {
        squarePalette = { ["0"] = 3, ["1"] = 5, ["2"] = 5, ["3"] = 1 },
        shutterSpeed = 5,
        screenDotAlphaDecreaseSpeed = .05,
        pointerAcceleration = .07, windowDegreeWidth = 18,
        trailSpawnInterval = 3*60,
        rnePercentChance = 26,
        rnes = { spinners = true, screens = false, roads = false, barcodes = true },
        findGridWidthAndHeight = function ()
            local find = function ()
                return zutil.clamp(math.floor(FilesCompleted / 3) + 12 + math.random(-2, 2), 4, math.huge)
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
            if CurrentDepartment == "A" then
                CurrentDepartment = "B"
            elseif CurrentDepartment == "B" then
                CurrentDepartment = "X"
            end

            FilesCompleted = 0
            ConditionsCollected = 1
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
    if MusicPlaying.audio then MusicPlaying.audio:stop() end
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
    if CurrentDepartment ~= "A" and not DepartmentTransition.running then
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