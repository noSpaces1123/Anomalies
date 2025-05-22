Info = {
    width = 500,
    text =
[[Anomalies v0.3.3-alpha

---------------- CREDITS ----------------

Developer, sound designer, composer, graphic designer, game designer --> Adam Lensch (frazy)
Idea makers --> Adam Lensch (frazy), David Lensch (avacado)
Play testers --> David Lensch (avacado), Ben van den Bos

Losing is learning.]]
}



function DrawInfo()
    if not StartedShift then return end

    love.graphics.setColor(Colors[CurrentDepartment].text[1],Colors[CurrentDepartment].text[2],Colors[CurrentDepartment].text[3], .5)

    local font = Fonts.small
    love.graphics.setFont(font)

    local spacing = 10
    local _, wrapped = font:getWrap(Info.text, Info.width)
    local textY = WINDOW.HEIGHT - #wrapped * font:getHeight() - Sprites.frazy:getHeight() - spacing * 2

    love.graphics.printf(Info.text, spacing, textY, Info.width, "left")

    love.graphics.setColor(Colors[CurrentDepartment].text)
    love.graphics.draw(Sprites.frazy, spacing, WINDOW.HEIGHT - Sprites.frazy:getHeight() - spacing)
end