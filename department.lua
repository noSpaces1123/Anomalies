CurrentDepartment = "A"

Colors = {
    A = {
        bg = {255,255,255},
        bgParticles = {0,0,0},
        fileBg = {255,255,255},
        fileOutline = {0,0,0},
        text = {0,0,0},
        type3Square = {0,255,255},
        squares = {0,0,0},
        screenBg = {255,255,255},
        screenOutline = {0,0,0},
        screenDots = {0,0,0},
        screenGrid = {255*.95,255*.95,255*.95},
        buttonFill = {255,255,255},
        titleColors = { {255,255,255} }
    },

    B = {
        bg = {3, 3, 3},
        bgParticles = {232, 238, 242},
        fileBg = {232, 238, 242},
        fileOutline = {232, 238, 242},
        text = {232, 238, 242},
        type3Square = {221, 45, 74},
        squares = {3, 3, 3},
        screenBg = {3, 3, 3},
        screenOutline = {221, 45, 74},
        screenDots = {232, 238, 242},
        screenGrid = {221/2, 45/2, 74/2},
        roadBg = {232, 238, 242},
        roadOutline = {3, 3, 3},
        roadPlayer = {221, 45, 74},
        buttonFill = {232, 238, 242},
        titleColors = { {232, 238, 242}, {221, 45, 74} }
    },

    X = {
        bg = {13, 21, 26},
        bgParticles = {167, 190, 211},
        fileBg = {167, 190, 211},
        fileOutline = {129, 173, 200},
        text = {129, 173, 200},
        type3Square = {104, 139, 88},
        squares = {13, 21, 26},
        screenBg = {13, 21, 26},
        screenOutline = {167, 190, 211},
        screenDots = {167, 190, 211},
        screenGrid = {13*1.2, 21*1.2, 26*1.2},
        roadBg = {13, 21, 26},
        roadOutline = {167, 190, 211},
        roadPlayer = {212, 213, 124},
        buttonFill = {167, 190, 211},
        barcodeOutline = {167, 190, 211},
        barcodeHoveringOutline = {129, 173, 200},
        titleColors = { {167, 190, 211}, {104, 139, 88}, {166, 52, 70} }
    },

    C = {
        bg = {43, 42, 38},
        bgParticles = {165, 158, 140},
        fileBg = {226, 226, 223},
        fileOutline = {76, 87, 96},
        text = {215, 206, 178},
        type3Square = {215, 206, 178},
        squares = {43, 42, 38},
        screenBg = {226, 226, 223},
        screenOutline = {76, 87, 96},
        screenDots = {43, 42, 38},
        screenGrid = {226*1.2, 226*1.2, 223*1.2},
        roadBg = {165, 158, 140},
        roadOutline = {215, 206, 178},
        roadPlayer = {226, 226, 223},
        buttonFill = {165, 158, 140},
        barcodeOutline = {165, 158, 140},
        barcodeHoveringOutline = {215, 206, 178},
        titleColors = { {215, 206, 178}, {226, 226, 223} },
    },
}

-- converts all RGB 0-255 values into RGB 0-1
for dept, list in pairs(Colors) do
    for key, value in pairs(list) do
        if key == "titleColors" then
            for i, color in ipairs(value) do
                for j, component in ipairs(color) do
                    Colors[dept][key][i][j] = component / 255
                end
            end
        else
            for i, component in ipairs(value) do
                Colors[dept][key][i] = component / 255
            end
        end
    end
end

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
        roadObstacleSpeed = 10,
        pointerAcceleration = .055, windowDegreeWidth = 18,
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

    C = {
        squarePalette = { ["0"] = 3, ["1"] = 5, ["2"] = 2, ["3"] = 1 },
        shutterSpeed = 3,
        roadObstacleSpeed = 10,
        screenDotAlphaDecreaseSpeed = .05,
        trailSpawnInterval = 6*60,
        rnePercentChance = 30,
        rnes = { spinners = false, screens = true, roads = true, barcodes = false },
        findGridWidthAndHeight = function ()
            local find = function ()
                return zutil.clamp(math.floor(FilesCompleted / 3) + 7 + math.random(-1, 3), 4, math.huge)
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
            if #DepartmentTree[CurrentDepartment] == 1 then
                LoadNewDepartment(DepartmentTree[CurrentDepartment][1])
            end
        end },
    },
    currentPhase = 1,
    afterDepartmentChoiceWait = { current = 0, max = 2*60, running = false, completeFunction = function ()
        LoadNewDepartment(DepartmentTransition.departmentChoice)
        DepartmentTransition.afterDepartmentChoiceWait.running = false
    end },
    departmentChoice = "",
}

DepartmentTree = {
    A = { "B" },
    B = { "C", "X" },
    C = { "D", "H" },
    D = { "L", "M" },
    H = { "K", "R", "M" },
    F = { "R", "N" },
    X = { "F", "W" },
    W = { "Z", "Y" },
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
    if DepartmentTransition.afterDepartmentChoiceWait.running then

        zutil.updatetimer(DepartmentTransition.afterDepartmentChoiceWait, DepartmentTransition.afterDepartmentChoiceWait.completeFunction, 1, GlobalDT)

    elseif DepartmentTransition.running and DepartmentTransition.currentPhase <= #DepartmentTransition.phases then

        local timer = DepartmentTransition.phases[DepartmentTransition.currentPhase]
        if (not timer.onlyRunIf) or timer.onlyRunIf() then
            zutil.updatetimer(timer, function()
                if timer.completeFunction then timer.completeFunction() end
                DepartmentTransition.currentPhase = DepartmentTransition.currentPhase + 1
            end , 1, GlobalDT)
        end

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

function LoadNewDepartment(dept)
    CurrentDepartment = dept

    DepartmentTransition.running = false

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
end