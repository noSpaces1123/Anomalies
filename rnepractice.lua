RNEPractice = {
    running = false,
    wait = { current = 0, max = 0, findMax = function ()
        return math.random(1,3)*60
    end, running = false },
}



function StartRNEPractice()
    RNEPractice.wait.running = true
    RNEPractice.wait.max = RNEPractice.wait.findMax()
    RNEPractice.running = true
end

function UpdateRNEPracticeWait()
    if not RNEPractice.wait.running then return end

    zutil.updatetimer(RNEPractice.wait, function ()
        RNEPractice.wait.running = false
        StartWheel()
    end, 1, GlobalDT)
end

function DrawRNEPracticeWaitScreen()
    if not RNEPractice.wait.running then return end

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("BE READY", 0, WINDOW.CENTER_Y - Fonts.normal:getHeight()/2, WINDOW.WIDTH, "center")
end