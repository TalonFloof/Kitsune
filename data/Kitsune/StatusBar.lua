local Element = require "Kitsune.Element"
local Core = require "Kitsune"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
end

function StatusBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x2c,0x2a,0x2b,255)
    Renderer.Image("Kitsune:LogoSymbolic",0,self.pos.y-self.scrollPos.y,32,32)
    if Core.DocumentView.document ~= nil then
        local maxLength = ((self.size.w/2)-40)//8
        if(#Core.DocumentView.document.path > maxLength) then
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"..."..Core.DocumentView.document.path:sub(#Core.DocumentView.document.path-maxLength+3,#Core.DocumentView.document.path),0xc4,0xb3,0x98)
        else
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,Core.DocumentView.document.path,0xc4,0xb3,0x98)
        end
    else
        Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"No buffer",0xc4,0xb3,0x98)
    end
    Renderer.Text(8,self.pos.y+40-self.scrollPos.y,1,"No tabs",0xc4,0xb3,0x98)
    Renderer.PopClipArea()
end

function StatusBar:onMouseMove(x,y)
    StatusBar.super.onMouseMove(self,x,y)
    if self:isWithinBounds(x,y) then
        self.scrollPos.dest.y = 32
    else
        self.scrollPos.dest.y = 0
    end
end

return StatusBar