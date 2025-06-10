Barcode = {
    running = false,
    conditionsMetWhenStarted = 0,

    patterns = {}, numberOfPatterns = 5, patternLength = 80,
    targetPattern = "",

    patternWidth = 400, patternHeight = 30, patternSpacing = 30,

    conclusionDelay = { current = 0, max = 0, running = false },
    conclusion = nil,
}
Barcode.xAnchor = WINDOW.CENTER_X - Barcode.patternWidth / 2



function StartBarcode(conditionsMetWhenStarted)
    Barcode.running = true
    Barcode.conditionsMetWhenStarted = conditionsMetWhenStarted

    zutil.playsfx(SFX["barcodePrint" .. math.random(1,3)], .7, math.random()/10+.95)

    -- generate target pattern
    Barcode.targetPattern = ""
    for _ = 1, Barcode.patternLength do
        Barcode.targetPattern = Barcode.targetPattern .. zutil.randomchoice({"0","1"})
    end

    local immunePatternIndex = math.random(Barcode.numberOfPatterns)

    -- generate patterns
    for i = 1, Barcode.numberOfPatterns do
        if i == immunePatternIndex then
            Barcode.patterns[i] = Barcode.targetPattern
        else
            for _ = 1, math.random(1,3) do
                local changeCharIndex = math.random(2, Barcode.patternLength - 1)
                local changeCharCurrentState = string.sub(Barcode.targetPattern, changeCharIndex, changeCharIndex)
                Barcode.patterns[i] = string.sub(Barcode.targetPattern, 1, changeCharIndex - 1) .. (changeCharCurrentState == "1" and "0" or "1") .. string.sub(Barcode.targetPattern, changeCharIndex + 1, #Barcode.targetPattern)
            end
        end
    end
end

function DrawBarcode()
    if not Barcode.running then return end

    local bitWidth = Barcode.patternWidth / Barcode.patternLength

    local drawBarcode = function (pattern, xAnch, yAnch, inChoices)
        local mouseHoveringOver = inChoices and zutil.touching(xAnch, yAnch, Barcode.patternWidth, Barcode.patternHeight, love.mouse.getX(), love.mouse.getY(), 0, 0)

        love.graphics.setLineWidth((mouseHoveringOver and 17 or 5))
        love.graphics.setColor((mouseHoveringOver and Colors[CurrentDepartment].barcodeHoveringOutline or Colors[CurrentDepartment].barcodeOutline))
        love.graphics.rectangle("line", xAnch, yAnch, Barcode.patternWidth, Barcode.patternHeight)

        for j = 1, #pattern do
            love.graphics.setColor((string.sub(pattern, j, j) == "1" and {0,0,0} or {1,1,1}))
            love.graphics.rectangle("fill", xAnch + (j - 1) * bitWidth, yAnch, bitWidth, Barcode.patternHeight)
        end
    end

    -- patterns
    for i = 1, Barcode.numberOfPatterns do
        drawBarcode(Barcode.patterns[i], Barcode.xAnchor, GetBarcodeY(i), true)
    end

    -- target pattern
    drawBarcode(Barcode.targetPattern, Barcode.xAnchor, 300)

    -- text
    love.graphics.setColor(Colors[CurrentDepartment].barcodeOutline)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf((Barcode.conclusionDelay.running and "JUST A MOMENT..." or "WHICH BARCODE BELOW MATCHES THE BARCODE ABOVE?"), 0, 300 + Barcode.patternHeight + 50, WINDOW.WIDTH, "center")
end
function GetBarcodeY(i)
    return WINDOW.CENTER_Y - (i - 1.5) * (Barcode.patternHeight + Barcode.patternSpacing) + 200
end

function CheckClickOnBarcode(mx, my)
    if not Barcode.running or Barcode.conclusionDelay.running then return end

    for i = 1, Barcode.numberOfPatterns do
        if zutil.touching(Barcode.xAnchor, GetBarcodeY(i), Barcode.patternWidth, Barcode.patternHeight, mx, my, 0, 0) then
            Barcode.conclusion = (Barcode.patterns[i] == Barcode.targetPattern and "correct" or "incorrect")

            Barcode.conclusionDelay.running = true
            Barcode.conclusionDelay.max = math.random(16,46)/10*60

            zutil.playsfx(SFX.barcodeScan, .5, 1)
            zutil.playsfx(SFX["barcodeProcessing" .. math.random(1,3)], .8, math.random()/10+.95)

            if zutil.weightedbool(24) then
---@diagnostic disable-next-line: undefined-field
                MusicPlaying.audio:pause()
            end

            break
        end
    end
end
function UpdateBarcodeConclusionDelay()
    if not Barcode.conclusionDelay.running then return end

    zutil.updatetimer(Barcode.conclusionDelay, function ()
        Barcode.conclusionDelay.running = false
    end, 1, GlobalDT)

    if Barcode.conclusionDelay.running then return end

    if Barcode.conclusion == "correct" then
        zutil.playsfx(SFX.rneComplete, .4, 1)
        PopSquare(SquareSelected.x, SquareSelected.y, Barcode.conditionsMetWhenStarted)
    elseif Barcode.conclusion == "incorrect" then
        Wrong()
    else
        error("barcode RNE had invalid conclusion? how?")
    end

---@diagnostic disable-next-line: undefined-field
    if MusicPlaying.audio then MusicPlaying.audio:play() end

    Barcode.running = false
end