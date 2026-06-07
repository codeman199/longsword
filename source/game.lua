local pd = playdate
local gfx = pd.graphics

import "scripts/logic/upgradeData"
import "scripts/logic/playerStats"
import "scripts/gameOverScene"

local totalGameTime <const> = 600000
local upgrades <const> = Upgrades
local unlocks <const> = Unlocks

class('Game').extends()

local function findInTable(table, name)
    for i = 1, #table do
        if table[i].name == name then
            return i
        end
    end
    return -1
end

function Game:init()
    self.sceneManager = SCENE_MANAGER
    self.curLevel = 1
    self.enemiesDefeated = 0
    self.time = totalGameTime
    self.upgrades = {}
    self.equipment = {}
    self.playerHealth = PlayerStats.maxHealth
    self:resetEquipmentAndUpgradeData()
    LevelScene(self, self.curLevel, self.time, self.playerHealth)
end

function Game:resetEquipmentAndUpgradeData()
    for i = 1, #unlocks do
        local unlockData = unlocks[i]
        if unlockData.isEquipment then
            --equipment[unlockData.name].level = 1
        else
            local upgradeData = upgrades[unlockData.name]
            upgradeData.level = unlockData.level
            if unlockData.level ~= 0 then
                table.insert(self.upgrades, upgradeData)
            end
        end
    end
end

function Game:playerDied(enemiesDefeated)
    self.enemiesDefeated += enemiesDefeated
    self.sceneManager:switchScene(GameOverScene, self.enemiesDefeated)
end
