class('CritDamage').extends()

function CritDamage:init(sword, data)
    local calculatedValue = data.value + (data.level - 1) * data.scaling
    sword.CritDamage += calculatedValue
end
