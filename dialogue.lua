Dialogue = {
    playing = {
        targetText = "",
        textThusFar = "",
        preliminaryWait = { current = 0, max = 1*60, done = false },
        charInterval = { current = 0, max = 3.5, defaultMax = 3.5, maxMax = 5.5, minMax = 0.5 },
        color = {0,0,0},
        running = false,
    },
    peopleColors = {
        ["foster"] = Colors[CurrentDepartment].text,
        ["michael"] = {0,.4,.8},
        ["noir"] = {221/255, 45/255, 74/255},
    },
    list = {
        firstEverGreeting = {
            "Welcome to Moriel Incorporated.",
        },
        greeting = {
            "Welcome back.",
            "Hello again.",
            "Hello. I wasn't sure if I'd see you again.",
            "Hello. Let's get to work.",
            "Hello. It feels as if we saw each other just a second ago.",
            "Hello. Let's get to it.",
            "I hope your day's going well.",
            "Hello. Feeling good?",
            "Nice to see you again.",
        },
        completeFile = {
            "Nice job on that last one.",
            "That's the spirit.",
            "Great job.",
            "The boss will be happy.",
            "This is better than coffee.",
            "Excellent work.",
            "Nice job.",
            "Good job.",
            "Great work.",
            "Admirable work.",
            "You impress.",
            "It gets better every time.",
            "Go get 'em, tiger.",
        },
        wrong = {
            "Owch. Try again.",
            "Being wrong is part of growing.",
            "Don't stress it.",
            "Give it another go.",
            "Try again.",
            "It's alright. It's just squares.",
            "No worries. Try again.",
            "Bouncing back is a unique feature of the human spirit.",
            "Resilience is a virtue.",
            "We're all wrong sometimes.",
            "Everyone you know will have made a mistake there too.",
            "It's okay. Don't worry.",
            "The standards we hold ourselves to are ones we may define ourselves.",
            "Losing is learning. Every bump in the road is growth.",
            "Your mistakes are by no means a reflection of your intelligence. Stay resilient.",
            "Losing is learning. There's nothing wrong with being wrong.",
            "It's okay. Try again. You may try again as many times as you like.",
            "Don't stress. They're just squares.",
            "I hope that didn't scare you.",
        },
        enterOptionsMenu = {
            "Ah, the options menu. I hope you find what you're looking for.",
            "Configure to your heart's desire.",
            "You have the power to change whatever you like. Have fun.",
            "Music too loud?",
        },
        changeDialogueSpeed = {
            "Hello. This is a sentence. Here is a second sentence, a sentence with a comma."
        },
        gain_sticker_50 = {
            "Good job for reaching a rating of 50. Here's a sticker for your hard work.",
            "Nice job getting to rating 50. Here's a sticker.",
            "You got a rating of 50. Nice. Have a sticker, only for the hard workers like you.",
        },
        gain_sticker_100 = {
            "Impressive. Rating of 100. Here you go.",
            "A rating of 100 deserves a sticker. Good job.",
            "Good work. You deserve a sticker. Take one.",
        },
        gain_sticker_200 = {
            "Wow, a rating of 200. Most only the hardest workers achieve such a sticker.",
            "Congratulations on a rating of 200. You don't see that every day.",
            "A rating of 200, huh? Great job. I knew you could do it.",
        },
        gain_filescompleted_10 = {
            "10 files completed. Well done.",
            "That's 10 files down. Proud of you.",
            "10 files done. Great job. Take a sticker.",
        },
        gain_filescompleted_20 = {
            "20 files completed. For you, take a sticker.",
            "20 files in the bag. The boss will be happy.",
            "20 files searched and filtrated. Great job. Have a sticker.",
        },
        gain_filescompleted_40 = {
            "40 files completed. For you, take a sticker.",
            "40 files done. Great job.",
            "40 files all done. I'm proud.",
        },
        gain_filescompleted_70 = {
            "I see you're really starting to settle in. 70 files done.",
            "70 files done. Fantastic work.",
            "70 files done. Such effort I admire.",
        },
        gain_filescompleted_100 = {
            "Wow, 100 files. Most workers don't complete 100 files in the time you did.",
            "Excellent speed. 100 files done.",
            "Great effort. You got to 100 files all done.",
        },
    },
    eventual = {
        {
            text = "My name is Jamie Foster. I'm sort of your boss. I'll be supervising you. Check your handbook for how to do your job.",
            when = function ()
                return CurrentDepartment == "A" and FilesCompleted == 0
            end
        },
        {
            text = "Rating is a thing. See in the top-right? It changes with how well you work. Don't worry, it doesn't go below 0.",
            when = function ()
                return CurrentDepartment == "A" and FilesCompleted == 3
            end
        },
        {
            text = "Check your cards. You've gained a new way to identify an anomaly.",
            when = function ()
                local cond = CurrentDepartment == "A" and FilesCompleted == 4
                if cond then ConditionsCollected = 3 end
                return cond
            end
        },
        {
            text = "Hey there, my name's Michael. Weird job, right? ... It gets kinda fun.", person = "michael",
            when = function ()
                return CurrentDepartment == "A" and FilesCompleted == 5
            end
        },
        {
            text = "Check your cards. You've got another new way to find anomalies.",
            when = function ()
                local cond = CurrentDepartment == "A" and FilesCompleted == 6
                if cond then ConditionsCollected = 4 end
                return cond
            end
        },
        {
            text = "Y'know, if you get a high enough rating, I'll give you a little reward.",
            when = function ()
                local collected = false
                for _, value in pairs(RewardsCollected) do
                    if value then collected = true break end
                end
                return CurrentDepartment == "A" and FilesCompleted == 7 and not collected
            end
        },
        {
            text = "Annoyed by those diagonal black squares strewn around? You've got a card to fix half of them.",
            when = function ()
                local cond = FilesCompleted == 9
                if cond then ConditionsCollected = 5 end
                return CurrentDepartment == "A" and cond
            end
        },
        {
            text = "Mr Foster's a bit of a weird guy. He doesn't have any photos of his family on his desk- or any personal belongings for that matter.", person = "michael",
            when = function ()
                return CurrentDepartment == "A" and FilesCompleted == 11
            end
        },
        {
            text = "Don't believe everything Mr Foster has to say. Moriel Incorporated is known amongst us for hiding information...", person = "michael",
            when = function ()
                return CurrentDepartment == "A" and FilesCompleted == 12
            end
        },
        {
            text = "You've gained a new kind of card. Check your cards. The red cards describe squares of which are NEVER anomalies.",
            when = function ()
                local cond = CurrentDepartment == "A" and FilesCompleted == 15
                if cond then ConditionsCollected = 6 end
                return cond
            end
        },
        {
            text = "From here on out, you have a chance to get a spinner when eradicating an anomaly. Read about it in the handbook.",
            when = function ()
                local cond = CurrentDepartment == "A" and FilesCompleted == 19
                if cond then UseSpinners = true end
                return cond
            end
        },
        {
            text = "Here is your practice spinner. The line has been slowed significantly. Take your time.",
            when = function ()
                return CurrentDepartment == "A" and UseSpinners and not WonSpinner and Spinner.running
            end
        },
        {
            text = "From here on out, you have a chance to get a memory screen when removing an anomaly. Read about it in the handbook, it's quite simple.",
            when = function ()
                local cond = CurrentDepartment == "A" and FilesCompleted == 24
                if cond then UseScreens = true end
                return cond
            end
        },

        {
            text = "Wake up.", person = "noir",
            when = function ()
                return CurrentDepartment == "A" and DepartmentTransition.running and DepartmentTransition.currentPhase == 2
            end
        },

        {
            text = "Welcome to Cleansing Department B. Look at your cards, they're not the same as in Department A.", person = "noir",
            when = function ()
                return CurrentDepartment == "B" and FilesCompleted == 0
            end
        },
        {
            text = "I'm sure you have a lot of questions. There's not time. You may not slack off and relax here as you did in Department A.", person = "noir",
            when = function ()
                return CurrentDepartment == "B" and FilesCompleted == 1
            end
        },
        {
            text = "Since time is more precious here, your spinners and memory screens will move faster. Stay focused.", person = "noir",
            when = function ()
                return CurrentDepartment == "B" and FilesCompleted == 2
            end
        },
        {
            text = "Here's a new card.", person = "noir",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 3
                if cond then ConditionsCollected = 3 end
                return cond
            end
        },
        {
            text = "Good work.", person = "noir",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 6
                if cond then ConditionsCollected = 4 end
                return cond
            end
        },
        {
            text = "New card. Check.", person = "noir",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 9
                if cond then ConditionsCollected = 5 end
                return cond
            end
        },
        {
            text = "You have a new RNE to worry about. Read about roads in the handbook.", person = "noir",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 10
                if cond then UseRoads = true end
                return cond
            end
        },
        {
            text = "Hey! I just moved to Department B. Mr Noir asked me to give this new card to you.", person = "michael",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 12
                if cond then ConditionsCollected = 6 end
                return cond
            end
        },
        {
            text = "Here's your last card.", person = "noir",
            when = function ()
                local cond = CurrentDepartment == "B" and FilesCompleted == 20
                if cond then ConditionsCollected = 7 end
                return cond
            end
        },
    },
}



function UpdateDialogue()
    if not Dialogue.playing.running or RNEPractice.running then return end

    if not Dialogue.playing.preliminaryWait.done then
        zutil.updatetimer(Dialogue.playing.preliminaryWait, function ()
            Dialogue.playing.preliminaryWait.done = true
        end, 1, GlobalDT)

        return
    end

    zutil.updatetimer(Dialogue.playing.charInterval, function ()
        if Dialogue.playing.textThusFar == Dialogue.playing.targetText then
            Dialogue.playing.running = false
            return
        end

        local i = #Dialogue.playing.textThusFar + 1
        local add = string.sub(Dialogue.playing.targetText, i, i)
        Dialogue.playing.textThusFar = Dialogue.playing.textThusFar .. add

        if #Dialogue.playing.textThusFar >= 3 and add == "." and string.sub(Dialogue.playing.textThusFar, #Dialogue.playing.textThusFar-1, #Dialogue.playing.textThusFar-1) == "." and string.sub(Dialogue.playing.textThusFar, #Dialogue.playing.textThusFar-2, #Dialogue.playing.textThusFar-2) == "." then
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax * 14
        elseif add == "." or add == "," or add == "!" or add == "?" or add == ";" then
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax * 6
        elseif add == "-" and i < #Dialogue.playing.targetText and string.sub(Dialogue.playing.targetText, i+1, i+1) == " " then
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax * 8
        else
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
        end

        zutil.playsfx(SFX[Dialogue.playing.person], .05, math.random()/2+.5)
    end, 1, GlobalDT)
end

function StartDialogue(type, category_OR_eventualIndex)
    if type == "list" and CurrentDepartment ~= "A" then return end

    Dialogue.playing.running = true
    Dialogue.playing.textThusFar = ""
    Dialogue.playing.charInterval.current = 0
    Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
    Dialogue.playing.preliminaryWait.current = 0
    Dialogue.playing.preliminaryWait.done = false

    Animations.greeting.running = false

    if type == "list" then
        Dialogue.playing.targetText = zutil.randomchoice(Dialogue.list[category_OR_eventualIndex])
        Dialogue.playing.person = "foster"

        if category_OR_eventualIndex == "greeting" or category_OR_eventualIndex == "firstEverGreeting" then
            Animations.greeting.running = true
        end
    elseif type == "eventual" then
        Dialogue.playing.targetText = Dialogue.eventual[category_OR_eventualIndex].text
        Dialogue.playing.person = (Dialogue.eventual[category_OR_eventualIndex].person and Dialogue.eventual[category_OR_eventualIndex].person or "foster")
    end

    Dialogue.playing.color = Dialogue.peopleColors[Dialogue.playing.person]
end

function DrawDialogue()
    if RNEPractice.wait.running then return end

    local y = GetDialogueY()

    local limit = 1000
    local spacing = (WINDOW.WIDTH - limit) / 2
    local _, wrappedText = Fonts.dialogue:getWrap(Dialogue.playing.textThusFar, limit)
    love.graphics.setColor(Dialogue.playing.color)
    love.graphics.setFont(Fonts.dialogue)
    love.graphics.printf(Dialogue.playing.textThusFar, spacing, y - (#wrappedText - 1) * Fonts.dialogue:getHeight(), limit, "center")

    DrawGreetingAnimation()
end
function GetDialogueY()
    local _, y = GetGridAnchorCoords()
    if DepartmentTransition.running then y = WINDOW.CENTER_Y
    elseif GameState == "menu" then y = 540
    elseif GameState == "options" then y = WINDOW.HEIGHT
    elseif Spinner.running then y = WINDOW.CENTER_Y - Spinner.radius
    elseif Screen.running then y = Screen.y
    elseif Road.running then y = Road.y end

    return y - Fonts.dialogue:getHeight() - 20
end

function SearchForDueEventualDialogue()
    local triggered = false
    for index, dialogue in ipairs(Dialogue.eventual) do
        local condscollectedbefore = ConditionsCollected

        if not dialogue.triggered and dialogue.when() then
            StartDialogue("eventual", index)
            dialogue.triggered = true
            triggered = true
        end

        if ConditionsCollected > condscollectedbefore then
            NewCardIndicator.on = true
        end
    end
    if triggered then SaveData() end
end