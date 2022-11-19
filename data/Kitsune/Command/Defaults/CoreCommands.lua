local Commands = require 'Kitsune.Command'
local Keybinds = require 'Kitsune.Command.Keybind'
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
                    score = name.points,
                    keybind = Keybinds.GetKeybind(name.text)
                }
            end
            return result
        end)
    end,
    ["core:toggle_fullscreen"] = function()
        Applet.ToggleFullscreen()
    end,
    ["core:open_debug_console"] = function()
        Core.DebugConsole.destHeight = (Core.DebugConsole.destHeight == 0 and Core.DebugConsole.maxHeight or 0)
    end
}

Keybinds.Add {
    ["ctrl+shift+p"] = "core:run_command",
    ["f11"] = "core:toggle_fullscreen",
    ["ctrl+`"] = "core:open_debug_console"
}