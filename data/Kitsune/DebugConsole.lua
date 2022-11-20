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
    self.prompt = ""
    self.env = setmetatable({
        print=function(...)
            for _,i in ipairs(table.pack(...)) do
                table.insert(self.lines,i)
            end
        end
    },{__index=_G})
    self.instance = load(string.dump(function() return coroutine.create(function()
        while true do
            local prompt = coroutine.yield()
            
        end
    end) end),"debug_console","bt",self.env)()
    coroutine.resume(self.instance)
end

function DebugCon:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.statusBackground)
    local promptTextSize = ((self.size.w-24)//8)-2
    Renderer.Text(8,self.maxHeight-24,1,"> "..self.prompt:sub(math.max(1,#self.prompt-promptTextSize),#self.prompt),Theme.docText)
    if self.ticks % 48 < 24 then
        Renderer.Rect(8+(#("> "..self.prompt:sub(math.max(1,#self.prompt-promptTextSize),#self.prompt))*8),self.maxHeight-24,2,16,Theme.caret)
    end
    for i,j in ipairs(self.lines) do
        Renderer.Text(0,self.maxHeight-48-((i-1)*16),1,j,Theme.text)
    end
    Renderer.PopClipArea()
end

function DebugCon:tick()
    DebugCon.super.tick(self)
    self:move_to(self.size,self.destHeight,"h",0.3)
    if self.destHeight > 0 and self.maxHeight ~= self.destHeight then
        self.destHeight = self.maxHeight
    end
    if self.destHeight > 0 then
        self.ticks = (self.ticks + 1) % (48*2)
        if self.ticks % 24 == 0 then
            Core.Redraw = true
        end
    end
end

return DebugCon