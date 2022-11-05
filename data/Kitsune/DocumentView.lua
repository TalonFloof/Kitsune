local Element = require "Kitsune.Element"

local DocumentView = Element:extend()

function DocumentView:new(doc)
    DocumentView.super.new(self)
    self.cursor = "Caret"
    self.document = doc
end

function DocumentView:getLineRange()
    local x = self.pos.x
    local y = self.pos.y-self.scrollPos.y
    local minimum = math.max(1, math.floor(y / 16))
    local maximum = math.min(#self.doc.lines)
end

function DocumentView:draw()
    self:drawBackground(0x34,0x32,0x33,255)
end

return DocumentView