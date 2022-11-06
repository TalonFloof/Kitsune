local Keybind = require "Kitsune.Command.Keybind"

local core = {}

core.Redraw = true
core.Cursor = "Default"
core.MousePos = {x=0,y=0}

function core.Initialize()
    local StatusBar = require "Kitsune.StatusBar"
    local DocView = require "Kitsune.DocumentView"
    local CmdBar = require "Kitsune.Command.CommandBar"
    local Command = require "Kitsune.Command"
    core.StatusBar = StatusBar()
    core.DocumentView = DocView()
    core.CommandBar = CmdBar()
    core.DocumentView.size.w = table.pack(Applet.GetResolution())[1]
    core.DocumentView.size.h = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.size.w = table.pack(Applet.GetResolution())[1]
    core.CommandBar.size.w = table.pack(Applet.GetResolution())[1]
    if not Renderer.LoadImage("Kitsune:Logo",EXEC_DIR.."/data/Assets/Kitsune.svg") then
        error("Failed to load image Kitsune:Logo!")
    end
    if not Renderer.LoadImage("Kitsune:LogoSymbolic",EXEC_DIR.."/data/Assets/KitsuneSymbolic.svg") then
        error("Failed to load image Kitsune:LogoSymbolic!")
    end

    Command.InitializeBuiltins()
end

function core.Run()
    local frameStart = Applet.GetMillis()
    while true do
        if core.Redraw then
            core.DocumentView:draw()
            core.StatusBar:draw()
            Renderer.ClearClipStack() -- Just in case...
            Renderer.Invalidate()
            core.Redraw = false
        else
            local event = table.pack(Applet.PollEvent())
            if #event > 0 then
                if event[1] == "AppletQuit" then
                    break
                elseif event[1] == "AppletResized" then
                    core.DocumentView.size.w = event[2]
                    core.DocumentView.size.h = event[3]-32
                    core.StatusBar.pos.y = event[3]-32
                    core.StatusBar.size.w = event[2]
                    core.Redraw = true
                elseif event[1] == "AppletMouseMoved" then
                    core.DocumentView:onMouseMove(event[2],event[3])
                    core.StatusBar:onMouseMove(event[2],event[3])
                    core.MousePos.x = event[2]
                    core.MousePos.y = event[3]
                elseif event[1] == "AppletMouseScroll" then
                    core.DocumentView:onMouseScroll(core.MousePos.x,core.MousePos.y,event[2])
                    core.StatusBar:onMouseScroll(core.MousePos.x,core.MousePos.y,event[2])
                elseif event[1] == "AppletKeyDown" then
                    Keybind.onKeyPress(event[2])
                elseif event[1] == "AppletKeyUp" then
                    if event[2] == "f11" then
                        Applet.ToggleFullscreen()
                    else
                        Keybind.onKeyRelease(event[2])
                    end
                end
            else
                Applet.Sleep(math.max(0, 1 / 60 - (Applet.GetMillis() - frameStart)))
            end
        end
        if Applet.GetMillis() - frameStart >= 1 / 60 then
            Applet.Sleep(math.max(0, 1 / 60 - (Applet.GetMillis() - frameStart)))
            frameStart = Applet.GetMillis()
            core.DocumentView:tick()
            core.StatusBar:tick()
        end
    end
end

return core