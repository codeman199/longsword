local pd = playdate
local gfx = pd.graphics

local player = {}

-- Defaults
local START_X = 200
local START_Y = 120
local SPEED = 3

local image = gfx.image.new("images/knight")
local sprite = gfx.sprite.new(image)
sprite:setCollideRect(8, 8, 16, 16)
sprite:add()


function player.reset()
    sprite:moveTo(START_X, START_Y)
end

function player.update()
    if pd.buttonIsPressed(pd.kButtonUp) then
        sprite:moveBy(0, -SPEED)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        sprite:moveBy(0, SPEED)
    end

    if pd.buttonIsPressed(pd.kButtonRight) then
        sprite:moveBy(SPEED, 0)
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        sprite:moveBy(-SPEED, 0)
    end
end

function player.checkCollision(otherSprite)
    local overlaps = sprite:overlappingSprites()

    for _, other in ipairs(overlaps) do
        if other == otherSprite then
            return true
        end
    end

    return false
end

function player.getPosition()
    return sprite.x, sprite.y
end

function player.getX()
    return sprite.x
end

function player.getY()
    return sprite.y
end

function player.getSprite()
    return sprite
end

function player.isOutOfBounds()
    return (
        sprite.y > 270 or
        sprite.y < -30 or
        sprite.x > 430 or
        sprite.x < -30
    )
end

-- Initial setup
player.reset()

return player
