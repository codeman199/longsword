class('SwingSpeed').extends()

function SwingSpeed:init(sword, data)
    local calculatedValue = data.value + (data.level - 1) * data.scaling
    sword.SwingSpeed += calculatedValue
end
