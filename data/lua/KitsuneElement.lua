local Core = require "KitsuneCore"
local Object = require "KitsuneObject"
local Utils = require "KitsuneUtil"

local Element = Object:extend()

function Element:new()
    self.pos = { x = 0, y = 0 }
    self.size = { w = 0, h = 0 }
    self.scrollPos = { x = 0, y = 0, dest = { x = 0, y = 0 } }
    self.isScrollable = false
end

function Element:move_to(originTable, destination, tableKey, speed)
    if math.abs(originTable[tableKey] - destination) < 0.5 then
        originTable[tableKey] = destination
    else
        originTable[tableKey] = Utils.lerp(originTable[tableKey], destination, speed)
    end
    if originTable[tableKey] ~= destination then
        Core.Redraw = true
    end
end

function Element:tick()
    self:move_to(self.scrollPos, self.scrollPos.dest.x, "x", 0.3)
    self:move_to(self.scrollPos, self.scrollPos.dest.y, "y", 0.3)
end

function Element:drawBackground(r,g,b,a)
    local x, y = self.pos.x, self.pos.y
    local w, h = self.size.w, self.size.h
    Renderer.Rect(x, y, w + x % 1, h + y % 1, r, g, b, a)
end

function Element:draw() end

return Element