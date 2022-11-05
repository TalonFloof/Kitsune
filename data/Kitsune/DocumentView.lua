local Element = require "Kitsune.Element"

local DocumentView = Element:extend()

function DocumentView:new(doc)
    DocumentView.super.new(self)
    self.cursor = "Caret"
    if doc ~= nil then
        local lineIterator = io.lines(doc)
        local retValue = {lines={},path=doc}
        for i in lineIterator do
            table.insert(retValue.lines,i)
        end
        self.document = retValue
    else
        self.document = nil
    end
end

function DocumentView:getLineRange()
    local y = self.scrollPos.y
    local minimum = math.max(1, math.floor(y / 16))
    local maximum = math.min(#self.document.lines,math.floor((y+self.size.h) / 16) + 1)
    return minimum, maximum
end

function DocumentView:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x34,0x32,0x33,255)
    local min, max = self:getLineRange()
    for i=min,max do
        Renderer.Text(0,((i-1)*16)-self.scrollPos.y,1,self.document.lines[i],255,255,255)
    end
    Renderer.PopClipArea()
end

function DocumentView:onMouseScroll(x,y,direction)
    if self:isWithinBounds(x,y) then
        self.scrollPos.dest.y = math.max(0,self.scrollPos.dest.y + direction * (-50 * SCALE))
    end
end

return DocumentView