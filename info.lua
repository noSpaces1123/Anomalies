Info = {
    showing = false,
    yOffset = 100, scrollYOffset = 0,
    width = 827,
    text =
[[
v0.1.0-alpha




---- CREDITS

Developer, sound designer, composer, graphic designer --> Adam Lensch (frazy)
Idea makers --> Adam Lensch (frazy), David Lensch (avacado)
Play testers --> David Lensch (avacado), Ben van den Bos

Losing is learning.




---- LICENSE

MIT License

Copyright (c) 2025 frazy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
}



function DrawInfo()
    if not Info.showing then return end

    zutil.overlay({0,0,0,.7})

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(Info.text, WINDOW.CENTER_X - Info.width / 2, Info.yOffset + Info.scrollYOffset, Info.width, "left")
end