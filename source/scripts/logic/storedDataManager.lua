import "scripts/logic/unlockData"

local pd <const> = playdate

TOTAL_DEATHS = 0
HIGH_SCORE = 0

function LoadGameData()
    local gameData = pd.datastore.read()
    if gameData then
        if gameData.unlocks then
            for i = 1, #Unlocks do
                local unlock = Unlocks[i]
                local gameDataUnlockLevel = FindUnlockLevel(gameData.unlocks, unlock)
                if gameDataUnlockLevel then
                    unlock.level = gameDataUnlockLevel
                end
            end
        end
        if gameData.totalDeaths then
            TOTAL_DEATHS = gameData.totalDeaths
        end
        if gameData.totalDeaths then
            HIGH_SCORE = gameData.highScore
        end
    end
end

function FindUnlockLevel(gameDataUnlocks, unlock)
    for i = 1, #gameDataUnlocks do
        local gameDataUnlock = gameDataUnlocks[i]
        if gameDataUnlock.name == unlock.name then
            return gameDataUnlock.level
        end
    end
end

function SaveGameData()
    local gameData = {
        unlocks = Unlocks,
        totalDeaths = TOTAL_DEATHS,
        highScore = HIGH_SCORE
    }
    pd.datastore.write(gameData)
end

function pd.gameWillTerminate()
    SaveGameData()
end

function pd.gameWillPause()
    SaveGameData()
end

LoadGameData()
