AlarmDelay = { current = 0, max = .6*60, running = false }
AlarmInterval = { current = 0, max = 10*60 }
CameraShotOverlay = { current = 0, max = .17*60, running = false }

UseCameraShots = false



function UpdateAlarmInterval()
    if not UseCameraShots or not DepartmentData[CurrentDepartment].useCameraShots or DepartmentTransition.running or GridGlobalData.generationAnimation.running or Spinner.running or Barcode.running or Screen.running or Road.running or RNEPractice.running then return end

    zutil.updatetimer(AlarmInterval, function ()
        StartAlarm()
    end, 1, GlobalDT)
end

function StartAlarm()
    AlarmDelay.running = true
    AlarmDelay.current = 0
    zutil.playsfx(SFX.alarmBlare, .2, 1)
    MusicPlaying.audio:pause()
end
function UpdateAlarmDelay()
    if not AlarmDelay.running then return end

    zutil.updatetimer(AlarmDelay, function ()
        TakeCameraShot()
        MusicPlaying.audio:play()
        AlarmDelay.running = false
    end, 1, GlobalDT)

    ShakeIntensity = 2
end

function TakeCameraShot()
    zutil.playsfx(SFX.cameraShot, .3, 1)

    local mx, my = love.mouse.getPosition()
    local gx, gy = GetGridAnchorCoords()
    if zutil.touching(mx, my, 0, 0, gx, gy, #Grid[1]*SquareGlobalData.width, #Grid*SquareGlobalData.height) then
        Wrong()
    else
        CameraShotOverlay.current = 0
        CameraShotOverlay.running = true
    end
end

function UpdateCameraShotOverlay()
    if not CameraShotOverlay.running then return end
    zutil.updatetimer(CameraShotOverlay, function ()
        CameraShotOverlay.running = false
    end, 1, GlobalDT)
end
function DrawCameraShotOverlay()
    if not CameraShotOverlay.running then return end
    zutil.overlay({1,1,1})
end