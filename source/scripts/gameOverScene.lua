local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameOverScene').extends(gfx.sprite)

function GameOverScene:init(enemiesDefeated)
    TOTAL_DEATHS += 1
    self.selectedUpgrade = math.ceil(1)

    local blackImage = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.sprite.setBackgroundDrawingCallback(function()
        blackImage:draw(0, 0)
    end)

    local splashDeathImage = gfx.image.new("images/death_screen")
    local splashSprite = gfx.sprite.new(splashDeathImage)
    splashSprite:setCenter(0, 0)
    splashSprite:moveTo(0, 0)
    splashSprite:add()

    --self.menuMoveSound = SfxPlayer("sfx-menu-move")
    self:add()
end

function GameOverScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        SCENE_MANAGER:switchScene(TitleScene)
    end
end
