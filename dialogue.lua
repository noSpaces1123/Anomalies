Dialogue = {
    playing = {
        targetText = "",
        textThusFar = "",
        preliminaryWait = { current = 0, max = 1*60, done = false },
        charInterval = { current = 0, max = 4, defaultMax = 4, },
        running = false,
    },
    list = {
        greeting = {
            "Welcome back.",
            "Hello again.",
            "Didn't think I'd see you again.",
            "Let's get to work.",
            "It feels as if we saw each other just a second ago.",
            "Let's get to it.",
            "I hope your day's going well.",
            "Feeling good?",
            "Nice to see you again.",
        },
        completeFile = {
            "Nice job on that last one.",
            "You can do it faster.",
            "Great job.",
            "The boss will be happy.",
            "Don't get distracted.",
            "Excellent work.",
            "You can do better.",
            "Good job.",
            "Great work.",
            "Admirable work.",
            "You impress.",
            "It gets better every time.",
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
    }
}



function UpdateDialogue()
    if not Dialogue.playing.running then return end

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

        if add == "." or add == "," then
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax * 4
        else
            Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
        end

        zutil.playsfx(SFX.dialogue, .05, math.random()/2+.5)
    end, 1, GlobalDT)
end

function StartDialogue(type)
    Dialogue.playing.running = true
    Dialogue.playing.textThusFar = ""
    Dialogue.playing.charInterval.current = 0
    Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
    Dialogue.playing.preliminaryWait.current = 0
    Dialogue.playing.preliminaryWait.done = false

    Dialogue.playing.targetText = zutil.randomchoice(Dialogue.list[type])
end

function DrawDialogue()
    local x, y = GetGridAnchorCoords()
    y = y - Fonts.dialogue:getHeight() - 20

    love.graphics.setColor(0,0,0)
    love.graphics.setFont(Fonts.dialogue)
    love.graphics.print(Dialogue.playing.textThusFar, x, y)
end