local Element = require "Kitsune.Element"
local Core = require "Kitsune"
local Theme = require "Kitsune.Theme"
local EmptyView = require "Kitsune.EmptyView"

local StatusBar = Element:extend()

function StatusBar:new()
    StatusBar.super.new(self)
    self.size.h = 32
    self.alertText = ""
    self.alertTimer = 0
    self.tabs = {}
    self.currentTab = 1
    self.ticks = 0
    self.defaultView = EmptyView()
end

function StatusBar:OpenTab(name,element)
    element.size.w = table.pack(Applet.GetResolution())[1]
    element.size.h = table.pack(Applet.GetResolution())[2]-32
    table.insert(self.tabs,element)
    self.currentTab = #self.tabs
end

function StatusBar:CloseTab()
    table.remove(self.tabs,self.currentTab)
    self.currentTab = math.max(1,math.min(#self.tabs,self.currentTab))
end

function StatusBar:getCurrent()
    if #self.tabs == 0 then
        return self.defaultView
    else
        return self.tabs[self.currentTab]
    end
end

function StatusBar:resizeTabElement(x,y)
    for i,j in ipairs(self.tabs) do
        j.pos.x = 0
        j.pos.y = 0
        j.size.w = x
        j.size.h = y-32
    end
    self.defaultView.pos.x = 0
    self.defaultView.pos.y = 0
    self.defaultView.size.w = x
    self.defaultView.size.h = y-32
end

function StatusBar:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.statusBackground)
    Renderer.Image("Kitsune:LogoSymbolic",0,self.pos.y-self.scrollPos.y,32,32)
    if self:getCurrent().document ~= nil then
        local maxLength = ((self.size.w/2)-40)//8
        local name = self:getCurrent().document.path or "unnamed"
        if #name > maxLength then
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"..."..name:sub(#name-maxLength+3,#name)..(self:getCurrent().document.unsavedChanges and "*" or ""),Theme.text)
        else
            Renderer.Text(40,self.pos.y-self.scrollPos.y,1,name..(self:getCurrent().document.unsavedChanges and "*" or ""),Theme.text)
        end
        Renderer.Text(40,self.pos.y-self.scrollPos.y+16,1,"line: "..tostring(self:getCurrent().selection.to.y).." col: "..tostring(self:getCurrent().selection.to.x).." "..string.format("%d%%", math.floor(self:getCurrent().selection.to.y / #self:getCurrent().document.lines * 100)),Theme.text)
    else
        Renderer.Text(40,self.pos.y-self.scrollPos.y,1,"No buffer",Theme.text)
    end
    if self.alertTimer > 0 then
        local maxLength = (self.size.w-24)//8
        if #self.alertText > maxLength then
            Renderer.Text(8,self.pos.y-24-self.scrollPos.y,1,"..."..self.alertText:sub(#self.alertText-maxLength+3,#self.alertText),Theme.text)
        else
            Renderer.Text(8,self.pos.y-24-self.scrollPos.y,1,self.alertText,Theme.text)
        end
    end
    if #self.tabs == 0 then
        Renderer.Text(8,self.pos.y+40-self.scrollPos.y,1,"No tabs",Theme.text)
    else
        if self.scrollPos.dest.y > 0 then
            for i,j in ipairs(self.tabs) do
                local w = math.min(170, math.ceil(self.size.w / #self.tabs))
                local x = self.pos.x + (i-1) * w
                if i == self.currentTab then
                    Renderer.Rect(x,self.pos.y+32-self.scrollPos.y,w,32,Theme.highlight)
                end
                Renderer.Text(x+(w/2)-((#j:getName()*8)//2),self.pos.y+40-self.scrollPos.y,1,j:getName(),Theme.text)
            end
        end
    end
    Renderer.PopClipArea()
    self:getCurrent():draw()
end

function StatusBar:tick()
    StatusBar.super.tick(self)
    if self.alertTimer > 0 then
        self.alertTimer = self.alertTimer - 1
        if self.alertTimer == 0 then
            if self:isWithinBounds(Core.MousePos.x,Core.MousePos.y) and Applet.IsFocused() then
                self.scrollPos.dest.y = 32
            else
                self.scrollPos.dest.y = 0
            end
        end
    elseif self.scrollPos.dest.y == 32 and not Applet.IsFocused() then
        if self.alertTimer <= 0 then
            self.scrollPos.dest.y = 0
        end
    end
    self.ticks = self.ticks + 1
end

function StatusBar:displayAlert(msg)
    self.alertTimer = 60*5
    self.alertText = msg
    self.scrollPos.dest.y = -32
end

function StatusBar:onMouseMove(x,y)
    StatusBar.super.onMouseMove(self,x,y)
    if self:isWithinBounds(x,y) and self.alertTimer <= 0 and Applet.IsFocused() then
        self.scrollPos.dest.y = 32
    elseif self.alertTimer <= 0 then
        self.scrollPos.dest.y = 0
    end
end

function StatusBar:onMouseDown(button,x,y,clicks)
    if self:isWithinBounds(x,y) then
        if #self.tabs > 0 and self.scrollPos.dest.y > 0 then
            for i,j in ipairs(self.tabs) do
                local w = math.min(170, math.ceil(self.size.w / #self.tabs))
                local X = self.pos.x + (i-1) * w
                if x > X and x < X+w then
                    self.currentTab = i
                    Core.Redraw = true
                    break
                end
            end
        end
    end
end

return StatusBar