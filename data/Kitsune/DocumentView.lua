local Element = require "Kitsune.Element"
local Core = require "Kitsune"
local Theme = require "Kitsune.Theme"

local DocumentView = Element:extend()

function DocumentView:new(doc)
    DocumentView.super.new(self)
    self.cursor = "Caret"
    self.selection = {from = {x = 1, y = 1}, to = {x = 1, y = 1}}
    self.prevPos = {x=-1,y=-1}
    self.mouseDown = false
    local result, val = DocumentView.OpenDoc(doc)
    if result then
        self.document = val
    else
        self.document = nil
    end
    self.ticks = 0
end

function DocumentView.OpenDoc(doc)
    return xpcall(function()
        if doc ~= nil then
            local lineIterator = io.lines(doc)
            local retValue = {lines={},path=doc}
            for i in lineIterator do
                table.insert(retValue.lines,tostring(i:gsub("[\t]","    ")))
            end
            if #retValue.lines == 0 then retValue.lines = {""} end
            return retValue
        else
            error("Document is nil")
        end
    end,function(e)
        return e
    end)
end

function DocumentView:getLineRange()
    local y = self.scrollPos.y
    local minimum = math.max(1, math.floor(y / 16))
    local maximum = math.min(#self.document.lines,math.floor((y+self.size.h) / 16) + 1)
    return minimum, maximum
end

function DocumentView:getSelectionRange()
    local x1 = self.selection.from.x
    local x2 = self.selection.to.x
    local y1 = self.selection.from.y
    local y2 = self.selection.to.y
    if y1 > y2
    or y1 == y2 and x1 > x2 then
        return x2, y2, x1, y1
    else
        return x1, y1, x2, y2
    end
end

function DocumentView:clampPosition(col, line)
    line = math.max(1,math.min(#self.document.lines,line))
    col = math.max(1,math.min(#self.document.lines[line]+1,col))
    return col, line
end

function DocumentView:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.docBackground)
    if self.document ~= nil then
        self.cursor = "Caret"
        local min, max = self:getLineRange()
        local padding = (#tostring(#self.document.lines)*8)+8
        for i=min,max do
            if self.selection.to.y == i and Core.CommandBar.destHeight < 32 and Applet.IsFocused() and self.selection.to.x == self.selection.from.x and self.selection.to.y == self.selection.from.y then
                Renderer.Rect(self.pos.x+padding,((i-1)*16)-self.scrollPos.y,self.size.w-padding,16,Theme.lineHighlight)
            end
            local x1, y1, x2, y2 = self:getSelectionRange()
            if i >= y1 and i <= y2 then
                if y1 ~= i then x1 = 1 end
                if y2 ~= i then x2 = #self.document.lines[i] end
                local X1 = (self.pos.x+padding-self.scrollPos.x)+(#self.document.lines[i]:sub(1,x1)*8)
                local X2 = (self.pos.x+padding-self.scrollPos.x)+(#self.document.lines[i]:sub(1,x2)*8)
                Renderer.PushClipArea(self.pos.x+padding,self.pos.y,self.size.w-padding,self.size.h)
                Renderer.Rect(X1,((i-1)*16)-self.scrollPos.y,X2-X1,16,Theme.highlight)
                Renderer.PopClipArea()
            end
            Renderer.PushClipArea(self.pos.x+padding,self.pos.y,self.size.w-padding,self.size.h)
            Renderer.Text(self.pos.x+padding-self.scrollPos.x,((i-1)*16)-self.scrollPos.y,1,self.document.lines[i],Theme.docText)
            Renderer.PopClipArea()
            if self.selection.to.y == i and Core.CommandBar.destHeight < 32 and Applet.IsFocused() then
                Renderer.Text(self.pos.x+padding/2-(#tostring(i)*4),((i-1)*16)-self.scrollPos.y+1,1,i,Theme.lineNumber2)
            else
                Renderer.Text(self.pos.x+padding/2-(#tostring(i)*4),((i-1)*16)-self.scrollPos.y+1,1,i,Theme.lineNumber1)
            end
            if self.selection.to.y == i and self.ticks % 48 < 24 and Core.CommandBar.destHeight < 32 and Applet.IsFocused() then
                Renderer.PushClipArea(self.pos.x+padding,self.pos.y,self.size.w-padding,self.size.h)
                Renderer.Rect(self.pos.x+padding+((self.selection.to.x-1)*8)-self.scrollPos.x,((i-1)*16)-self.scrollPos.y,2,16,Theme.caret)
                Renderer.PopClipArea()
            end
        end
    else
        self.cursor = "Default"
        local imageSize = math.floor((self.size.h+32) / 4)
        Renderer.Image("Kitsune:Logo",(self.size.w/2)-(imageSize/2)+self.pos.x,(self.size.h/2)-(imageSize/2)+self.pos.y,imageSize,imageSize)
        local cmdBarMsg = "Press Ctrl+Shift+P for a list of commands"
        if self.size.w >= #cmdBarMsg*16 then
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*8)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,2,cmdBarMsg,Theme.text)
        else
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*4)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,1,cmdBarMsg,Theme.text)
        end
    end
    Renderer.PopClipArea()
end

local function ensureVisibility(docView)
    local min = 16 * (docView.selection.to.y - 1)
    local max = 16 * (docView.selection.to.y + 2) - docView.size.h
    docView.scrollPos.dest.y = math.min(docView.scrollPos.dest.y, min)
    docView.scrollPos.dest.y = math.max(docView.scrollPos.dest.y, max)
    local gw = (#tostring(#docView.document.lines)*8)+8
    local xoffset = (docView.selection.to.x-1)*8
    local max = xoffset - docView.size.w + gw + docView.size.w / 5
    docView.scrollPos.dest.x = math.max(0, max)
end

function DocumentView:tick()
    DocumentView.super.tick(self)
    if self.document ~= nil and Core.CommandBar.destHeight < 32 then
        self.ticks = (self.ticks + 1) % (48*2)
        if self.ticks % 24 == 0 then
            Core.Redraw = true
        end
        if self.prevPos.x ~= self.selection.to.x or self.prevPos.y ~= self.selection.to.y and self.size.w > 0 then
            ensureVisibility(self)
            self.prevPos.x, self.prevPos.y = self.selection.to.x, self.selection.to.y
        end
    else
        self.ticks = 0
    end
end

function DocumentView:onMouseScroll(x,y,direction)
    if self:isWithinBounds(x,y) and self.document ~= nil then
        self.scrollPos.dest.y = math.max(0,math.min(16*(#self.document.lines-1),self.scrollPos.dest.y + direction * (-50 * SCALE)))
    end
end

function DocumentView:onKeyPress(k)
    if self.document ~= nil and Core.CommandBar.size.h <= 0 then
        --[[if k == "down" then
            self.selection.to.y = math.min(#self.document.lines,self.selection.to.y+1)
            self.selection.to.x = math.min(#self.document.lines[self.selection.to.y]+1,self.selection.to.x)
            self.selection.from.x = self.selection.to.x
            self.selection.from.y = self.selection.to.y
            self.selection.to.x = self.selection.to.x
            self.selection.to.y = self.selection.to.y
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "up" then
            self.selection.to.y = math.max(1,self.selection.to.y-1)
            self.selection.to.x = math.min(#self.document.lines[self.selection.to.y]+1,self.selection.to.x)
            self.selection.from.x = self.selection.to.x
            self.selection.from.y = self.selection.to.y
            self.selection.to.x = self.selection.to.x
            self.selection.to.y = self.selection.to.y
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "right" then
            if self.selection.to.x+1 > #self.document.lines[self.selection.to.y]+1 then
                if math.min(#self.document.lines,self.selection.to.y+1) ~= self.selection.to.y then
                    self.selection.to.y = self.selection.to.y+1
                    self.selection.to.x = 1
                    self.selection.from.x = 1
                    self.selection.from.y = self.selection.to.y
                    self.selection.to.x = 1
                    self.selection.to.y = self.selection.to.y
                    self.ticks = 0
                    ensureVisibility(self)
                    Core.Redraw = true
                end
            else
                self.selection.to.x = self.selection.to.x+1
                self.selection.from.x = self.selection.to.x
                self.selection.to.x = self.selection.to.x
                self.ticks = 0
                ensureVisibility(self)
                Core.Redraw = true
            end
        elseif k == "left" then
            if self.selection.to.x-1 < 1 then
                if math.max(1,self.selection.to.y-1) ~= self.selection.to.y then
                    self.selection.to.y = self.selection.to.y-1
                    self.selection.to.x = #self.document.lines[self.selection.to.y]+1
                    self.selection.from.x = self.selection.to.x
                    self.selection.from.y = self.selection.to.y
                    self.selection.to.x = self.selection.to.x
                    self.selection.to.y = self.selection.to.y
                    self.ticks = 0
                    ensureVisibility(self)
                    Core.Redraw = true
                end
            else
                self.selection.to.x = self.selection.to.x-1
                self.selection.from.x = self.selection.to.x
                self.selection.to.x = self.selection.to.x
                self.ticks = 0
                ensureVisibility(self)
                Core.Redraw = true
            end
        elseif k == "home" then
            self.selection.to.x = 1
            self.selection.from.x = 1
            self.selection.to.x = 1
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "end" then
            self.selection.to.x = #self.document.lines[self.selection.to.y]+1
            self.selection.from.x = self.selection.to.x
            self.selection.to.x = self.selection.to.x
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "backspace" and self.selection.to.x > 1 then
            local text = self.document.lines[self.selection.to.y]
            text = text:sub(1,self.selection.to.x-2)..text:sub(self.selection.to.x)
            self.document.lines[self.selection.to.y] = text
            self.selection.to.x = math.max(1,self.selection.to.x - 1)
            self.selection.from.x = self.selection.to.x
            self.selection.to.x = self.selection.to.x
            ensureVisibility(self)
            self.ticks = 0
            Core.Redraw = true
        elseif k == "backspace" and self.selection.to.x <= 1 and self.selection.to.y > 1 then
            local text = self.document.lines[self.selection.to.y]
            if self.selection.to.y-1 >= 1 then
                self.document.lines[self.selection.to.y-1] = self.document.lines[self.selection.to.y-1] .. text
            end
            self.selection.to.y = self.selection.to.y - 1
            self.selection.to.x = #self.document.lines[self.selection.to.y]-#text+1
            self.selection.from.x = self.selection.to.x
            self.selection.from.y = self.selection.to.y
            self.selection.to.x = self.selection.to.x
            self.selection.to.y = self.selection.to.y
            table.remove(self.document.lines,self.selection.to.y+1)
            ensureVisibility(self)
            self.ticks = 0
            Core.Redraw = true
        elseif k == "return" then
            local movingOverText = self.document.lines[self.selection.to.y]:sub(self.selection.to.x)
            self.document.lines[self.selection.to.y] = self.document.lines[self.selection.to.y]:sub(1,self.selection.to.x-1)
            table.insert(self.document.lines,self.selection.to.y+1,movingOverText)
            self.selection.to.y = self.selection.to.y + 1
            self.selection.to.x = 1
            self.selection.from.x = self.selection.to.x
            self.selection.from.y = self.selection.to.y
            self.selection.to.x = self.selection.to.x
            self.selection.to.y = self.selection.to.y
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "tab" then
            local text = self.document.lines[self.selection.to.y]
            text = text:sub(1,self.selection.to.x-1).."    "..text:sub(self.selection.to.x)
            self.document.lines[self.selection.to.y] = text
            self.selection.to.x = self.selection.to.x + 4
            self.selection.from.x = self.selection.to.x
            self.selection.to.x = self.selection.to.x
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        end]]
    end
end

function DocumentView:onMouseDown(button,x,y,clicks)
    if self:isWithinBounds(x,y) and self.document ~= nil then
        self.mouseDown = true
        local padding = (#tostring(#self.document.lines)*8)+8
        self.selection.to.x = (self.scrollPos.dest.x+(x-padding)+8)//8
        self.selection.to.y = (self.scrollPos.dest.y+y+16)//16
        self.selection.to.y = math.floor(math.min(#self.document.lines,self.selection.to.y))
        self.selection.to.x = math.floor(math.max(1,math.min(#self.document.lines[self.selection.to.y]+1,self.selection.to.x)))
        self.selection.from.x = self.selection.to.x
        self.selection.from.y = self.selection.to.y
        ensureVisibility(self)
        Core.Redraw = true
        self.ticks = 0
    end
end

function DocumentView:onMouseUp(button,x,y)
    self.mouseDown = false
end

function DocumentView:onMouseMove(x,y)
    DocumentView.super.onMouseMove(self,x,y)
    if self:isWithinBounds(x,y) and self.document ~= nil and self.mouseDown then
        local padding = (#tostring(#self.document.lines)*8)+8
        self.selection.to.y = (self.scrollPos.dest.y+y+16)//16
        self.selection.to.y = math.floor(math.min(#self.document.lines,self.selection.to.y))
        self.selection.to.x = (self.scrollPos.dest.x+(x-padding)+8)//8
        self.selection.to.x = math.floor(math.max(1,math.min(#self.document.lines[self.selection.to.y]+1,self.selection.to.x)))
        ensureVisibility(self)
        Core.Redraw = 1
        self.ticks = 0
    end
end

function DocumentView:onTextType(k)
    if self.document ~= nil and Core.CommandBar.destHeight < 32 then
        local text = self.document.lines[self.selection.to.y]
        text = text:sub(1,self.selection.to.x-1)..k..text:sub(self.selection.to.x)
        self.document.lines[self.selection.to.y] = text
        self.selection.to.x = self.selection.to.x + 1
        self.selection.from.x = self.selection.to.x
        self.ticks = 0
        ensureVisibility(self)
        Core.Redraw = true
    end
end

return DocumentView