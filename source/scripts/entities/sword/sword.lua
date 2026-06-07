import "scripts/logic/swordStats"
import "scripts/entities/player/player"
import "CoreLibs/object"

local pd                 = playdate
local gfx                = pd.graphics

local swordStats <const> = SwordStats

-- Distance in pixels between hilt of sword and center of player
local DISTANCE           = 22

-- Draw sword sprites with offset of 90 degrees so they start horizontal
local IMAGE_OFFSET       = 90
local currentBladeReach  = 0

local hilt               = gfx.image.new("images/sword_hilt_single")
local blade              = gfx.image.new("images/sword_blade")
local tip                = gfx.image.new("images/sword_tip_single")

local _, hiltHeight      = hilt:getSize()
local _, bladeHeight     = blade:getSize()

class('Sword').extends(gfx.sprite)

function Sword:init(x, y, gameManager, levelScene)
    self.gameManager     = gameManager
    self.levelScene      = levelScene

    self.length          = swordStats.length
    self.width           = swordStats.width
    self.damage          = swordStats.damage
    self.speed           = swordStats.speed
    self.thickness       = swordStats.thickness
    self.baseCritChance  = swordStats.baseCritChance
    self.baseCritDamage  = swordStats.baseCritDamage

    self.angle           = 0
    --self:setZIndex(Z_INDEXES.SWORD)

    --self.animationLoop      = gfx.animation.loop.new(200, playerSpriteSheet, true)

    self.hiltSpriteSheet = gfx.imagetable.new("images/sword_hilt")
    self.bladeImage      = gfx.image.new("images/sword_blade")
    self.tipSpriteSheet  = gfx.imagetable.new("images/sword_tip")

    self.hiltSprite      = gfx.sprite.new(self.hiltSpriteSheet[1])
    self.bladeSprite     = gfx.sprite.new(self.bladeImage)
    self.tipSprite       = gfx.sprite.new(self.tipSpriteSheet[1])

    self.hiltSprite:add()
    self.bladeSprite:add()
    self.tipSprite:add()
    self:add()
end

function Sword:upgradeLength()
    self.length += 1
end

function Sword:update()
    local playerX, playerY = self.player.x, self.player.y
    local crankChange = pd.getCrankChange()

    self.angle = (self.angle + crankChange * self.speed) % 360
    local hiltFrame = (math.floor((self.angle + 90) / 360 * 16 + 0.5) % 16) + 1
    local tipFrame = (math.floor((self.angle + 90) / 360 * 8 + 0.5) % 8) + 1

    local rad = math.rad(self.angle)
    local dx = math.cos(rad)
    local dy = math.sin(rad)

    local bladeLength = bladeHeight * (self.length + 1)
    currentBladeReach = DISTANCE + (hiltHeight - bladeHeight) + bladeLength - 2

    -- Hilt
    local hiltX = playerX + DISTANCE * dx
    local hiltY = playerY + DISTANCE * dy

    self.hiltSprite:setImage(self.hiltSpriteSheet[hiltFrame])
    self.hiltSprite:moveTo(hiltX, hiltY)

    -- Blade
    local bladeLength = bladeHeight * (self.length + 1)
    local halfStretch = (bladeLength - bladeHeight) / 2
    local bladeX = playerX + (DISTANCE + (hiltHeight - bladeHeight - 1) + halfStretch) * dx
    local bladeY = playerY + (DISTANCE + (hiltHeight - bladeHeight - 1) + halfStretch) * dy

    self.bladeSprite:moveTo(bladeX, bladeY)
    self.bladeSprite:setRotation(self.angle + IMAGE_OFFSET)
    if self.width ~= self.currentWidth or self.length ~= self.currentLength then
        self.currentWidth = self.width
        self.currentLength = self.length
        self.bladeSprite:setScale(self.width, self.length + 1)
    end

    -- Tip
    local tipOffset = (DISTANCE + (hiltHeight - bladeHeight) + bladeLength) - 2
    local tipX = playerX + tipOffset * dx
    local tipY = playerY + tipOffset * dy

    self.tipSprite:moveTo(tipX, tipY)
    self.tipSprite:setImage(self.tipSpriteSheet[tipFrame])
end

local function segmentIntersectsCircle(x1, y1, x2, y2, cx, cy, radius)
    local dx = x2 - x1
    local dy = y2 - y1
    local fx = x1 - cx
    local fy = y1 - cy
    local a = dx * dx + dy * dy
    if a == 0 then
        return (fx * fx + fy * fy) < (radius * radius)
    end
    local b = 2 * (fx * dx + fy * dy)
    local c = (fx * fx + fy * fy) - (radius * radius)
    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return false end
    local sqrtDisc = math.sqrt(discriminant)
    local t1 = (-b - sqrtDisc) / (2 * a)
    local t2 = (-b + sqrtDisc) / (2 * a)
    if (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1) then return true end
    if t1 < 0 and t2 > 1 then return true end
    return false
end

function Sword:checkCollision(playerX, playerY, enemyX, enemyY, enemyRadius)
    local rad = math.rad(self.angle)
    local dx = math.cos(rad)
    local dy = math.sin(rad)
    local x1 = playerX + DISTANCE * dx
    local y1 = playerY + DISTANCE * dy
    local x2 = playerX + currentBladeReach * dx
    local y2 = playerY + currentBladeReach * dy

    return segmentIntersectsCircle(
        x1, y1, x2, y2,
        enemyX, enemyY,
        enemyRadius or self.thickness
    )
end
