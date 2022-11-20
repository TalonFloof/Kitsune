local Object = require "Kitsune.Object"
local Core = require "Kitsune"

local SyntaxHighlighter = Object:extend()

function SyntaxHighlighter:new(docView)
    self.docView = docView
    Core.addThread(function()
        while true do
            if self.firstLine > self.maxLine then
                self.maxLine = 0
                coroutine.yield(1/60)
            else
                
            end
        end
    end,self)
end

function SyntaxHighlighter:reset()
    self.lines = {}
    self.firstLine = 1
    self.maxLine = 0
end