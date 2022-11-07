local Command = require "Kitsune.Command"

local Keybind = {}

Keybind.Bindings = {
    ["ctrl+shift+p"] = "core:run_command",
    ["f11"] = "core:toggle_fullscreen",
    ["ctrl+s"] = "file:save"
}
Keybind.ModKeys = {}

local ModKeymap = {
    ["left ctrl"] = "ctrl",
    ["right ctrl"] = "ctrl",
    ["left shift"] = "shift",
    ["right shift"] = "shift",
    ["left alt"] = "alt",
    ["right alt"] = "altgr",
}

local function convertKeyToStrokeName(k)
    local modkeys = { "ctrl", "alt", "altgr", "shift" }
    local stroke = ""
    for _, mk in ipairs(modkeys) do
        if Keybind.ModKeys[mk] then
            stroke = stroke .. mk .. "+"
        end
    end
    return stroke .. k
end

function Keybind.onKeyPress(k)
    local mk = ModKeymap[k]
    if mk then
        Keybind.ModKeys[mk] = true
        if mk == "altgr" then
            Keybind.ModKeys["ctrl"] = false
        end
    else
        local stroke = convertKeyToStrokeName(k)
        local command = Keybind.Bindings[stroke]
        if command then
            return Command.Execute(command)
        end
    end
    return false
end

function Keybind.onKeyRelease(k)
    local mk = ModKeymap[k]
    if mk then
        Keybind.ModKeys[mk] = false
    end
end

return Keybind