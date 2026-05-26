local pd = playdate
local gfx = pd.graphics

local sword = {}

-- Defaults
local START_LENGTH = 1
local START_WIDTH = 1
local START_SPEED = 1
local START_ANGLE = 0

local DISTANCE = 16
local THICKNESS = 12
local IMAGE_OFFSET = 90

-- Speed system
local BASE_SPEED = 1.0
local MAX_SPEED = 3.0
local MIN_SPEED = 1 / 3
local MAX_UPGRADES = 20

-- Runtime values
local angle = START_ANGLE
local speed = START_SPEED
local length = START_LENGTH
local width = START_WIDTH
local upgradeLevel = 0

-- Images
local hilt = gfx.image.new("images/sword-hilt")
local blade = gfx.image.new("images/sword-blade")
local tip = gfx.image.new("images/sword-tip")

local _, hiltHeight = hilt:getSize()
local _, bladeHeight = blade:getSize()

local tipX = 0
local tipY = 0

function sword.reset()
    angle = START_ANGLE
    speed = START_SPEED
    length = START_LENGTH
    width = START_WIDTH
    upgradeLevel = 0
end

function sword.upgradeLength()
    length += 1
end

function sword.adjustSpeedUpgrade(change)
    upgradeLevel = math.max(
        -MAX_UPGRADES,
        math.min(MAX_UPGRADES, upgradeLevel + change)
    )

    if upgradeLevel >= 0 then
        local t = upgradeLevel / MAX_UPGRADES
        speed = BASE_SPEED + (MAX_SPEED - BASE_SPEED) * t
    else
        local t = -upgradeLevel / MAX_UPGRADES
        speed = BASE_SPEED + (MIN_SPEED - BASE_SPEED) * t
    end
end

function sword.update(playerX, playerY)
    local crankChange = pd.getCrankChange()

    angle = (angle + crankChange * speed) % 360

    sword.draw(playerX, playerY)
end

function sword.draw(playerX, playerY)
    local rad = math.rad(angle)

    local dx = math.cos(rad)
    local dy = math.sin(rad)

    -- Hilt
    local hiltX = playerX + DISTANCE * dx
    local hiltY = playerY + DISTANCE * dy

    hilt:drawRotated(hiltX, hiltY, angle + IMAGE_OFFSET)

    -- Blade
    local bladeLength = bladeHeight * (length + 1)

    local halfStretch = (bladeLength - bladeHeight) / 2

    local bladeX =
        playerX + (DISTANCE + hiltHeight + halfStretch) * dx

    local bladeY =
        playerY + (DISTANCE + hiltHeight + halfStretch) * dy

    blade:drawRotated(
        bladeX,
        bladeY,
        angle + IMAGE_OFFSET,
        width,
        length + 1
    )

    -- Tip
    local tipOffset = DISTANCE + hiltHeight + bladeLength

    tipX = playerX + tipOffset * dx
    tipY = playerY + tipOffset * dy

    tip:drawRotated(tipX, tipY, angle + IMAGE_OFFSET)
end

function sword.checkCollision(playerX, playerY, enemyX, enemyY)
    local dx = tipX - playerX
    local dy = tipY - playerY

    local lengthSq = dx * dx + dy * dy

    if lengthSq == 0 then
        return false
    end

    local t =
        ((enemyX - playerX) * dx + (enemyY - playerY) * dy)
        / lengthSq

    t = math.max(0, math.min(1, t))

    local projX = playerX + t * dx
    local projY = playerY + t * dy

    local distSq =
        (enemyX - projX) ^ 2 +
        (enemyY - projY) ^ 2

    return distSq < (THICKNESS * THICKNESS)
end

-- Initial setup
sword.reset()

return sword
