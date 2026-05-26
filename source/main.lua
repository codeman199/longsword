import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd = playdate
local gfx = pd.graphics

local game = import "game"

function pd.update()
    gfx.clear()

    gfx.sprite.update()

    game.update()

    game.drawUI()
end
