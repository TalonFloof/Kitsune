local Object = require "Kitsune.Object"
local Core = require "Kitsune"

local SyntaxHighlighter = Object:extend()

function SyntaxHighlighter:new(docView)
    self.docView = docView
    Core.addThread(function()
        while true do
            coroutine.yield(1/60)
        end
    end,self)
end