import "game"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('TitleScene').extends(gfx.sprite)

function TitleScene:init()
    local backgroundImage = gfx.image.new("images/main-menu-title")
    self:setImage(backgroundImage)
    self:moveTo(200, 120)
    self:add()
end

function TitleScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then SCENE_MANAGER:switchScene(Game) end
end
