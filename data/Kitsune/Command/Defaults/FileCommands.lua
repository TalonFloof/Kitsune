local Commands = require 'Kitsune.Command'
local Core = require 'Kitsune'

Commands.Add {
    ["file:open"] = function()
        Core.CommandBar:createPrompt("Path",function(txt, option)
            Core.DocumentView.document = Core.DocumentView.OpenDoc(txt)
        end,function(txt)
            return {}
        end)
    end
}