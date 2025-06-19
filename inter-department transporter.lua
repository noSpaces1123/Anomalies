InterDepartmentTransporter = {
    sprite = love.graphics.newImage("assets/sprites/inter-department transporter.png", {dpiscale = 4}),
    codes = {
        [LizardGlobalData.departmentCode] = function ()
            StartDepartmentTransition()
            DepartmentTransition.running = true
            DepartmentTransition.afterDepartmentChoiceWait.running = true
            DepartmentTransition.afterDepartmentChoiceWait.current = 0
            DepartmentTransition.departmentChoice = "LIZARD"
            Dialogue.playing.textThusFar = ""
            TurnOffDialogueAnimations()
        end,
    },
    x = 120, y = WINDOW.HEIGHT - 300,
    box = {
        input = "", charLimit = 4, typing = false,
        textX = 20, textY = 48, -- offsets from InterDepartmentTransporter.x and .y
        x = 8.75, y = 40, width = 112.5, height = 46.5,
    },
    particleTimer = { current = 0, max = 8 },
    suspendMusic = false,
}
InterDepartmentTransporter.width, InterDepartmentTransporter.height = InterDepartmentTransporter.sprite:getDimensions()

HasInterDepartmentTransporter = false



function DrawInterDepartmentTransporter()
    if not HasInterDepartmentTransporter or not NoRNERunning() or RNEPractice.wait.running or GameState ~= "game" then return end

    local drawX, drawY = InterDepartmentTransporter.x, InterDepartmentTransporter.y

    if InterDepartmentTransporter.box.typing then
        zutil.updatetimer(InterDepartmentTransporter.particleTimer, function ()
            table.insert(Particles, NewParticle(drawX + InterDepartmentTransporter.width / 2, drawY + InterDepartmentTransporter.height / 2,
            math.random(2,5), {1,1/3,0}, math.random()*2+1, math.random(360), -0.04, math.random(200,400), function (self)
                if self.speed > 0 then
                    self.speed = self.speed - 0.01
                    if self.speed < 0 then self.speed = 0 end
                end
            end))
        end, 1, GlobalDT)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(InterDepartmentTransporter.sprite, drawX, drawY)

    local text = InterDepartmentTransporter.box.input

    if InterDepartmentTransporter.box.input == "" then
        text = "PIN"
        love.graphics.setColor(1,1,1,.3)
    end

    love.graphics.setFont(Fonts.interDepartmentTransporterInput)
    love.graphics.print(text, drawX + InterDepartmentTransporter.box.textX, drawY + InterDepartmentTransporter.box.textY)
end

function GetInterDepartmentTransporter()
    zutil.playsfx(SFX.getInterDepartmentTransporter, .6, 1)
    HasInterDepartmentTransporter = true
    SaveData()
end