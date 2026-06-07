COLLISION_GROUPS = {
    PLAYER = 1,
    SWORD = 2,
    ENEMY = 3,
    PROJECTILE = 4,
    WALL = 5,
}

Z_INDEXES = {
    UI = 32766,
    PLAYER = 100,
    SWORD = 90,
}

TAGS = {
    PLAYER = 1,
    ENEMY = 2,
    WALL = 3,
}

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "CoreLibs/animation"
import "CoreLibs/crank"
import "CoreLibs/ui"
import "CoreLibs/utilities/sampler"
import "scripts/libraries/SceneManager"

import "scripts/levelScene"
import "scripts/logic/storedDataManager"
import "scripts/title/titleScene"
import "game"

local pd = playdate
local gfx = pd.graphics

SCENE_MANAGER = SceneManager()


TitleScene()

local spriteUpdate <const> = gfx.sprite.update
local timerUpdate <const> = pd.timer.updateTimers
local drawFPS <const> = pd.drawFPS

gfx.setColor(gfx.kColorWhite)

function pd.update()
    gfx.clear()

    spriteUpdate()

    timerUpdate()

    drawFPS(5, 225)
end
