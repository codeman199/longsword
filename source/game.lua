local pd = playdate
local gfx = pd.graphics

local player = import "entities/player"
local sword = import "entities/sword"
local enemies = import "entities/enemies"
local coins = import "entities/coins"

local game = {}

local gameState = "stopped"
local score = 0
local coinsHeld = 0
local killsThisRun = 0

-- Resets all values and starts the game
function game.start()
    gameState = "active"

    score = 0
    coinsHeld = 0
    killsThisRun = 0

    player.reset()
    sword.reset()
    enemies.reset()
    coins.reset()

    enemies.spawnGoblin()
end

function game.stop()
    gameState = "stopped"
end

function game.isActive()
    return gameState == "active"
end

function game.isStopped()
    return gameState == "stopped"
end

function game.addScore(points)
    score += points
    killsThisRun += 1

    -- Increase sword length every kill
    sword.upgradeLength()

    -- Increase goblin speed every 3 kills
    if killsThisRun % 3 == 0 then
        enemies.increaseGoblinSpeed()
    end

    -- Add another goblin every 5 kills
    if killsThisRun % 5 == 0 then
        enemies.spawnGoblin()
    end
end

function game.collectCoin()
    coinsHeld += coins.getBasicCoinValue()
end

function game.update()
    -- Stopped state
    if gameState == "stopped" then
        if pd.buttonJustPressed(pd.kButtonA) then
            game.start()
        end

        return
    end

    -- Update entities
    player.update()

    local px, py = player.getPosition()

    sword.update(px, py)

    enemies.update(px, py)

    -- Goblin logic
    local goblins = enemies.getAll()

    for i = #goblins, 1, -1 do
        local goblin = goblins[i]

        local gx, gy = goblin.x, goblin.y

        -- Sword collision
        if sword.checkCollision(px, py, gx, gy) then
            coins.spawnBasicCoin(gx, gy)

            enemies.remove(i)

            game.addScore(10)

            enemies.spawnGoblin()
        end

        -- Player collision
        if player.checkCollision(goblin) then
            game.stop()
            return
        end
    end

    local activeCoins = coins.getAll()

    for i = #activeCoins, 1, -1 do
        local activeCoin = activeCoins[i]

        -- Player collision
        if player.checkCollision(activeCoin) then
            game.collectCoin()
            coins.remove(i)
        end
    end

    -- Out of bounds check
    if player.isOutOfBounds() then
        game.stop()
    end
end

function game.drawUI()
    if gameState == "stopped" then
        gfx.drawTextAligned(
            "Press A to Start",
            200,
            120,
            kTextAlignment.center
        )

        return
    end

    gfx.drawText("Score: " .. score, 10, 10)
    gfx.drawText("Coins: " .. coinsHeld, 10, 30)
    gfx.drawText("Enemies: " .. enemies.count(), 10, 50)
end

return game
