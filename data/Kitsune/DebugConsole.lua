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
    self:ResetInstance()
end

function DebugCon:ResetInstance()
    self.env = nil
    self.env = setmetatable({
        print=function(...)
            local toStringTable = table.pack(...)
            for i=1,#toStringTable do
                toStringTable[i] = tostring(toStringTable[i])
            end
            for i in string.gmatch(table.concat(toStringTable,"    "),"([^\n]+)") do
                for j=1,math.ceil((#i*8)/self.size.w) do
                    local base = ((j-1)*(self.size.w//8))+1
                    table.insert(self.lines,1,i:sub(base,base+(self.size.w//8)))
                end
            end
        end
    },{__index=_G})
    self.instance = load(string.dump(function() return coroutine.create(function(env)
        while true do
            local prompt = coroutine.yield()
            print("> "..prompt)
            xpcall(function()
                local result, err = load(prompt,"debug_console_prompt","bt",env)
                if not result then
                    print(err)
                else
                    local output = table.pack(result())
                    if #output > 0 then
                        print("=>",table.unpack(output))
                    end
                end
            end,function(e)
                io.stderr:write("Internal Error "..e.."\n")
                io.stderr:flush()
                print("Internal Error: "..e)
            end)
        end
    end) end),"debug_console","bt",self.env)()
    coroutine.resume(self.instance,self.env)
end

function DebugCon:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.statusBackground)
    local promptTextSize = ((self.size.w-24)//8)-2
    Renderer.Text(8,self.maxHeight-24,1,"> "..self.prompt:sub(math.max(1,#self.prompt-promptTextSize),#self.prompt),Theme.docText)
    if self.ticks % 48 < 24 then
        Renderer.Rect(8+(#("> "..self.prompt:sub(math.max(1,#self.prompt-promptTextSize),#self.prompt))*8),self.maxHeight-24,2,16,Theme.caret)
    end
    local num = -1
    for i,j in ipairs(self.lines) do
        if self.maxHeight-48-((i-1)*16) < 0 then num = i break end
        Renderer.Text(0,self.maxHeight-48-((i-1)*16),1,j,Theme.text)
    end
    if num ~= -1 then while #self.lines >= num do table.remove(self.lines,num) end end
    Renderer.PopClipArea()
end

function DebugCon:onKeyPress(k)
    if self.destHeight > 0 then
        if k == "backspace" then
            self.prompt = self.prompt:sub(1,#self.prompt-1)
            self.ticks = 0
            Core.Redraw = true
        elseif k == "return" then
            coroutine.resume(self.instance,self.prompt)
            self.prompt = ""
            self.ticks = 0
            Core.Redraw = true
        end
    end
end

function DebugCon:onTextType(k)
    if self.destHeight > 0 then
        self.prompt = self.prompt .. k
        self.ticks = 0
        Core.Redraw = true
    end
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