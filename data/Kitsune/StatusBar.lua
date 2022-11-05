local Element = require "Kitsune.Element"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
end

function StatusBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x2c,0x2a,0x2b,255)
    Renderer.Image("Kitsune:LogoSymbolic",0,self.pos.y-self.scrollPos.y,32,32)
    Renderer.PopClipArea()
end

function StatusBar:onMouseMove(x,y)
    StatusBar.super.onMouseMove(self,x,y)
    if x >= self.pos.x and x <= self.pos.x+self.size.w and y >= self.pos.y and y <= self.pos.y+self.size.h then
        self.scrollPos.dest.y = self.size.h
    else
        self.scrollPos.dest.y = 0
    end
end

return StatusBar