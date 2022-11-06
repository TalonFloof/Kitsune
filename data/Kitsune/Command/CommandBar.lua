local Element = require "Kitsune.Element"
local Core = require "Kitsune"

local CommandBar = Element:extend()

function CommandBar:new()
    CommandBar.super.new(self)
end

function CommandBar:tick()
    CommandBar.super.tick(self)
end

function CommandBar:draw()

end

return CommandBar