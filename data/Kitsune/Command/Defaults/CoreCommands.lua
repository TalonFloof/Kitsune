local Commands = require 'Kitsune.Command'

Commands.Add {
    ["kitsune_core:open_command_bar"] = function()

    end,
    ["kitsune_core:toggle_fullscreen"] = function()
        Applet.ToggleFullscreen()
    end
}