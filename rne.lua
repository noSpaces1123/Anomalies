RNEPractice = {
    running = false,
    dotSine = { current = 0, max = 360, intensity = 50 },
    wait = { current = 0, max = 0, findMax = function ()
        return math.random(1,3)*60
    end, running = false },
}

RNEQueue = {
    doing = false,
    listMax = 10,
    theOnePlayingIsFrom = "",
}
RNEQueueAddInterval = { current = 0, max = 20*60 }
RNEQueueList = {}



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

    zutil.updatetimer(RNEPractice.dotSine, nil, 3, GlobalDT)
end
function DrawRNEPracticeWaitScreen()
    if not RNEPractice.wait.running then return end

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(Colors[CurrentDepartment].text)
    love.graphics.printf("BE READY", 0, WINDOW.CENTER_Y - Fonts.normal:getHeight()/2, WINDOW.WIDTH, "center")

    love.graphics.circle("fill", WINDOW.CENTER_X + math.sin(math.rad(RNEPractice.dotSine.current)) * RNEPractice.dotSine.intensity, WINDOW.CENTER_Y + Fonts.normal:getHeight()/2 + 20, 3, 200)
end

function UpdateRNEQueue()
    if CurrentDepartment ~= "B" then return end

    zutil.updatetimer(RNEQueueAddInterval, function ()
        if #RNEQueueList < RNEQueue.listMax then
            NewRNEQueueItem()
            zutil.playsfx(SFX.newRneInQueue, .3, 1)

            local self = Buttons[4]
            for _ = 1, 30 do
                table.insert(Particles, NewParticle(self.x+self.width/2, self.y+self.height/2, math.random()*3+2, {1,1,1}, math.random()*3+3, math.random(360), .04, math.random(300,600)))
            end

            RNEQueueAddInterval.max = math.random(12, 22) *60
        end
    end, 1, GlobalDT)
end
function NewRNEQueueItem()
    table.insert(RNEQueueList, zutil.randomchoice({"Wheel","Screen","Road"}))
end
function StartRNEFromQueue()
    if #RNEQueueList <= 0 then return end

    RNEPractice.running = true -- so i don't have to code another thing for the exact same purpose
    RNEQueue.doing = true
    _G["Start"..RNEQueueList[1]]()
    table.remove(RNEQueueList, 1)

    local names = {
        "james", "amelia", "charles", "charlotte", "emma", "joseph", "mia", "olivia", "henry", "sophia",
        "william", "freya", "ella", "evelyn", "noah", "oliver", "alexander", "finley", "malakai",
        "koa", "kai", "ayaan", "vihaan", "kenji", "jiahao", "rahul", "yeong-su", "shrivatsa", "alejandro",
        "mateo", "santiago", "daniel", "gabriel", "sebastian", "pedro", "manuel", "luna", "rafaela", "irene",
    }

    RNEQueue.theOnePlayingIsFrom = "rne from " .. zutil.randomchoice(names) .. " of department " .. zutil.weighted({A = 50, B = 5, X = 3, HQ = 1})
    RNEQueue.theOnePlayingIsFrom = string.upper(RNEQueue.theOnePlayingIsFrom)
end
function DrawRNEQueueSourcePerson()
    if RNEQueue.doing then
        love.graphics.setFont(Fonts.normal)
        love.graphics.setColor(Colors[CurrentDepartment].text)
        love.graphics.printf(RNEQueue.theOnePlayingIsFrom, 0, WINDOW.HEIGHT - 100, WINDOW.WIDTH, "center")
    end
end

function PerhapsPlayVoicedAffirmationSFX()
    if zutil.weightedbool(70) then return end

    local options = {
        "nice", "goodJob", "greatJob", "perfect",
    }

    zutil.playsfx(SFX[zutil.randomchoice(options)], .1, 1)
end