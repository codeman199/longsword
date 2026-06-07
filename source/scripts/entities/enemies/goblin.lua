import "scripts/entities/enemies/enemy"
import "scripts/logic/enemyStats"

local stats <const> = EnemyStats["goblin"]

class('Goblin').extends(Enemy)

function Goblin:init(x, y, level, spriteName)
    if not spriteName then
        spriteName = "goblin"
    end

    Goblin.super.init(self, x, y, level, spriteName)
    self.attackCooldown = stats.attackCooldown
    self.attackDamage = stats.attackDamage
    self.health = stats.health
    self.maxVelocity = stats.velocity
    self.resistance = stats.resistance

    self.experience = stats.experience
end
