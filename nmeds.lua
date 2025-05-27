---@diagnostic disable: undefined-field

NMeds = {
    sprite = love.graphics.newImage("assets/sprites/n-meds.png", {dpiscale=4}),
    x = 200, y = WINDOW.CENTER_Y + 160,
    effectDelay = { current = 0, max = 3*60, running = false },
    effectDuration = { current = 0, max = 25*60, running = false },
    heartbeatTimer = { current = 0, max = 1.5*60 },
    overlayIntensity = { current = 0, max = 1, running = false },
}
HasNMeds = false



function GainNMeds()
    HasNMeds = true
    zutil.playsfx(SFX.gainNMeds, .3, 1)
    MusicPlaying.audio:stop()
    SaveData()
end
function TakeNMeds()
    assert(HasNMeds, "you don't have n-meds. what the hell did you do mr man? if you're not affiliated with frazy (the developer of Anomalies) in any way, please email him regarding this error. the game should be fine if you just restart it. :3")

    NMeds.effectDelay.running = true
    NMeds.effectDelay.current = 0
    HasNMeds = false

    zutil.playsfx(SFX.gulp, .05, 1)
end

function DrawNMeds()
    if not HasNMeds or Spinner.running or Screen.running or Road.running or Barcode.running then return end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(NMeds.sprite, NMeds.x, NMeds.y)

    local amp = 5
    for _ = 1, 2 do
        love.graphics.setColor(1,1,1, math.random()/2.5+.2)
        love.graphics.draw(NMeds.sprite, NMeds.x + zutil.jitter(amp), NMeds.y + zutil.jitter(amp))
    end
end

function UpdateNMedsEffectDelay()
    if not NMeds.effectDelay.running then return end

    zutil.updatetimer(NMeds.effectDelay, function ()
        ApplyNMedsEffect()
        NMeds.effectDelay.running = false
    end, 1, GlobalDT)
end

function ApplyNMedsEffect()
    NMeds.effectDuration.running = true
    NMeds.overlayIntensity.running = true
    zutil.playsfx(SFX.takeNMeds, .4, 1)
end

function UpdateNMedsDuration()
    if not NMeds.effectDuration.running then return end

    TimeMultiplier = zutil.lerp(1, .5, CalculateNMedsEffectIntensity())

    zutil.updatetimer(NMeds.effectDuration, function ()
        NMeds.effectDuration.running = false
        TimeMultiplier = 1
    end, 1, GlobalUnalteredDT)

    zutil.updatetimer(NMeds.heartbeatTimer, function ()
        zutil.playsfx(SFX.heartbeat, .4 * CalculateNMedsEffectIntensity(), 1)
    end, 1, GlobalUnalteredDT)

    if not NMeds.overlayIntensity.running then return end

    zutil.updatetimer(NMeds.overlayIntensity, function ()
        NMeds.overlayIntensity.running = false
    end, .01, GlobalUnalteredDT)
end

function DrawNMedsEffectOverlay()
    if not NMeds.effectDuration.running then return end

    love.graphics.setColor(0, 87/255, 25/255, CalculateNMedsEffectIntensity() / 2)
    love.graphics.setBlendMode("subtract")
    love.graphics.rectangle("fill", 0, 0, WINDOW.WIDTH, WINDOW.HEIGHT)
    love.graphics.setBlendMode("alpha")

    if NMeds.overlayIntensity.running then zutil.overlay({0,0,0, 1 - NMeds.overlayIntensity.current}) end
end

function CalculateNMedsEffectIntensity()
    local startTransitionBack = NMeds.effectDuration.max - 4*60
    return 1 - zutil.easing.easeInQuint(zutil.relu((NMeds.effectDuration.current - startTransitionBack)) / (NMeds.effectDuration.max - startTransitionBack))
end