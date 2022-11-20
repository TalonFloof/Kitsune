local Keybind = nil

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
    local DebugCon = require "Kitsune.DebugConsole"
    Keybind = require "Kitsune.Command.Keybind"
    core.StatusBar = StatusBar()
    --core.StatusBar:OpenTab("Test 1",DocView(#STARTUP_FILE > 0 and STARTUP_FILE or nil))
    core.StatusBar:resizeTabElement(Applet.GetResolution())
    --core.DocumentView = DocView(#STARTUP_FILE > 0 and STARTUP_FILE or nil)
    core.CommandBar = CmdBar()
    core.DebugConsole = DebugCon()
    core.StatusBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.size.w = table.pack(Applet.GetResolution())[1]
    core.CommandBar.size.w = table.pack(Applet.GetResolution())[1]
    core.CommandBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.CommandBar.sourceY = table.pack(Applet.GetResolution())[2]-32
    core.DebugConsole.size.w = table.pack(Applet.GetResolution())[1]
    core.DebugConsole.maxHeight = table.pack(Applet.GetResolution())[2]//3
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
            core.StatusBar:draw()
            core.CommandBar:draw()
            core.DebugConsole:draw()
            Renderer.ClearClipStack() -- Just in case...
            Renderer.Invalidate()
            core.Redraw = false
        else
            local event = table.pack(Applet.PollEvent())
            if #event > 0 then
                if event[1] == "AppletQuit" then
                    break
                elseif event[1] == "AppletResized" then
                    core.StatusBar:resizeTabElement(event[2],event[3])
                    core.StatusBar.pos.y = event[3]-32
                    core.StatusBar.size.w = event[2]
                    core.CommandBar.pos.y = event[3]-32
                    core.CommandBar.sourceY = event[3]-32
                    core.CommandBar.size.w = event[2]
                    core.DebugConsole.size.w = event[2]
                    core.DebugConsole.maxHeight = event[3]//3
                    core.Redraw = true
                elseif event[1] == "AppletMouseMoved" then
                    if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseMove(event[2],event[3]) end
                    core.StatusBar:onMouseMove(event[2],event[3])
                    core.MousePos.x = event[2]
                    core.MousePos.y = event[3]
                elseif event[1] == "AppletMouseScroll" then
                    if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseScroll(core.MousePos.x,core.MousePos.y,event[2]) end
                    core.StatusBar:onMouseScroll(core.MousePos.x,core.MousePos.y,event[2])
                elseif event[1] == "AppletKeyDown" then
                    Keybind.onKeyPress(event[2])
                    core.CommandBar:onKeyPress(event[2])
                elseif event[1] == "AppletKeyUp" then
                    Keybind.onKeyRelease(event[2])
                elseif event[1] == "AppletText" then
                    core.CommandBar:onTextType(event[2])
                    if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onTextType(event[2]) end
                elseif event[1] == "AppletMouseDown" then
                    core.CommandBar:onMouseDown(event[2],event[3],event[4],event[5])
                    if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseDown(event[2],event[3],event[4],event[5]) end
                elseif event[1] == "AppletMouseUp" then
                    if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseUp(event[2],event[3],event[4]) end
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
            core.StatusBar:getCurrent():tick()
            core.StatusBar:tick()
            core.CommandBar:tick()
            core.DebugConsole:tick()
        end
    end
end

return core
