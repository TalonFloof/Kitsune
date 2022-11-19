local Keybind = require "Kitsune.Command.Keybind"

local core = {}

core.Redraw = true
core.Cursor = "Default"
core.MousePos = {x=0,y=0}

function core.try(f)
    xpcall(f,function(e)
        core.StatusBar:displayAlert(e)
    end)
end

function core.Initialize()
    local StatusBar = require "Kitsune.StatusBar"
    local DocView = require "Kitsune.DocumentView"
    local CmdBar = require "Kitsune.Command.CommandBar"
    local Command = require "Kitsune.Command"
    core.StatusBar = StatusBar()
    core.DocumentView = DocView(#STARTUP_FILE > 0 and STARTUP_FILE or nil)
    core.CommandBar = CmdBar()
    core.DocumentView.size.w = table.pack(Applet.GetResolution())[1]
    core.DocumentView.size.h = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.size.w = table.pack(Applet.GetResolution())[1]
    core.CommandBar.size.w = table.pack(Applet.GetResolution())[1]
    core.CommandBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.CommandBar.sourceY = table.pack(Applet.GetResolution())[2]-32
    if not Renderer.LoadImage("Kitsune:Logo",EXEC_DIR.."/data/Assets/Kitsune.svg") then
        error("Failed to load image Kitsune:Logo!")
    end
    if not Renderer.LoadImage("Kitsune:LogoSymbolic",EXEC_DIR.."/data/Assets/KitsuneSymbolic.svg") then
        error("Failed to load image Kitsune:LogoSymbolic!")
    end
    Command.InitializeBuiltins()
    require "User"
end

function core.Run()
    local frameStart = Applet.GetMillis()
    while true do
        if core.Redraw == true then
            core.DocumentView:draw()
            core.StatusBar:draw()
            core.CommandBar:draw()
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
                    core.CommandBar.pos.y = event[3]-32
                    core.CommandBar.sourceY = event[3]-32
                    core.CommandBar.size.w = event[2]
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
                    core.CommandBar:onKeyPress(event[2])
                    core.DocumentView:onKeyPress(event[2])
                elseif event[1] == "AppletKeyUp" then
                    Keybind.onKeyRelease(event[2])
                elseif event[1] == "AppletText" then
                    core.CommandBar:onTextType(event[2])
                    core.DocumentView:onTextType(event[2])
                elseif event[1] == "AppletMouseDown" then
                    core.CommandBar:onMouseDown(event[2],event[3],event[4],event[5])
                    core.DocumentView:onMouseDown(event[2],event[3],event[4],event[5])
                elseif event[1] == "AppletMouseUp" then
                    core.DocumentView:onMouseUp(event[2],event[3],event[4])
                end
            else
                Applet.Sleep(math.max(0, 1 / 60 - (Applet.GetMillis() - frameStart)))
            end
        end
        if Applet.GetMillis() - frameStart >= 1 / 60 then
            Applet.Sleep(math.max(0, 1 / 60 - (Applet.GetMillis() - frameStart)))
            frameStart = Applet.GetMillis()
            if type(core.Redraw) == "number" then
                core.Redraw = core.Redraw - 1
                if core.Redraw == 0 then
                    core.Redraw = true
                end
            end
            core.DocumentView:tick()
            core.StatusBar:tick()
            core.CommandBar:tick()
        end
    end
end

return core
