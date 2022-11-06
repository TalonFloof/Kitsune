local Element = require "Kitsune.Element"
local Core = require "Kitsune"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
    self.alertText = ""
    self.alertTimer = 0
end

function StatusBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x2c,0x2a,0x2b,255)
    Renderer.Image("Kitsune:LogoSymbolic",0,self.pos.y-self.scrollPos.y,32,32)
    if Core.DocumentView.document ~= nil then
        local maxLength = ((self.size.w/2)-40)//8
        local name = Core.DocumentView.document.path or "unnamed"
        if #name > maxLength then
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"..."..name:sub(#name-maxLength+3,#name),0xc4,0xb3,0x98)
        else
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,name,0xc4,0xb3,0x98)
        end
        Renderer.Text(40,self.pos.y-self.scrollPos.y+16,1,"line: "..tostring(Core.DocumentView.caretPos.y).." col: "..tostring(Core.DocumentView.caretPos.x).." "..string.format("%d%%", Core.DocumentView.caretPos.y / #Core.DocumentView.document.lines * 100),0xc4,0xb3,0x98)
    else
        Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"No buffer",0xc4,0xb3,0x98)
    end
    if self.alertTimer > 0 then
        local maxLength = (self.size.w-24)//8
        if #self.alertText > maxLength then
            Renderer.Text(8,self.pos.y-24-self.scrollPos.y,1,"..."..self.alertText:sub(#self.alertText-maxLength+3,#self.alertText),0xc4,0xb3,0x98)
        else
            Renderer.Text(8,self.pos.y-24-self.scrollPos.y,1,self.alertText,0xc4,0xb3,0x98)
        end
    end
    Renderer.Text(8,self.pos.y+40-self.scrollPos.y,1,"No tabs",0xc4,0xb3,0x98)
    Renderer.PopClipArea()
end

function StatusBar:tick()
    StatusBar.super.tick(self)
    if self.alertTimer > 0 then
        self.alertTimer = self.alertTimer - 1
        if self.alertTimer == 0 then
            if self:isWithinBounds(Core.MousePos.x,Core.MousePos.y) then
                self.scrollPos.dest.y = 32
            else
                self.scrollPos.dest.y = 0
            end
        end
    end
end

function StatusBar:displayAlert(msg)
    self.alertTimer = 60*5
    self.alertText = msg
    self.scrollPos.dest.y = -32
end

function StatusBar:onMouseMove(x,y)
    StatusBar.super.onMouseMove(self,x,y)
    if self:isWithinBounds(x,y) and self.alertTimer <= 0 then
        self.scrollPos.dest.y = 32
    elseif self.alertTimer <= 0 then
        self.scrollPos.dest.y = 0
    end
end

return StatusBar