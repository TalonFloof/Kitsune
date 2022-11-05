local Element = require "Kitsune.Element"

local DocumentView = Element:extend()

function DocumentView:new()
    DocumentView.super.new(self)
    self.cursor = "Caret"
end

function DocumentView:draw()
    self:drawBackground(0x34,0x32,0x33,255)
end

return DocumentView