-- MIT License

-- Copyright (c) 2025 frazy

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.



---@diagnostic disable: undefined-global

local zutil = { _version = "1.0", easing = {} }



--Supply an amplitude. Returns a random value between `amplitude * -1` and `amplitude`.
function zutil.jitter(amplitude)
    return (math.random()-math.random())*amplitude
end

--Supply x, a minimum, and maximum. Returns x "restrained" between the minimum and maximum.
function zutil.clamp(x, min, max)
    if x < min then x = min
    elseif x > max then x = max
    end
    return x
end

--Supply x, y, width, and height values for two objects. Returns boolean: whether or not the objects are colliding.
function zutil.touching(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 + w1 >= x2 and y1 + h1 >= y2 and x1 <= x2 + w2 and y1 <= y2 + h2
end

--Simple easing function. Supply a value `x` where `0 ≤ x ≤ 1`.
function zutil.easing.easeOutQuint(x)
    return 1 - (1 - x)^5
end

--Simple easing function. Supply a value `x` where `0 ≤ x ≤ 1`
function zutil.easing.easeInQuint(x)
    return x^5
end

--Simple easing function. Supply a value `x` where `0 ≤ x ≤ 1`.
function zutil.easing.easeInExpo(x)
    return (x == 0 and 0 or 2^(10 * x - 10))
end

--Simple easing function. Supply a value `x` where `0 ≤ x ≤ 1`.
function zutil.easing.easeOutExpo(x)
    return (x == 1 and 1 or 1 - 2^(-10 * x))
end

--Simple easing function. Supply a value `x` where `0 ≤ x ≤ 1`.
function zutil.easing.easeInOutCubic(x)
    return (x < 0.5 and 4 * x^3 or 1 - (-2 * x + 2)^3 / 2)
end

--Returns `math.sqrt(a^2 + b^2)`.
function zutil.pythag(a, b)
    return math.sqrt(a^2 + b^2)
end

--Supply a maximum `a`, a minimum `b`, and a float `t`, where `0 ≤ t ≤ 1`. Returns `a + (b - a) * t`.
function zutil.lerp(a, b, t)
    return a + (b - a) * t
end

--Supply a maximum `a`, a minimum `b`, and a value `x`. Returns `(x - a) / (b - a)`. This function is a rearranged form of `x = f(a,b,t)`, here as `t = g(a,b,x)`.
function zutil.reverselerp(a, b, x)
    return (x - a) / (b - a)
end

--Supply two pairs of coordinates. Returns the coordinates of the midpoint between the two.
function zutil.midpoint(x1, y1, x2, y2)
    return (x1 + x2) / 2, (y1 + y2) / 2
end

--Supply two pairs of coordinates. Returns the distance between the two.
function zutil.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

--Displays data about supplied variables. Requires Love2D. Supply any non-function variables you wish. Returns a string containing one data point about each variable, split over multiple lines.
function zutil.varDisplay(...)
    local t = {...}
    local text = ""

    for _, value in ipairs(t) do
        if type(value) == "table" then
            text = text..#value.." items\n"
        elseif type(value) == "function" or type(value) == "userdata" or type(value) == "thread" then
            error("Cannot display contents of a "..type(value).." value.")
        else
            text = text..tostring(value).."\n"
        end
    end

    return text
end

--Supply a pair of coordinates. Returns the angle between them in radians.
function zutil.anglebetween(x1, y1, x2, y2)
---@diagnostic disable-next-line: deprecated
    return math.atan2(x2 - x1, y2 - y1)
end

--Supply a table. Returns the table with the order of its elements randomized.
function zutil.shuffle(t)
    local newt = {}
    for _ = 1, #t do
        newt[#newt+1] = table.remove(t, math.random(#t))
    end
    return newt
end

--Requires Löve2D. Renders a rectangle of the specified color and alpha over the entirety of the screen (be wary of graphics transformations you may have applied). Supply a table `color`, containing the RGB and alpha values of the overlay.
function zutil.overlay(color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

--Requires Löve2D. Initialises global variables WINDOW.WIDTH, WINDOW.HEIGHT, WINDOW.CENTER_X, and WINDOW.CENTER_Y, sets file identity, sets window title, turns on highdpi setting, and sets window dimensions.
function zutil.stdinit(windowWidth, windowHeight, gameName)
    love.window.setMode(windowWidth, windowHeight, {highdpi=true})

    WINDOW = {
        WIDTH = love.graphics.getWidth(),
        HEIGHT = love.graphics.getHeight(),
    }
    WINDOW.CENTER_X = WINDOW.WIDTH / 2
    WINDOW.CENTER_Y = WINDOW.HEIGHT / 2

    love.window.setTitle(gameName)
    love.filesystem.setIdentity(gameName)
end

--Supply a string and a separator (single character). Returns a table containing the substrings of the string split by the separator (all substrings excluding the separator).
function zutil.split(str, separator)
    local t = {""}
    for i = 1, #str do
        local char = string.sub(str,i,i)
        if char == separator then
            t[#t+1] = ""
        else
            t[#t] = t[#t]..char
        end
    end
    return t
end

--Requires Löve2D. Loads SFX with fle type `fileType` (suffix, like ".wav" or ".ogg") from the desired directory into the supplied `sfxTable`. Returns `sfxTable`.
function zutil.loadsfx(directory, sfxTable, fileType)
    for _, name in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local suffix = zutil.split(name,".")[2]
        if suffix ~= fileType then     goto next     end
        sfxTable[zutil.split(name,".")[1]] = love.audio.newSource(directory.."/"..name, "static")
        ::next::
    end
    return sfxTable
end

--Requires Löve2D. Plays an audio source. Returns whether the audio source had to be stopped.
function zutil.playsfx(sfx, volume, pitch)
    assert(sfx, "Invalid/nil audio source supplied.")
    local isPlaying = sfx:isPlaying()
    sfx:stop()
    sfx:setVolume((volume and volume or 1))
    sfx:setPitch((pitch and pitch or 1))
    sfx:play()
    return isPlaying
end

--Supply a value `x`, `a`, and `b`. Returns `x` wrapped between `a` and `b`.
function zutil.wrap(x, a, b)
    if x < a then return zutil.wrap(b - (a - x) + 1, a, b)
    elseif x > b then return zutil.wrap(a + (x - b) - 1, a, b)
    else return x end
end

--Requires Löve2D. Initialises a global variable `graphics = love.graphics`.
function zutil.abbreviatelove2dgraphics()
---@diagnostic disable-next-line: lowercase-global
    graphics = love.graphics
end

--Supply a value `x` and an integer `placeValue` (1). Returns x truncated to the `placeValue` supplied. For example: `zutil.floor(5.6, 1) = 5`, `zutil.floor(91, 2) = 90`, `zutil.floor(220, 3) = 200`.
function zutil.floor(x, placeValue)
    placeValue = (placeValue and placeValue - 1 or 1)
    return math.floor(x/10^placeValue)*10^placeValue
end

--Supply a value `x` and an integer `placeValue` (1). Returns x rounded up to the `placeValue` supplied. For example: `zutil.ceiling(5.6, 1) = 6`, `zutil.ceiling(91, 2) = 100`, `zutil.ceiling(220, 3) = 300`.
function zutil.ceiling(x, placeValue)
    placeValue = (placeValue and placeValue - 1 or 1)
    return math.ceil(x/10^placeValue)*10^placeValue
end

--Supply a timer table `timer`, a function `completeFunction`, a number `speed` to increment by, and the delta-time `dt`. `timer` must have fields `current: number` and `max: number`. This function returns the `current` field of the timer incremented by `dt * speed`.
function zutil.updatetimer(timer, completeFunction, speed, dt)
    assert(timer.current and timer.max, "Timer table supplied must have fields 'current' and 'max'.")
    timer.current = timer.current + speed * dt
    if timer.current > timer.max then
        repeat
            timer.current = timer.current - timer.max
            if completeFunction then completeFunction() end
        until timer.current < timer.max
    end
    return timer
end

--Supply a table `t` and a value `v` to remove from the table. Returns the value removed and the index it was removed at. Returns `nil` if the value was not found.
function zutil.remove(t, v)
    for index, value in ipairs(t) do
        if value == v then
            table.remove(t,index)
            return v, index
        end
    end
    return nil, nil
end

--Supply a table `t` and a value `v` to search for in the table. Returns the the index the value was found at. Returns `nil` if the value was not found.
function zutil.search(t, v)
    for index, value in ipairs(t) do
        if value == v then
            return index
        end
    end
    return nil
end

--Returns the number of elements in table `t`, ignoring elements with a field `disabled = true`.
function zutil.count(t)
    local n = 0
    for _, value in ipairs(t) do
        if not value.disabled then n = n + 1 end
    end
    return n
end

--Returns "You're welcome!"
function zutil.thanks()
    return "You're welcome!"
end

--Returns `t` with the elements of `tSprinkle` randomly placed within.
function zutil.sprinkle(t, tSprinkle)
    for _, value in ipairs(tSprinkle) do
        table.insert(t, math.random(#t), value)
    end
    return t
end

--Returns a clone of table `t`, not sharing a memory adress with `t`.
function zutil.clone(t)
    local newt = {}
    for key, value in pairs(t) do newt[key] = value end
    return newt
end

--Returns `nilv` if `x` is nil, otherwise returns `v`.
function zutil.nilcheck(x, v, nilv)
    return (x and v or nilv)
end

--Returns a table containing all English letters (without diacratics) in lowercase.
function zutil.letters()
    local t = {}
    local letters = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, #letters do t[#t+1] = string.sub(letters,i,i) end
    return t
end

--Returns `x` if `x > 0`, otherwise returns `0`.
function zutil.relu(x)
    if x < 0 then return 0
    else return x end
end

--Returns a random value from table `t`, where the values of `t` are fields equal to their weight. For example, with `zutil.weighted({ lion = 2, bear = 1 })`, this function is two times more likely to return `"lion"` than `"bear"`.
function zutil.weighted(t)
    local pool = {}
    for key, weight in pairs(t) do
        for _ = 1, weight do pool[#pool+1] = key end
    end
    return pool[math.random(#pool)]
end

--Supply a percentage `trueWeight` where `0 ≤ trueWeight ≤ 100`. Returns `true` `trueWeight`% of the time.
function zutil.weightedbool(trueWeight)
    return math.random(0,100) <= trueWeight
end

--Returns a random element from table `t`.
function zutil.randomchoice(t)
    return t[math.random(#t)]
end

--Sets the random seed to `os.time()`: `math.randomseed(os.time())`. Returns the seed used.
function zutil.alwaysrandom()
    local seed = os.time()
    math.randomseed(seed)
    return seed
end





return zutil