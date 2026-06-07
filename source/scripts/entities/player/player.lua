import "scripts/libraries/AnimatedSprite"
import "scripts/entities/player/healthBar"
import "scripts/logic/playerStats"

local pd = playdate
local gfx = pd.graphics

local getDrawOffset <const> = gfx.getDrawOffset
local setDrawOffset <const> = gfx.setDrawOffset

local hurtboxXOffset, hurtboxYOffset
local hurtboxWidth
local hurtboxHeight
local hurtboxHalfWidth
local hurtboxHalfHeight

local querySpritesInRect <const> = gfx.sprite.querySpritesInRect

local playerStats <const> = PlayerStats
class('Player').extends(gfx.sprite)

local playerStates <const> = {
    active = 1,
    inactive = 2
}

function Player:init(x, y, health, game, levelScene)
    self.game = game
    self.levelScene = levelScene

    -- Player Stats
    self.maxVelocity = playerStats.maxVelocity
    self.maxHealth = playerStats.maxHealth
    self.health = playerStats.maxHealth
    self.healthRegen = 0
    self.restoration = 0


    -- Health tracking
    local healthbar <const>   = Healthbar(self)
    self.healthbar            = healthbar
    self.flashTime            = 100
    self.invincible           = false

    local healthRegenTickRate = 500
    local healthRegen <const> = self.healthRegen
    local healthRegenTimer    = pd.timer.new(healthRegenTickRate, function()
        self:heal(healthRegen)
    end)
    healthRegenTimer.repeats  = true


    -- Animation logic
    local playerSpriteSheet       = gfx.imagetable.new("images/knight")

    self.animationLoop            = gfx.animation.loop.new(200, playerSpriteSheet, true)
    self.direction                = "down" -- default facing
    self.isMoving                 = false

    -- Define animation row start frames (1-indexed,4 frames each)
    self.animFrames               = {
        right = 1,
        left  = 5,
        up    = 9,
        down  = 13,
    }

    self.animationLoop.startFrame = 13
    self.animationLoop.endFrame   = 13

    self:setImage(playerSpriteSheet[self.animationLoop.startFrame])
    self:add()

    self:setZIndex(Z_INDEXES.PLAYER)

    self.velocity = 0
    self.xVelocity = 0
    self.yVelocity = 0

    self:moveTo(x, y)
    setDrawOffset(-(x - 200), -(y - 120))

    -- Hitbox/Collisions
    self:setGroups(COLLISION_GROUPS.PLAYER)
    self:setCollidesWithGroups(COLLISION_GROUPS.WALL)
    self:setCollideRect(0, 0, self:getSize())
    self.collisionResponse = "slide"
    self:setTag(TAGS.PLAYER)

    local playerWidth, playerHeight = self:getSize()
    local hurtboxWidthBuffer = 8
    local hurtboxHeightBuffer = 8
    local xOffset, yOffset = 12, 12
    hurtboxWidth = playerWidth - hurtboxWidthBuffer * 2
    hurtboxHeight = playerHeight - hurtboxHeightBuffer * 2
    hurtboxHalfWidth = hurtboxWidth / 2
    hurtboxHalfHeight = hurtboxHeight / 2
    hurtboxXOffset = hurtboxHalfWidth - xOffset
    hurtboxYOffset = hurtboxHalfHeight - yOffset
    self.hurtboxWidth = hurtboxWidth
    self.hurtboxHeight = hurtboxHeight
    self.hurtboxHalfWidth = hurtboxHalfWidth
    self.hurtboxHalfHeight = hurtboxHalfHeight
    self.hurtboxXOffset = hurtboxXOffset
    self.hurtboxYOffset = hurtboxYOffset

    self.enemyTag = TAGS.ENEMY

    -- Screen shake logic
    -- FIXME: Current has a bug that causes the pd display to get offset by a few pixels in the x and y directions
    self.shakeTimer = pd.timer.new(500, 5, 0)
    self.shakeTimer:pause()
    self.shakeTimer.timerEndedCallback = function(timer)
        pd.display.setOffset(0, 0)
        timer:reset()
        timer:pause()
    end
    self.shakeTimer.updateCallback = function(timer)
        local shakeAmount = timer.value
        local shakeAngle = math.random() * math.pi * 2;
        local shakeX = math.floor(math.cos(shakeAngle) * shakeAmount);
        local shakeY = math.floor(math.sin(shakeAngle) * shakeAmount);
        pd.display.setOffset(shakeX, shakeY)
    end
    self.shakeTimer.discardOnCompletion = false
end

function Player:screenShake()
    if self.shakeTimer.paused then
        self.shakeTimer:start()
    end
end

function Player:update()
    -- Check if dead
    if self.playerState == playerStates.inactive then
        return
    end

    local playerX, playerY = self.x, self.y

    self:setZIndex(self.y)

    self:updateMovement()

    self:setImage(self.animationLoop:image())

    local drawOffsetX, drawOffsetY = getDrawOffset()
    local targetOffsetX, targetOffsetY = -(playerX - 200), -(playerY - 120)
    --local smoothedX = lerp(drawOffsetX, targetOffsetX, smoothSpeed)
    --local smoothedY = lerp(drawOffsetY, targetOffsetY, smoothSpeed)
    setDrawOffset(targetOffsetX, targetOffsetY)

    -- Check if being damaged by enemies
    local queryX = playerX - hurtboxXOffset
    local queryY = playerY - hurtboxYOffset
    local overlappingSprites = querySpritesInRect(queryX, queryY, hurtboxWidth, hurtboxHeight)
    for i = 1, #overlappingSprites do
        local enemy = overlappingSprites[i]
        if enemy:getTag() == self.enemyTag and enemy:canAttack() then
            self:damage(enemy.attackDamage)
            enemy:setAttackCooldown()
        end
    end
end

function Player:updateMovement()
    local dx, dy = 0, 0
    local swordX, swordY = self.sword.hiltSprite.x, self.sword.hiltSprite.y

    if pd.buttonIsPressed(pd.kButtonUp) then dy = -self.maxVelocity end
    if pd.buttonIsPressed(pd.kButtonDown) then dy = self.maxVelocity end
    if pd.buttonIsPressed(pd.kButtonRight) then dx = self.maxVelocity end
    if pd.buttonIsPressed(pd.kButtonLeft) then dx = -self.maxVelocity end

    local swordPlayerDiffX = swordX - self.x
    local swordPlayerDiffY = swordY - self.y

    local newDir = self.direction
    if math.abs(swordPlayerDiffX) > math.abs(swordPlayerDiffY) then
        newDir = swordPlayerDiffX > 0 and "right" or "left"
    else
        newDir = swordPlayerDiffY > 0 and "down" or "up"
    end

    local moving        = dx ~= 0 or dy ~= 0

    local dirChanged    = newDir ~= self.direction
    local movingChanged = moving ~= self.isMoving

    self.direction      = newDir
    self.isMoving       = moving

    -- Only update animation loop when direction or moving state changes
    if dirChanged or movingChanged then
        local startFrame = self.animFrames[newDir]
        if moving then
            self.animationLoop.startFrame = startFrame
            self.animationLoop.endFrame   = startFrame + 3
        else
            self.animationLoop.startFrame = startFrame
            self.animationLoop.endFrame   = startFrame -- freeze on first frame
        end
    end

    if moving then
        self:moveBy(dx, dy)
    end
end

function Player:damage(amount)
    if self.invincible then
        return
    end

    self:screenShake()
    --self.musicPlayer:duck(700)
    --self.damageSound:play()
    self.health -= amount

    if self.health <= 0 then
        self.health = 0
    end

    if self:isDead() then
        self.invincible = true
        --self.deathSound:play()
        self.levelScene:playerDied()
        -- TODO: Player death animation
        --self:removeActivePlayerElements()
        self.playerState = playerStates.inactive
    end

    self:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.healthbar:setFillWhite(true)
    pd.timer.new(self.flashTime, function()
        self:setImageDrawMode(gfx.kDrawModeCopy)
        self.healthbar:setFillWhite(false)
    end)
end

function Player:isDead()
    return self.health <= 0
end

function Player:heal(amount)
    self.health += amount
    if self.health >= self.maxHealth then
        self.health = self.maxHealth
    end
    self.healthbar:updateBarImage()
end
