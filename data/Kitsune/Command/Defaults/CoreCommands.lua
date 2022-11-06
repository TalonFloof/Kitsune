local Commands = require 'Kitsune.Command'
local Core = require 'Kitsune'

Commands.Add {
    ["kitsune_core:open_command_bar"] = function()
        Core.CommandBar.destHeight = 32
    end,
    ["kitsune_core:toggle_fullscreen"] = function()
        Applet.ToggleFullscreen()
    end
}