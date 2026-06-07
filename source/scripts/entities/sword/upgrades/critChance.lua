class('CritChance').extends()

function CritChance:init(sword, data)
    local calculatedValue = data.value + (data.level - 1) * data.scaling
    sword.CritChance += calculatedValue
end
