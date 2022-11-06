local Commands = require 'Kitsune.Command'
local Core = require 'Kitsune'
local Utils = require 'Kitsune.Util'

Commands.Add {
    ["core:run_command"] = function()
        local commandList = Commands.GetNames()
        Core.CommandBar:createPrompt("Run Command",function(txt, option)
            if option then
                Commands.Execute(option.cmd)
            end
        end,function(txt)
            local result = Utils.FuzzyMatchTable(commandList,txt)
            for i, name in ipairs(result) do
                result[i] = {
                    text = Commands.StylizeName(name.text),
                    cmd = name.text,
                    score = name.points
                }
            end
            return result
        end)
    end,
    ["core:toggle_fullscreen"] = function()
        Applet.ToggleFullscreen()
    end
}