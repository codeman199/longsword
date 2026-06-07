import "scripts/libraries/AnimatedSprite"
import "scripts/entities/sword/sword"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local math <const> = math
local sqrt <const> = math.sqrt
local random <const> = math.random
local kImageUnflipped <const> = gfx.kImageUnflipped
local kImageFlippedX <const> = gfx.kImageFlippedX
local sfxPlayer <const> = SfxPlayer

-- Enemy Consts
local invincibilityTime <const> = 100
local directionUpdateInterval <const> = 60
local dieTimerMax <const> = 20


local enemySprites <const> = {
    --goblin = gfx.imagetable.new("images/goblin"),
    goblin = gfx.image.new("images/goblin"),
}

class('Enemy').extends(gfx.sprite)

function Enemy:init(x, y, levelScene, spriteName)
    local stats = EnemyStats[spriteName]
    self.spritesheet = enemySprites[spriteName]
    --self.animationLoopCount = 1
    --self.animationFrameTime = 6
    --self.animationFrame = 1
    --self.maxAnimationFrame = self.spritesheet:getLength()
    self:setImage(self.spritesheet)
    self:add()

    -- Stats
    self.attackCooldown = stats.attackCooldown
    self.attackDamage = stats.attackDamage
    self.health = stats.health
    self.experience = stats.experience
    self.coins = stats.coins
    self.experience = stats.experience
    self.velocity = stats.velocity
    self.hitRadius = 10

    self.hitStun = 0

    self.levelScene = levelScene

    self:setGroups(COLLISION_GROUPS.ENEMY)
    self:setCollideRect(0, 0, self:getSize())
    self.collisionResponse = "overlap"
    self:setTag(TAGS.ENEMY)

    self.playerTag = TAGS.PLAYER

    self.invincible = false

    self.player = self.levelScene.player
    self.sword = self.levelScene.sword

    self:moveTo(x, y)

    self.directionUpdateCount = 0
    self.randomMoveUpdateInterval = 40

    self.dieTimer = dieTimerMax

    self.imageFlip = kImageUnflipped

    self.attackOnCooldown = false

    --self.dieSound = sfxPlayer("sfx-enemy-death")
    --self.damageSound = sfxPlayer("sfx-enemy-damage")

    self.spriteWidth, self.spriteHeight = self:getSize()
end

function Enemy:update()
    local playerX, playerY = self.player.x, self.player.y
    local x, y = self.x, self.y

    if self.dieTimer < 0 then
        self:die()
        return
    end

    --local curImageFlip <const> = self.imageFlip

    --local animationLoopCount = self.animationLoopCount
    --animationLoopCount = animationLoopCount % self.animationFrameTime + 1
    --self.animationLoopCount = animationLoopCount
    --if animationLoopCount == 1 then
    --    local animationFrame = self.animationFrame % self.maxAnimationFrame + 1
    --    self.animationFrame = animationFrame
    --    self:setImage(self.spritesheet:getImage(animationFrame), curImageFlip)
    --    self:setZIndex(y)
    --end

    --self.hitStun -= 1
    --if self.hitStun <= 0 then
    --    self.hitStun = 0
    --else
    --    return
    --end

    local velocity = self.velocity

    local dx = playerX - x
    local dy = playerY - y

    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        self:moveBy(
            velocity * (dx / dist),
            velocity * (dy / dist)
        )
    end

    local hit = self.sword:checkCollision(playerX, playerY, self.x, self.y, self.hitRadius)

    if hit then
        self:damage(self.sword.damage, false)
    end
end

function Enemy:setAttackCooldown()
    self.attackOnCooldown = true
    pd.timer.new(self.attackCooldown, function()
        self.attackOnCooldown = false
    end)
end

function Enemy:canAttack()
    return not self.attackOnCooldown
end

function Enemy:damage(amount, hitStun)
    if hitStun and hitStun > self.hitStun then
        self.hitStun = hitStun * (1 - self.resistance)
    end

    if self.invincible == true then
        return
    end

    --self.damageSound:play()
    self.health -= amount
    if self.health <= 0 then
        self:die()
    end

    self:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.invincible = true
    pd.timer.new(invincibilityTime, function()
        self:setImageDrawMode(gfx.kDrawModeCopy)
        self.invincible = false
    end)
end

function Enemy:die()
    if self.health > 0 then
        self.levelScene:enemyDied(0)
    else
        --self.dieSound:play()
        self.levelScene:enemyDied(self.experience)
        self.sword:upgradeLength()
    end
    self:remove()
end
