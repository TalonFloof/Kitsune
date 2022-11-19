local Element = require "Kitsune.Element"
local Core = require "Kitsune"
local Theme = require "Kitsune.Theme"

local CommandBar = Element:extend()

function CommandBar:new()
    CommandBar.super.new(self)
    self.sourceY = 0
    self.destHeight = 0
    self.ticks = 0
    self.prompt = ""
    self.suggestMethod = nil
    self.action = nil
    self.currentChange = -1
    self.lastChange = 0
    self.suggestions = {}
    self.suggestionIndex = 1
    self.promptMsg = ""
end

function CommandBar:tick()
    CommandBar.super.tick(self)
    self:move_to(self.size,self.destHeight,"h",0.3)
    self:move_to(self.pos,self.sourceY-self.destHeight,"y",0.3)
    if self.size.h > 0 then
        if self.currentChange ~= self.lastChange and self.size.h >= 32 then
            local result = self.suggestMethod(self.prompt)
            self.suggestions = {}
            for i,j in ipairs(result) do
                if i > 10 then
                    break
                end
                self.suggestions[i] = j
            end
            table.sort(self.suggestions, function(a,b) return a.score < b.score end)
            self.destHeight = 32+((#self.suggestions)*16)
            self.lastChange = self.currentChange
        end
        if self.ticks % 24 == 0 then
            Core.Redraw = true
        end
        self.ticks = self.ticks + 1
    else
        self.ticks = 0
    end
end

function CommandBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.commandBackground)
    Renderer.Rect(self.pos.x,self.pos.y+self.size.h-31,self.size.w,31,Theme.docBackground)
    Renderer.Text(8,self.pos.y+self.size.h-(math.min(32,self.size.h)/2+8),1,self.promptMsg..self.prompt,Theme.docText)
    if self.ticks % 48 < 24 then
        Renderer.Rect(8+(#(self.promptMsg..self.prompt)*8),self.pos.y+self.size.h-(math.min(32,self.size.h)/2+8),2,16,Theme.caret)
    end
    local maxLength = math.floor(self.size.w*.75)//8
    for i,j in ipairs(self.suggestions) do
        if #self.suggestions-(self.suggestionIndex-1) == i then
            Renderer.Rect(0,self.pos.y+((i-1)*16),self.size.w,16,Theme.commandHighlight)
        end
        if #j.text > maxLength then
            Renderer.Text(0,self.pos.y+((i-1)*16),1,"..."..j.text:sub(#j.text-maxLength+3,#j.text),Theme.text)
        else
            Renderer.Text(0,self.pos.y+((i-1)*16),1,j.text,Theme.text)
        end
        local str = j.keybind or ""
        Renderer.Text(self.size.w-(#str*8),self.pos.y+((i-1)*16),1,str,Theme.dimText)
    end
    Renderer.PopClipArea()
end

function CommandBar:createPrompt(prompt, action, suggests)
    self.promptMsg = prompt..": "
    self.action = action
    self.suggestMethod = suggests
    self.destHeight = 32
    self.prompt = ""
    self.currentChange = -1
    self.lastChange = 0
    self.suggestions = {}
    self.suggestionIndex = 1
    Core.Redraw = true
end

function CommandBar:onKeyPress(k)
    if self.destHeight > 0 then
        if k == "escape" then
            self.destHeight = 0
            self.action = nil
            self.suggestMethod = nil
            self.lastChange = 0
            self.currentChange = 0
            self.suggestions = {}
            self.suggestionIndex = 1
            Core.Redraw = true
        elseif k == "backspace" then
            self.prompt = self.prompt:sub(1,#self.prompt-1)
            self.currentChange = self.currentChange + 1
            self.suggestionIndex = 1
            Core.Redraw = true
        elseif k == "return" then
            self.destHeight = 0
            self.suggestMethod = nil
            self.lastChange = 0
            self.currentChange = 0
            self.action(self.prompt,self.suggestions[#self.suggestions-(self.suggestionIndex-1)])
            self.suggestions = {}
            self.suggestionIndex = 1
            Core.Redraw = true
        elseif k == "up" then
            self.suggestionIndex = math.max(1,math.min(#self.suggestions,self.suggestionIndex+1))
            if self.suggestions[#self.suggestions-(self.suggestionIndex-1)] then
                self.prompt = self.suggestions[#self.suggestions-(self.suggestionIndex-1)].text
            end
            Core.Redraw = true
        elseif k == "down" then
            self.suggestionIndex = math.max(1,self.suggestionIndex-1)
            if self.suggestions[#self.suggestions-(self.suggestionIndex-1)] then
                self.prompt = self.suggestions[#self.suggestions-(self.suggestionIndex-1)].text
            end
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
        self.currentChange = self.currentChange + 1
        self.suggestionIndex = 1
        Core.Redraw = true
    end
end

return CommandBar