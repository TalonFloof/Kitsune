local Element = require "Kitsune.Element"
local Core = require "Kitsune"
local Theme = require "Kitsune.Theme"

local EmptyView = Element:extend()

function EmptyView:new()
    EmptyView.super.new(self)
end

function EmptyView:draw()
    Renderer.PushClipArea(self.pos.x,self.pos.y,self.size.w,self.size.h)
    self:drawBackground(Theme.docBackground)
    local imageSize = math.floor((self.size.h+32) / 4)
    Renderer.Image("Kitsune:Logo",(self.size.w/2)-(imageSize/2),(self.size.h/2)-(imageSize/2)+self.pos.y,imageSize,imageSize)
    local cmdBarMsg = "Press Ctrl+Shift+P for a list of commands"
    if self.size.w >= #cmdBarMsg*16 then
        Renderer.Text((self.size.w/2)-(#cmdBarMsg*8)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,2,cmdBarMsg,Theme.text)
    else
        Renderer.Text((self.size.w/2)-(#cmdBarMsg*4)+self.pos.x,(self.size.h/2)+(imageSize/2)+self.pos.y,1,cmdBarMsg,Theme.text)
    end
    Renderer.PopClipArea()
end

return EmptyView