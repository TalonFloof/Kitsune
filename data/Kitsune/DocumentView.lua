local Element = require "Kitsune.Element"
local Core = require "Kitsune"

local DocumentView = Element:extend()

function DocumentView:new(doc)
    DocumentView.super.new(self)
    self.cursor = "Caret"
    self.caretPos = {x = 1, y = 1}
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

function DocumentView:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(0x34,0x32,0x33,255)
    if self.document ~= nil then
        self.cursor = "Caret"
        local min, max = self:getLineRange()
        local padding = (#tostring(#self.document.lines)*8)+8
        for i=min,max do
            if self.caretPos.y == i and Core.CommandBar.destHeight < 32 and Applet.IsFocused() then
                Renderer.Rect(self.pos.x+padding,((i-1)*16)-self.scrollPos.y,self.size.w-padding,16,0x52,0x4F,0x50,255)
            end
            Renderer.PushClipArea(self.pos.x+padding,self.pos.y,self.size.w-padding,self.size.h)
            Renderer.Text(self.pos.x+padding-self.scrollPos.x,((i-1)*16)-self.scrollPos.y,1,self.document.lines[i],255,255,255)
            Renderer.PopClipArea()
            if self.caretPos.y == i and Core.CommandBar.destHeight < 32 and Applet.IsFocused() then
                Renderer.Text(self.pos.x+padding/2-(#tostring(i)*4),((i-1)*16)-self.scrollPos.y+1,1,i,0x61,0x5d,0x5f)
            else
                Renderer.Text(self.pos.x+padding/2-(#tostring(i)*4),((i-1)*16)-self.scrollPos.y+1,1,i,0x45,0x42,0x44)
            end
            if self.caretPos.y == i and self.ticks % 48 < 24 and Core.CommandBar.destHeight < 32 and Applet.IsFocused() then
                Renderer.Rect(self.pos.x+padding+((self.caretPos.x-1)*8)-self.scrollPos.x,((i-1)*16)-self.scrollPos.y,2,16,0x61,0xef,0xce,255)
            end
        end
    else
        self.cursor = "Default"
        local imageSize = math.floor((self.size.h+32) / 4)
        Renderer.Image("Kitsune:Logo",(self.size.w/2)-(imageSize/2)+self.pos.x,(self.size.h/2)-(imageSize/2)+self.pos.y,imageSize,imageSize)
        local cmdBarMsg = "To begin, press Ctrl+Shift+P to run a command"
        if self.size.w >= #cmdBarMsg*16 then
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*8)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,2,cmdBarMsg,0xc4,0xb3,0x98)
        else
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*4)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,1,cmdBarMsg,0xc4,0xb3,0x98)
        end
    end
    Renderer.PopClipArea()
end

function DocumentView:tick()
    DocumentView.super.tick(self)
    if self.document ~= nil and Core.CommandBar.destHeight < 32 then
        self.ticks = (self.ticks + 1) % (48*2)
        if self.ticks % 24 == 0 then
            Core.Redraw = true
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

local function ensureVisibility(docView)
    local padding = (#tostring(#docView.document.lines)*8)+8
    docView.scrollPos.dest.x = ((docView.caretPos.x-1) // ((docView.size.w-padding)//8)) * (docView.size.w-padding)
    
end

function DocumentView:onKeyPress(k)
    if self.document ~= nil and Core.CommandBar.size.h <= 0 then
        if k == "down" then
            self.caretPos.y = math.min(#self.document.lines,self.caretPos.y+1)
            self.caretPos.x = math.min(#self.document.lines[self.caretPos.y]+1,self.caretPos.x)
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "up" then
            self.caretPos.y = math.max(1,self.caretPos.y-1)
            self.caretPos.x = math.min(#self.document.lines[self.caretPos.y]+1,self.caretPos.x)
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "right" then
            if self.caretPos.x+1 > #self.document.lines[self.caretPos.y]+1 then
                if math.min(#self.document.lines,self.caretPos.y+1) ~= self.caretPos.y then
                    self.caretPos.y = self.caretPos.y+1
                    self.caretPos.x = 1
                    self.ticks = 0
                    ensureVisibility(self)
                    Core.Redraw = true
                end
            else
                self.caretPos.x = self.caretPos.x+1
                self.ticks = 0
                ensureVisibility(self)
                Core.Redraw = true
            end
        elseif k == "left" then
            if self.caretPos.x-1 < 1 then
                if math.max(1,self.caretPos.y-1) ~= self.caretPos.y then
                    self.caretPos.y = self.caretPos.y-1
                    self.caretPos.x = #self.document.lines[self.caretPos.y]+1
                    self.ticks = 0
                    ensureVisibility(self)
                    Core.Redraw = true
                end
            else
                self.caretPos.x = self.caretPos.x-1
                self.ticks = 0
                ensureVisibility(self)
                Core.Redraw = true
            end
        elseif k == "home" then
            self.caretPos.x = 1
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "end" then
            self.caretPos.x = #self.document.lines[self.caretPos.y]+1
            self.ticks = 0
            ensureVisibility(self)
            Core.Redraw = true
        elseif k == "backspace" and self.caretPos.x > 1 then
            local text = self.document.lines[self.caretPos.y]
            text = text:sub(1,self.caretPos.x-2)..text:sub(self.caretPos.x)
            self.document.lines[self.caretPos.y] = text
            self.caretPos.x = math.max(1,self.caretPos.x - 1)
            ensureVisibility(self)
            self.ticks = 0
            Core.Redraw = true
        elseif k == "backspace" and self.caretPos.x <= 1 and self.caretPos.y > 1 then
            local text = self.document.lines[self.caretPos.y]
            if self.caretPos.y-1 >= 1 then
                self.document.lines[self.caretPos.y-1] = self.document.lines[self.caretPos.y-1] .. text
            end
            self.caretPos.y = self.caretPos.y - 1
            self.caretPos.x = #self.document.lines[self.caretPos.y]-#text+1
            table.remove(self.document.lines,self.caretPos.y+1)
            ensureVisibility(self)
            self.ticks = 0
            Core.Redraw = true
        elseif k == "return" then
            local movingOverText = self.document.lines[self.caretPos.y]:sub(self.caretPos.x)
            self.document.lines[self.caretPos.y] = self.document.lines[self.caretPos.y]:sub(1,self.caretPos.x-1)
            table.insert(self.document.lines,self.caretPos.y+1,movingOverText)
            self.caretPos.y = self.caretPos.y + 1
            self.caretPos.x = 1
            self.ticks = 0
            Core.Redraw = true
        end
    end
end

function DocumentView:onTextType(k)
    if self.document ~= nil and Core.CommandBar.destHeight < 32 then
        local text = self.document.lines[self.caretPos.y]
        text = text:sub(1,self.caretPos.x-1)..k..text:sub(self.caretPos.x)
        self.document.lines[self.caretPos.y] = text
        self.caretPos.x = self.caretPos.x + 1
        self.ticks = 0
        ensureVisibility(self)
        Core.Redraw = true
    end
end

return DocumentView