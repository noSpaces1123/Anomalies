Theories = {
    { name = "dream", checkIfToBeCollected = function ()
        return CurrentDepartment == "W"
    end, dialogue = {
        { text = "Where am I? Am I alive?" },
        { text = "Was I... dreaming?", showImage = true },
    }, dialogueIndex = 1 },
}
TheoryDialoguePlaying = {}

TheoriesCollected = {}



function CollectTheories()
    for _, theory in ipairs(Theories) do
        if theory.checkIfToBeCollected() then
            table.insert(TheoriesCollected, theory.name)
        end
    end
end