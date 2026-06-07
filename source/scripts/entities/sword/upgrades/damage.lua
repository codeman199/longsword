class('Damage').extends()

function Damage:init(sword, data)
    local calculatedValue = data.value + (data.level - 1) * data.scaling
    sword.PercentDamage += calculatedValue
end
