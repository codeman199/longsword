local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Healthbar').extends(gfx.sprite)

function Healthbar:init(player)
    self.player = player

    self:setZIndex(Z_INDEXES.UI)
    self:add()

    -- Drawing
    self.drawHeight = 6
    self.maxDrawWidth = 30
    self.drawWidth = self.maxDrawWidth

    self.drawOffset = 25
end

function Healthbar:update()
    local drawX, drawY = self.player.x, self.player.y + self.drawOffset
    self:moveTo(drawX, drawY)
end

function Healthbar:getHealth()
    return self.player.health
end

function Healthbar:getMaxHealth()
    return self.player.maxHealth
end

function Healthbar:updateBarImage()
    local barImage = gfx.image.new(self.maxDrawWidth, self.drawHeight)
    self.drawWidth = (self.player.health / self.player.maxHealth) * self.maxDrawWidth
    gfx.pushContext(barImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, self.maxDrawWidth, self.drawHeight)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(0, 0, self.maxDrawWidth, self.drawHeight)
    gfx.fillRect(0, 0, self.drawWidth, self.drawHeight)
    gfx.popContext()
    self:setImage(barImage)
end

function Healthbar:setFillWhite(flag)
    if flag then
        self:setImageDrawMode(gfx.kDrawModeFillWhite)
    else
        self:setImageDrawMode(gfx.kDrawModeCopy)
    end
end
