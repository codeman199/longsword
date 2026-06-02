local gfx = playdate.graphics

local enemies = {}

-- Default values
local START_GOBLIN_SPEED = 1.2

-- Enemy data
local goblins = {}
local goblinSpeed = START_GOBLIN_SPEED
local goblinImage = gfx.image.new("images/goblin")

function enemies.reset()
    -- Remove existing goblin sprites
    for _, goblin in ipairs(goblins) do
        goblin:remove()
    end

    goblins = {}

    goblinSpeed = START_GOBLIN_SPEED
end

function enemies.spawnGoblin()
    local goblin = gfx.sprite.new(goblinImage)

    goblin:setCollideRect(3, 3, 10, 10)

    -- Spawn from random edge
    local side = math.random(1, 4)

    if side == 1 then
        -- Left
        goblin:moveTo(-40, math.random(0, 240))
    elseif side == 2 then
        -- Right
        goblin:moveTo(480, math.random(0, 240))
    elseif side == 3 then
        -- Top
        goblin:moveTo(math.random(0, 400), -40)
    else
        -- Bottom
        goblin:moveTo(math.random(0, 400), 280)
    end

    goblin:add()

    table.insert(goblins, goblin)
end

function enemies.update(playerX, playerY)
    for _, goblin in ipairs(goblins) do
        local gx, gy = goblin.x, goblin.y

        local dx = playerX - gx
        local dy = playerY - gy

        local dist = math.sqrt(dx * dx + dy * dy)

        if dist > 0 then
            goblin:moveBy(
                goblinSpeed * (dx / dist),
                goblinSpeed * (dy / dist)
            )
        end
    end
end

function enemies.remove(index)
    goblins[index]:remove()
    table.remove(goblins, index)
end

function enemies.removeAll()
    for _, goblin in ipairs(goblins) do
        goblin:remove()
    end

    goblins = {}
end

function enemies.increaseGoblinSpeed(amount)
    amount = amount or 0.01

    goblinSpeed += amount
end

function enemies.getGoblinSpeed()
    return goblinSpeed
end

function enemies.getAll()
    return goblins
end

function enemies.count()
    return #goblins
end

-- Initial setup
enemies.reset()

return enemies
