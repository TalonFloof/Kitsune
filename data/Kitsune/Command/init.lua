local Command = {}

Command.Map = {}

function Command.StylizeName(name)
    return name:gsub(":", ": "):gsub("_", " "):gsub("%S+", function(str) return str:sub(1, 1):upper() .. str:sub(2) end)
end

function Command.Add(map)
    for name, fn in pairs(map) do
        Command.Map[name] = fn
    end
end

function Command.Execute(name)
    local cmd = Command.Map[name]
    if cmd then
        cmd()
        return true
    end
    return false
end

function Command.InitializeBuiltins()
    for _, name in ipairs({"Core"}) do
        require("Kitsune.Command.Defaults."..name.."Commands")
    end
end

return Command