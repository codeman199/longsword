import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd = playdate
local gfx = pd.graphics

-- Player
local playerStartX = 180
local playerStartY = 120
local playerSpeed = 3
local playerImage = playdate.graphics.image.new("images/knight")
local playerSprite = gfx.sprite.new(playerImage)
playerSprite:setCollideRect(8, 8, 16, 16)
playerSprite:moveTo(playerStartX, playerStartY)
playerSprite:add()

-- Sword
local swordHiltImage = gfx.image.new("images/sword-hilt")
local swordBladeImage = gfx.image.new("images/sword-blade")
local swordTipImage = gfx.image.new("images/sword-tip")
local _, swordHiltHeight = swordHiltImage:getSize()   -- Get width and height of hilt
local _, swordBladeHeight = swordBladeImage:getSize() -- Get width and height of blade
local _, swordTipHeight = swordTipImage:getSize()     -- Get width and height of blade

-- Sword Settings
local swordStartingLength = 1
local swordStartingWidth = 1
local swordAngle = 0
local swordImageOffet = 90 -- The sword images are drawn vertically, but we want them to start rotated
local swordLength = swordStartingLength
local swordWidth = swordStartingWidth
local swordDistance = 16
local swordThickness = 12 -- Base thickness

-- Sword Speed System (Instant Feel)
local swordSpeed = 1.0
local upgradeLevel = 0 -- From -20 to +20

local MAX_UPGRADES = 20
local MAX_SPEED = 3.0
local MIN_SPEED = 1 / 3
local BASE_SPEED = 1.0

-- Goblins
local goblins = {} -- Table to hold all goblin sprites
local goblinSpeed = 1.2
local goblinImage = gfx.image.new("images/goblin")

-- Game State
local gameState = "stopped"
local score = 0
local debugMode = false


-- Draw Sword
-- The sword is broken into 3 segments: Hilt, Blade, and Tip.
-- Based on the sword length, we scale the blade image to match the length we wish to represent.
local function drawSword(playerX, playerY, swordAngle)
    local rad = math.rad(swordAngle)
    local dx = math.cos(rad)
    local dy = math.sin(rad)

    local baseOffset = swordDistance

    -- Hilt
    local hiltX = playerX + baseOffset * dx
    local hiltY = playerY + baseOffset * dy
    swordHiltImage:drawRotated(hiltX, hiltY, swordAngle + swordImageOffet, swordWidth, 1)

    -- Blade
    local bladeStartOffset = baseOffset + swordHiltHeight

    -- Total desired blade length
    local bladeVisualLength = swordBladeHeight * (swordLength + 1)

    -- Important: Offset the blade position so it starts right after the hilt
    -- We subtract half the stretched height because scaling happens from center
    local halfStretch = (bladeVisualLength - swordBladeHeight) / 2

    local bladeX = playerX + (bladeStartOffset + halfStretch) * dx
    local bladeY = playerY + (bladeStartOffset + halfStretch) * dy

    swordBladeImage:drawRotated(
        bladeX,
        bladeY,
        swordAngle + swordImageOffet,
        swordWidth,
        (swordLength + 1)
    )

    -- Tip
    local tipOffset = bladeStartOffset + bladeVisualLength
    local tipX = playerX + tipOffset * dx
    local tipY = playerY + tipOffset * dy
    swordTipImage:drawRotated(tipX, tipY, swordAngle + swordImageOffet, swordWidth, 1)

    return tipX, tipY
end

-- Adjusts sword speed based on current upgrades
local function adjustSwordSpeedUpgrade(change)
    upgradeLevel = math.max(-MAX_UPGRADES, math.min(MAX_UPGRADES, upgradeLevel + change))

    -- Instantly calculate new speed
    if upgradeLevel >= 0 then
        local t = upgradeLevel / MAX_UPGRADES
        swordSpeed = BASE_SPEED + (MAX_SPEED - BASE_SPEED) * t
    else
        local t = -upgradeLevel / MAX_UPGRADES
        swordSpeed = BASE_SPEED + (MIN_SPEED - BASE_SPEED) * t
    end
end

-- Spawn a new goblin
local function spawnGoblin()
    local goblin = gfx.sprite.new(goblinImage)
    goblin:setCollideRect(4, 4, 24, 24)

    -- Spawn off-screen on random side
    local side = math.random(1, 4)
    if side == 1 then     -- left
        goblin:moveTo(-40, math.random(0, 240))
    elseif side == 2 then -- right
        goblin:moveTo(480, math.random(0, 240))
    elseif side == 3 then -- top
        goblin:moveTo(math.random(0, 400), -40)
    else                  -- bottom
        goblin:moveTo(math.random(0, 400), 280)
    end

    goblin:add()
    table.insert(goblins, goblin)
end

-- Sword collision detection - Checks if a point (usually an enemy) is touching the sword
-- px, py = Player position
-- gx, gy = Goblin (or target) position
-- tipX, tipY = Current sword tip position
local function pointOnSword(playerX, playerY, enemyX, enemyY, tipX, tipY)
    -- Vector from player to sword tip
    local dx = tipX - playerX
    local dy = tipY - playerY

    -- Squared length of the sword (faster than using math.sqrt)
    local lengthSq = dx * dx + dy * dy

    -- Prevent division by zero if sword has zero length
    if lengthSq == 0 then
        return false
    end

    -- Project the goblin onto the sword's line
    -- This calculates how far along the sword (from 0 to 1) the closest point is
    local t = ((enemyX - playerX) * dx + (enemyY - playerY) * dy) / lengthSq

    -- Clamp t between 0 and 1 so we only consider the actual sword segment
    -- (not the infinite line extending beyond the player or tip)
    t = math.max(0, math.min(1, t))

    -- Calculate the closest point on the sword segment to the goblin
    local projX = playerX + t * dx
    local projY = playerY + t * dy

    -- Calculate squared distance between goblin and the closest point on sword
    local distSq = (enemyX - projX) ^ 2 + (enemyY - projY) ^ 2

    local currentSwordThickness = swordThickness

    -- Return true if goblin is within the sword's hitbox thickness
    return distSq < (currentSwordThickness * currentSwordThickness)
end

function pd.update()
    gfx.sprite.update()

    if gameState == "stopped" then
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "active"
            score = 0
            swordLength = swordStartingLength
            swordSpeed = 1
            goblinSpeed = 1

            playerSprite:moveTo(playerStartX, playerStartY)
            swordAngle = 0

            -- Clear old goblins
            for _, goblin in ipairs(goblins) do
                goblin:remove()
            end
            goblins = {}

            -- Spawn initial goblin
            spawnGoblin()
        end
    elseif (gameState == "active") then
        -- || PLAYER MOVEMENT ||
        if (pd.buttonIsPressed(pd.kButtonUp)) then
            playerSprite:moveBy(0, -playerSpeed)
        elseif (pd.buttonIsPressed(pd.kButtonDown)) then
            playerSprite:moveBy(0, playerSpeed)
        end

        if (pd.buttonIsPressed(pd.kButtonRight)) then
            playerSprite:moveBy(playerSpeed, 0)
        elseif (pd.buttonIsPressed(pd.kButtonLeft)) then
            playerSprite:moveBy(-playerSpeed, 0)
        end

        -- Player x and y
        local playerX, playerY = playerSprite.x, playerSprite.y

        -- || SWORD MOVEMENT ||
        local crankChange = pd.getCrankChange()
        swordAngle = (swordAngle + crankChange * swordSpeed) % 360


        local tipX, tipY = drawSword(playerX, playerY, swordAngle)

        -- || GOBLIN LOGIC ||
        for i = #goblins, 1, -1 do
            local goblin = goblins[i]
            local gx, gy = goblin.x, goblin.y

            -- Chase player
            local dx = playerX - gx
            local dy = playerY - gy
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist > 0 then
                goblin:moveBy(goblinSpeed * (dx / dist), goblinSpeed * (dy / dist))
            end

            -- || COLLISION CHECKS ||
            -- Sword hit (manual check)
            if pointOnSword(playerX, playerY, gx, gy, tipX, tipY) then
                goblin:remove()
                table.remove(goblins, i)
                score += 10
                spawnGoblin()

                -- Increase sword length and decrease sword speed every kill
                if score % 10 == 0 then
                    swordLength = swordLength + 1
                    --adjustSwordSpeedUpgrade(-1)
                end

                -- Increase goblin speed every 2 kills
                if score % 10 == 0 then
                    goblinSpeed += 0.01
                end

                -- Increase number of goblins every 5 kills
                if score % 30 == 0 then
                    spawnGoblin()
                end
            end

            -- Goblin hits player
            local playerOverlaps = playerSprite:overlappingSprites()
            for _, other in ipairs(playerOverlaps) do
                if other == goblin then
                    gameState = "stopped"
                    break
                end
            end
        end

        gfx.drawText("Score: " .. score, 10, 10)
        gfx.drawText("Length: " .. math.floor(swordLength), 10, 30)
        gfx.drawText("Angle: " .. math.floor(swordAngle), 10, 50)

        -- Boundary check
        if playerSprite.y > 270 or playerSprite.y < -30 or playerSprite.x > 430 or playerSprite.x < -30 then
            gameState = "stopped"
        end
    end
end
