class('Length').extends()

function Length:init(sword, data)
    local calculatedValue = data.value + (data.level - 1) * data.scaling
    sword.Length += calculatedValue
end
