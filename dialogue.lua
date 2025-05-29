function InitialiseDialogue()
    Dialogue = {
        playing = {
            targetText = "",
            textThusFar = "",
            preliminaryWait = { current = 0, max = 1*60, done = false },
            charInterval = { current = 0, max = 3.5, defaultMax = 3.5, maxMax = 5.5, minMax = 0.5 },
            color = {0,0,0},
            running = false,
            limit = 1000,
        },
        peopleColors = {
            ["foster"] = Colors[CurrentDepartment].text,
            ["michael"] = {0,.4,.8},
            ["noir"] = {221/255, 45/255, 74/255},
            ["atrium"] = {0, 201/255, 128/255},
            ["yoke"] = {211/255, 213/255, 124/255},
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
            notFocusedOnWindow = {
                "Do you have something better to do? Let's get back to work.",
                "What is so important?",
                "Come on, let's get back to work.",
                "If you don't want to work then just leave.",
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
            gain_filescompleted_30 = {
                "30 files completed. For you, take a sticker.",
                "30 files done. Great job.",
                "30 files all done. I'm proud.",
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
                    local cond = CurrentDepartment == "A" and FilesCompleted == 9
                    if cond then ConditionsCollected = 5 end
                    return cond
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
                text = "Cleansing Department B is your next step. I hope your time here in Department A has been fun.",
                when = function ()
                    local cond = CurrentDepartment == "A" and FilesCompleted == 27
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
                text = "Welcome to Cleansing Department B. I'm Mr Noir. Look at your cards, they're not the same as in Department A.", person = "noir", animation = "greeting",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 0
                    if cond then ConditionsCollected = 2 end
                    return cond
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
                text = "Something new: RNE Queues. Remember how, when you were in Department A, your RNEs were sent to other employees while you were learning? It's time for you to receive and complete RNEs from other learning employees now. Work on your RNE Queue with the button in the bottom right.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 9
                    if cond then UnlockedRNEQueue = true ; SaveData() end
                    return cond
                end
            },
            {
                text = "New card. Check.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 10
                    if cond then ConditionsCollected = 5 end
                    return cond
                end
            },
            {
                text = "Hi, I'm Atrium. I- I hear you're new here in Department B! It's been a long 20 years here... I look forward to- to getting to know you.", person = "atrium",
                when = function ()
                    return CurrentDepartment == "B" and FilesCompleted == 13
                end
            },
            {
                text = "You have a new RNE to worry about. Read about roads in the handbook.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 15
                    if cond then UseRoads = true end
                    return cond
                end
            },
            {
                text = "Hey! Remember me? I just moved to Department B. Mr Noir asked me to give this new card to you.", person = "michael",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 17
                    if cond then ConditionsCollected = 6 end
                    return cond
                end
            },
            {
                text = "Here's your last card.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "B" and FilesCompleted == 21
                    if cond then ConditionsCollected = 7 end
                    return cond
                end
            },

            {
                text = "...", person = "yoke",
                when = function ()
                    return CurrentDepartment == "B" and DepartmentTransition.running and DepartmentTransition.currentPhase == 2
                end
            },

            {
                text = "I'm Ms Yoke. I can't talk now. See you later.", person = "yoke",
                when = function ()
                    local cond = CurrentDepartment == "X" and FilesCompleted == 0
                    if cond then ConditionsCollected = 3 end
                    return cond
                end
            },
            {
                text = "It's me, Atrium! I just got moved here as well, as part of the migration... How are you settling in? This place is weird...", person = "atrium", animation = "greeting",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 3
                end
            },
            {
                text = "Ms Yoke told me to bring this card to you...", person = "atrium",
                when = function ()
                    local cond = CurrentDepartment == "X" and FilesCompleted == 4
                    if cond then ConditionsCollected = 4 end
                    return cond
                end
            },
            {
                text = "Hey. Here's your last card. Enjoy. By the way, there are barcode RNEs now. You'll figure it out, I'm sure.", person = "yoke",
                when = function ()
                    local cond = CurrentDepartment == "X" and FilesCompleted == 9
                    if cond then ConditionsCollected = 5 ; UseBarcodes = true end
                    return cond
                end
            },
            {
                text = "It's quite clear that, in this department, the anomalies are much harder to find... because they're so specific.", person = "atrium",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 12
                end
            },
            {
                text = "Do you ever wonder what we're actually doing this for? W- what data are we cleansing?", person = "atrium",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 13
                end
            },
            {
                text = "T- try these. They're called N-Meds. I got them from one of the other employees here. They told me the N-Meds will... help you be more content with the work.", person = "atrium",
                when = function ()
                    local cond = CurrentDepartment == "X" and FilesCompleted == 16
                    if cond then GainNMeds() end
                    return cond
                end
            },
            {
                text = "A- are you okay?", person = "atrium",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 16 and NMeds.effectDuration.running
                end
            },
            {
                text = "I've noticed that we tend to get moved to another department upon completing our 31st file...", person = "atrium",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 20
                end
            },
            {
                text = "S- see you on the other side, pal.", person = "atrium",
                when = function ()
                    return CurrentDepartment == "X" and FilesCompleted == 30 and ClearGoal <= 3
                end
            },

            {
                text = "Hello. I'm Mr Noir. Here are a couple cards to start with.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "C" and FilesCompleted == 0
                    if cond then ConditionsCollected = 2 end
                    return cond
                end
            },
            {
                text = "Because of a new policy, you don't have permission to speak to any of the other workers here because of the nature of your work. I trust you will obey.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "C" and FilesCompleted == 6
                    if cond then ConditionsCollected = 3 end
                    return cond
                end
            },
            {
                text = "If any of your colleagues comes and tries to give you blue-ish cyan pills, refuse them, for your own good.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "C" and FilesCompleted == 10
                    if cond then ConditionsCollected = 4 end
                    return cond
                end
            },
            {
                text = "Those blue-ish pills are called N-Meds. We've had a bit of a problem with them being smuggled out of ############.", person = "noir",
                when = function ()
                    return CurrentDepartment == "C" and FilesCompleted == 11
                end
            },
            {
                text = "N-Meds cause... hallucinations. Don't take them if you're given them.", person = "noir",
                when = function ()
                    return CurrentDepartment == "C" and FilesCompleted == 12
                end
            },
            {
                text = "Your last card.", person = "noir",
                when = function ()
                    local cond = CurrentDepartment == "C" and FilesCompleted == 18
                    if cond then ConditionsCollected = 5 end
                    return cond
                end
            },
        },
    }
end

InitialiseDialogue()



function UpdateDialogue()
    if not Dialogue.playing.running or RNEPractice.running or GridGlobalData.generationAnimation.running or Spinner.running or Road.running or Screen.running then return end

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

        if add ~= "#" then
            zutil.playsfx(SFX[Dialogue.playing.person], (Dialogue.playing.person == "yoke" and .15 or .05), math.random()/2+.5)
        end
    end, 1, GlobalDT)
end

function StartDialogue(type, category_OR_eventualIndex, animation)
    if type == "list" and CurrentDepartment ~= "A" then return end
    if type == "list" and (category_OR_eventualIndex == "completeFile" or category_OR_eventualIndex == "wrong") and (Dialogue.playing.running or zutil.weightedbool(60)) then return end

    Dialogue.playing.running = true
    Dialogue.playing.textThusFar = ""
    Dialogue.playing.charInterval.current = 0
    Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
    Dialogue.playing.preliminaryWait.current = 0
    Dialogue.playing.preliminaryWait.done = false

    if animation then
        Animations[animation].running = true
    else
        for _, value in pairs(Animations) do
            value.running = false
        end
    end

    if type == "list" then
        Dialogue.playing.targetText = zutil.randomchoice(Dialogue.list[category_OR_eventualIndex])
        Dialogue.playing.person = "foster"
    elseif type == "eventual" then
        Dialogue.playing.targetText = Dialogue.eventual[category_OR_eventualIndex].text
        Dialogue.playing.person = (Dialogue.eventual[category_OR_eventualIndex].person and Dialogue.eventual[category_OR_eventualIndex].person or "foster")
    end

    Dialogue.playing.color = Dialogue.peopleColors[Dialogue.playing.person]
end

function DrawDialogue()
    if RNEPractice.wait.running or GridGlobalData.generationAnimation.running or Spinner.running or Road.running or Screen.running then return end

    local y = GetDialogueY()

    local spacing = (WINDOW.WIDTH - Dialogue.playing.limit) / 2
    local _, wrappedText = Fonts.dialogue:getWrap(Dialogue.playing.textThusFar, Dialogue.playing.limit)
    love.graphics.setColor(Dialogue.playing.color)
    love.graphics.setFont(Fonts.dialogue)
    love.graphics.printf(Dialogue.playing.textThusFar, spacing, y - (#wrappedText - 1) * Fonts.dialogue:getHeight(), Dialogue.playing.limit, "center")

    local animationToDraw
    for key, value in pairs(Animations) do
        if value.running then
            animationToDraw = key
            break
        end
    end

    if animationToDraw then
        DrawAnimation(animationToDraw)
    end
end
function GetDialogueY()
    local _, y = GetGridAnchorCoords()
    if DepartmentTransition.running then y = WINDOW.CENTER_Y
    elseif GameState == "menu" then y = 540
    elseif GameState == "options" then y = WINDOW.HEIGHT end

    return y - Fonts.dialogue:getHeight() - 20
end

function SearchForDueEventualDialogue()
    local condscollectedbefore = ConditionsCollected
    local triggered = false
    for index, dialogue in ipairs(Dialogue.eventual) do
        if not dialogue.triggered and dialogue.when() then
            StartDialogue("eventual", index, dialogue.animation)
            dialogue.triggered = true
            triggered = true
        end
    end
    if triggered then SaveData() end

    if ConditionsCollected > condscollectedbefore then
        NewCardIndicator.on = true
        Animations.newCard.running = true
    end
end