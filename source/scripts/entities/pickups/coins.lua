local gfx = playdate.graphics

local coins = {}

-- Default values
local BASIC_COIN_VALUE = 1

-- Enemy data
local basicCoins = {}
local basicCoinValue = BASIC_COIN_VALUE
local basicCoinImage = gfx.image.new("images/coin")


function coins.reset()
    -- Remove existing goblin sprites
    for _, basicCoin in ipairs(basicCoins) do
        basicCoin:remove()
    end

    basicCoins = {}

    basicCoinValue = BASIC_COIN_VALUE
end

function coins.spawnBasicCoin(x, y)
    local basicCoin = gfx.sprite.new(basicCoinImage)

    basicCoin:setCollideRect(-1, -1, 10, 10)
    basicCoin:moveTo(x, y)
    basicCoin:add()

    table.insert(basicCoins, basicCoin)
end

-- Unused for now
function coins.update(playerX, playerY)
    for _, basicCoin in ipairs(basicCoins) do
        local gx, gy = basicCoin.x, basicCoin.y
    end
end

function coins.remove(index)
    basicCoins[index]:remove()
    table.remove(basicCoins, index)
end

function coins.removeAll()
    for _, basicCoin in ipairs(basicCoins) do
        basicCoin:remove()
    end

    basicCoins = {}
end

function coins.increaseBasicCoinValue(amount)
    amount = amount or 1

    basicCoinValue += amount
end

function coins.getBasicCoinValue()
    return basicCoinValue
end

function coins.getAll()
    return basicCoins
end

function coins.count()
    return #basicCoins
end

-- Initial setup
coins.reset()

return coins
