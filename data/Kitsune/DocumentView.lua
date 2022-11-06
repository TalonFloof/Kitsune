local Element = require "Kitsune.Element"

local DocumentView = Element:extend()

function DocumentView:new(doc)
    DocumentView.super.new(self)
    self.cursor = "Caret"
    self.caretPos = {x = 1, y = 1}
    self.document = DocumentView.OpenDoc(doc)
end

function DocumentView.OpenDoc(doc) 
    if doc ~= nil then
        local lineIterator = io.lines(doc)
        local retValue = {lines={},path=doc}
        for i in lineIterator do
            table.insert(retValue.lines,tostring(i:gsub("[\t]","    ")))
        end
        return retValue
    else
        return nil
    end
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
            Renderer.Text(padding,((i-1)*16)-self.scrollPos.y,1,self.document.lines[i],255,255,255)
            Renderer.Text(padding/2-(#tostring(i)*4),((i-1)*16)-self.scrollPos.y+1,1,i,0x45,0x42,0x44)
        end
    else
        self.cursor = "Default"
        local imageSize = math.floor((self.size.h+32) / 4)
        Renderer.Image("Kitsune:Logo",(self.size.w/2)-(imageSize/2)+self.pos.x,(self.size.h/2)-(imageSize/2)+self.pos.y,imageSize,imageSize)
        local cmdBarMsg = "To begin, press Ctrl+Shift+P to see a list of commands"
        if self.size.w >= #cmdBarMsg*16 then
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*8)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,2,cmdBarMsg,0xc4,0xb3,0x98)
        else
            Renderer.Text((self.size.w/2)-(#cmdBarMsg*4)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,1,cmdBarMsg,0xc4,0xb3,0x98)
        end
    end
    Renderer.PopClipArea()
end

function DocumentView:onMouseScroll(x,y,direction)
    if self:isWithinBounds(x,y) then
        self.scrollPos.dest.y = math.max(0,self.scrollPos.dest.y + direction * (-50 * SCALE))
    end
end

return DocumentView