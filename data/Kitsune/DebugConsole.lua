local Element = require "Kitsune.Element"
local Core = require "Kitsune"
local Theme = require "Kitsune.Theme"

local DebugCon = Element:extend()

function DebugCon:new()
    DebugCon.super.new(self)
    self.destHeight = 0
    self.maxHeight = 0
    self.lines = {}
    self.pos = {x=0,y=0}
    self.ticks = 0
end

function DebugCon:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.statusBackground)
    Renderer.Text(8,self.size.h-24,1,"> ",Theme.docText)
    Renderer.PopClipArea()
end

function DebugCon:tick()
    DebugCon.super.tick(self)
    self:move_to(self.size,self.destHeight,"h",0.3)
    if self.destHeight > 0 and self.maxHeight ~= self.destHeight then
        self.destHeight = self.maxHeight
    end
end

return DebugCon