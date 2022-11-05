local Element = require "Kitsune.Element"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
end

function StatusBar:draw()
    self:drawBackground(0x2c,0x2a,0x2b,255)
    Renderer.Text(8,self.pos.y+8,1,"Kitsune",0xc4,0xb3,0x98)
end

return StatusBar