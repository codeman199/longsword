import "scripts/entities/player/player"
import "scripts/entities/sword/sword"
import "scripts/entities/enemies/goblin"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('LevelScene').extends(gfx.sprite)

function LevelScene:init(game, curLevel, time, playerHealth)
    self.game = game
    self.curLevel = curLevel
    self.playerHealth = playerHealth

    -- TODO: Calculate level experience scaling
    --local levelExperience = 6 + curLevel * 6 + math.max(0, (curLevel - 7) * 12) + math.max(0, (curLevel - 4) * 6)
    --self.hud = HUD(time, levelExperience, self)
    self:setupLevelLayout()
    self:setupEnemySpawner()

    --self.levelAnimatingOut = false

    self.playerDead = false

    self:add()
end

function LevelScene:update()
    --self.player:update()
    --self.sword:update(self.player.x, self.player.y)
    -- TODO: Add wave progress logic here

    --if self.canDig and not self.playerDead then
    --    self.digSprite:setImage(self.digSpriteAnimation:image())
    --    if pd.buttonJustPressed(pd.kButtonDown) and not self.levelAnimatingOut then
    --        self.levelAnimatingOut = true
    --        self.player:levelDefeated()
    --        self.hud:stopTimer()
    --    end
    --end

    -- LEVEL SKIP
    -- if pd.buttonIsPressed(pd.kButtonB) then
    --     self.levelAnimatingOut = true
    --     self.player:levelDefeated()
    --     self.hud:stopTimer()
    -- end
end

function LevelScene:setupLevelLayout()
    --self.mapGenerator = MapGenerator()

    local spawnX = 180
    local spawnY = 120
    self.player = Player(spawnX, spawnY, self.playerHealth, self.game, self)
    self.sword = Sword(spawnX, spawnY, self.game, self)

    self.player.sword = self.sword
    self.sword.player = self.player
end

function LevelScene:setupEnemySpawner()
    self.enemyCount = 0
    self.maxEnemies = math.min(2 + self.curLevel * 2, 10)
    self.maxEnemies = 100
    self.enemiesDefeated = 0

    local levelStartDelay = 40

    pd.timer.performAfterDelay(levelStartDelay, function()
        local spawnTimer = pd.timer.new(math.max(1000, 3000 - self.curLevel * 10), function()
            if self.enemyCount >= self.maxEnemies then
                return
            end
            self.enemyCount += 1
            local RandEnemy = Goblin --self:getRandomEnemy()
            local spawnX = self.player.x
            local spawnY = self.player.y

            -- Spawn from random edge
            local side = math.random(1, 4)

            if side == 1 then
                -- Left
                spawnX += -240
                spawnY += math.random(0, 280)
            elseif side == 2 then
                -- Right
                spawnX += 240
                spawnY += math.random(0, 180)
            elseif side == 3 then
                -- Top
                spawnX += math.random(0, 140)
                spawnY += -180
            else
                -- Bottom
                spawnX += math.random(0, 240)
                spawnY += 180
            end

            RandEnemy(spawnX, spawnY, self)
        end)
        spawnTimer.repeats = true
    end)
end

function LevelScene:getRandomEnemy()
    local probabilityWeightTotal = 0
    for _, probabilityObject in ipairs(self.spawnProbabilities) do
        probabilityWeightTotal += probabilityObject[1]
    end

    local probablitySum = 0
    local randNum = math.random() * probabilityWeightTotal
    for _, probabilityObject in ipairs(self.spawnProbabilities) do
        probablitySum += probabilityObject[1]
        if randNum <= probablitySum then
            return probabilityObject[2]
        end
    end
end

function LevelScene:enemyDied(experience)
    self.enemyCount -= 1
    if experience > 0 then
        self.enemiesDefeated += 1
    end
    --self.hud:addExperience(experience)
end

function LevelScene:levelDefeated(playerHealth)
    local time = self.hud:getTimeLeft()
    self.game:levelDefeated(time, self.enemiesDefeated, playerHealth)
end

function LevelScene:playerDied()
    self.playerDead = true
    self.game:playerDied(self.enemiesDefeated)
end
