AllConditions = {
    A = {
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 0 },
                { offset = { y = 1, x = 0 }, type = 2 }
            }
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 0 },
                { offset = { y = 0, x = 1 }, type = 2 }
            }
        },
        {
            parts = {
                { offset = { y = -2, x = 0 }, type = 0 },
                { offset = { y = 2, x = 0 }, type = 0 }
            }
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = -1 },
                { offset = { y = 1, x = 0 }, type = -1 }
            }
        },
        {
            parts = {
                { offset = { y = -1, x = -1 }, type = -1 },
                { offset = { y = 1, x = 1 }, type = -1 }
            }
        },
        {
            parts = {
                { offset = { y = -2, x = 0 }, type = 1 },
                { offset = { y = 2, x = 0 }, type = 1 }
            },
            isNot = true
        },
    },

    B = {
        {
            parts = {
                { offset = { y = -1, x = -2 }, type = 0 },
                { offset = { y = 1, x = 2 }, type = 0 }
            }
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 3 },
                { offset = { y = 2, x = 0 }, type = 0 }
            }
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = -1 },
                { offset = { y = 0, x = 1 }, type = -1 }
            }
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 3 },
                { offset = { y = 0, x = 1 }, type = 1 }
            }
        },
        {
            parts = {
                { offset = { y = 1, x = 0 }, type = 3 },
                { offset = { y = 0, x = -1 }, type = 0 }
            }
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = -1 },
                { offset = { y = 1, x = 0 }, type = -1 }
            },
            isNot = true,
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 0 },
                { offset = { y = 1, x = 0 }, type = 0 }
            },
            isNot = true,
        },
    },

    X = {
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 3 },
                { offset = { y = 1, x = -1 }, type = 2 },
                { offset = { y = 1, x = 1 }, type = 2 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 2 },
                { offset = { y = 1, x = -1 }, type = 0 },
                { offset = { y = 1, x = 1 }, type = 3 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 2 },
                { offset = { y = 0, x = 1 }, type = 2 },
                { offset = { y = 1, x = 0 }, type = 2 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = 1 }, type = 3 },
                { offset = { y = 1, x = -1 }, type = 0 },
            },
        },
        {
            parts = {
                { offset = { y = 1, x = 0 }, type = 0 },
            },
            isNot = true,
        },
    },

    C = {
        {
            parts = {
                { offset = { y = -1, x = 1 }, type = 2 },
                { offset = { y = 1, x = -1 }, type = 2 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 2 },
                { offset = { y = 0, x = -1 }, type = 1 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 3 },
                { offset = { y = -1, x = -1 }, type = 0 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = -1 }, type = 1 },
                { offset = { y = 1, x = -1 }, type = 1 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 0 },
                { offset = { y = 0, x = 1 }, type = 0 },
            },
            isNot = true,
        },
    },

    D = {
        {
            parts = {
                { offset = { y = 1, x = -1 }, type = 1 },
                { offset = { y = -1, x = 0 }, type = 2 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 3 },
                { offset = { y = 0, x = 1 }, type = 2 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 2 },
                { offset = { y = 0, x = 1 }, type = 1 },
                { offset = { y = 1, x = 1 }, type = 1 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = -1 }, type = 1 },
                { offset = { y = -1, x = 1 }, type = 1 },
                { offset = { y = -1, x = 0 }, type = 1 },
                { offset = { y = 1, x = 0 }, type = 3 },
            },
        },
        {
            parts = {
                { offset = { y = 0, x = -1 }, type = 0 },
            },
            isNot = true,
        },
    },

    R = {
        {
            parts = {
                { offset = { y = -1, x = -1 }, type = 1 },
                { offset = { y = 1, x = 0 }, type = 1 },
            },
        },
        {
            parts = {
                { offset = { y = -1, x = 0 }, type = 2 },
                { offset = { y = 0, x = 1 }, type = 2 },
            },
        },
    },
}

NewCardIndicator = {
    on = false,
    bounce = { current = 0, max = 360 },
    sprite = love.graphics.newImage("assets/sprites/new card.png", {dpiscale=4})
}



function LoadCards()
    Cards = {}
    local directory = "assets/sprites/cards/department " .. CurrentDepartment
    local peskyDSSTore = false
    for index, fileName in ipairs(love.filesystem.getDirectoryItems(directory)) do
        if fileName == ".DS_Store" then
            peskyDSSTore = true
        else
            local fileDir = directory.."/".. index - (peskyDSSTore and 1 or 0) ..".png"
            table.insert(Cards, { sprite = love.graphics.newImage(fileDir, {dpiscale = 5}), condition = AllConditions[CurrentDepartment][index - (peskyDSSTore and 1 or 0)] })
        end
    end
end

function DrawCards()
    local maxDistance = 40
    local distance = zutil.distance(love.mouse.getX(), love.mouse.getY(), love.mouse.getX(), WINDOW.HEIGHT)
    local ratio = distance/maxDistance
    local alpha = 1 - (Handbook.showing and 1 or zutil.clamp(ratio, 0, 1))
    if distance <= maxDistance then NewCardIndicator.on = false end -- turn of new card indicator thing

    local spacing = 10
    local spacingBetweenCards = 5
    local anchorX, anchorY = WINDOW.CENTER_X - ConditionsCollected / 2 * Cards[1].sprite:getWidth(), WINDOW.HEIGHT - spacing - Cards[1].sprite:getHeight() + (1 - alpha) * Cards[1].sprite:getWidth()

    spacing = 300
    love.graphics.setColor(Colors[CurrentDepartment].text[1],Colors[CurrentDepartment].text[2],Colors[CurrentDepartment].text[3], 1 - alpha)
    love.graphics.setLineWidth(1)
    local y = WINDOW.HEIGHT - 10
    love.graphics.line(spacing, y, WINDOW.WIDTH - spacing, y)

    love.graphics.setColor(1,1,1, alpha)
    for index, card in ipairs(Cards) do
        if index > ConditionsCollected then break end
        love.graphics.draw(card.sprite, anchorX + (index - 1) * (card.sprite:getWidth() + spacingBetweenCards), anchorY)
    end

    DrawNewCardIndicator()
end

function UpdateNewCardIndicator()
    zutil.updatetimer(NewCardIndicator.bounce, nil, 2, GlobalDT)
end
function DrawNewCardIndicator()
    if not NewCardIndicator.on then return end

    love.graphics.setColor(Colors[CurrentDepartment].fileOutline)
    love.graphics.draw(NewCardIndicator.sprite, WINDOW.CENTER_X - NewCardIndicator.sprite:getWidth()/2, WINDOW.HEIGHT - 50 - math.abs(math.sin(math.rad(NewCardIndicator.bounce.current))) * 10)
end