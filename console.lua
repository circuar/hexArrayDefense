local api = require "api"
local console = {
    sizeX = 10,
    sizeY = 10,

    buffer = ""
}

function  console.out(text)
    
end

function console.clear()
    console.buffer = ""
    console.flush()
end

function console.newLine(line)
    
end

function console.flush()
    api.setUILabelText(Player, "1519736575|1335340132", console.buffer)
end

return console
