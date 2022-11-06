local Element = require "Kitsune.Element"
local Core = require "Kitsune"

local CommandBar = Element:extend()

function CommandBar:new()
    CommandBar.super.new(self)
    self.sourceY = 0
    self.destHeight = 0
    self.ticks = 0
    self.prompt = ""
end

function CommandBar:tick()
    CommandBar.super.tick(self)
    self:move_to(self.size,self.destHeight,"h",0.3)
    self:move_to(self.pos,self.sourceY-self.destHeight,"y",0.3)
    if self.size.h > 0 then
        if self.ticks % 30 == 0 then
            Core.Redraw = true
        end
        self.ticks = self.ticks + 1
    else
        self.ticks = 0
    end
end

function CommandBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x34,0x32,0x33,255)
    Renderer.Text(8,self.pos.y+(self.size.h/2-8),1,"Run Command: "..self.prompt,255,255,255)
    Renderer.Rect(self.pos.x,self.pos.y,self.size.w,1,0x24,0x22,0x23,255)
    if self.ticks % 60 < 30 then
        Renderer.Rect(8+(#("Run Command: "..self.prompt)*8),self.pos.y+(self.size.h/2-8),2,16,0x61,0xef,0xce,255)
    end
    Renderer.PopClipArea()
end

function CommandBar:onKeyPress(k)
    if self.destHeight > 0 then
        if k == "escape" then
            self.destHeight = 0
            self.prompt = ""
        elseif k == "backspace" then
            self.prompt = self.prompt:sub(1,#self.prompt-1)
            Core.Redraw = true
        end
    end
end

function CommandBar:onMouseDown(button,x,y,clicks)
    if y < self.pos.y+self.size.h and not self:isWithinBounds(x,y) then
        self.destHeight = 0
    end
end

function CommandBar:onTextType(text)
    if self.destHeight > 0 then
        self.prompt = self.prompt .. text
        Core.Redraw = true
    end
end

return CommandBar