local Element = require "KitsuneElement"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
end

function StatusBar:draw()
    self:drawBackground(0x2c,0x2a,0x2b,255)
    Renderer.Text(8,self.pos.y+8,1,"Kitsune",255,255,255)
end

return StatusBar