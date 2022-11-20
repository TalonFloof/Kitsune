--[[
    Some code used within here is adpoted from rxi's lite text editor, licensed under the MIT License.
    The original source code can be found here: https://github.com/rxi/lite/blob/master/data/core/init.lua
]]

local Keybind = nil

local core = {}

core.Redraw = true
core.Cursor = "Default"
core.MousePos = {x=0,y=0}
core.Threads = {}
core.Tickables = {}
core.Exit = false

function core.try(f)
    xpcall(f,function(e)
        core.StatusBar:displayAlert(e)
    end)
end

function core.addTickable(obj)
    table.insert(core.Tickables,obj)
end

function core.addThread(f, weakRef)
    local key = weakRef or #core.Threads + 1
    local fn = function() return core.try(f) end
    core.Threads[key] = { cr = coroutine.create(fn), wake = 0 }
  end

function core.Initialize()
    local StatusBar = require "Kitsune.StatusBar"
    local DocView = require "Kitsune.DocumentView"
    local CmdBar = require "Kitsune.Command.CommandBar"
    local Command = require "Kitsune.Command"
    local DebugCon = require "Kitsune.DebugConsole"
    Keybind = require "Kitsune.Command.Keybind"
    core.StatusBar = StatusBar()
    if #STARTUP_FILE > 0 then
        core.StatusBar:OpenTab(DocView(STARTUP_FILE))
    end
    core.StatusBar:resizeTabElement(Applet.GetResolution())
    --core.DocumentView = DocView(#STARTUP_FILE > 0 and STARTUP_FILE or nil)
    core.CommandBar = CmdBar()
    core.DebugConsole = DebugCon()
    core.addTickable(core.StatusBar)
    core.addTickable(core.CommandBar)
    core.addTickable(core.DebugConsole)
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
    while true do
        core.frameStart = Applet.GetMillis()
        local redrawTriggered = core.Step()
        if core.Exit then break end
        core.ThreadStep()
        for _,i in ipairs(core.Tickables) do i:tick() end
        core.StatusBar:getCurrent():tick()
        local elapsed = Applet.GetMillis() - core.frameStart
        Applet.Sleep(math.max(0, 1 / 60 - elapsed))
        if type(core.Redraw) == "number" then
            core.Redraw = core.Redraw - 1
            if core.Redraw == 0 then
                core.Redraw = true
            end
        end
    end
end

core.ThreadStep = coroutine.wrap(function()
    while true do
        local max_time = 1 / 60 - 0.004
        local ran_any_threads = false
        for k, thread in pairs(core.Threads) do
            if thread.wake < Applet.GetMillis() then
                local _, wait = assert(coroutine.resume(thread.cr))
                if coroutine.status(thread.cr) == "dead" then
                    if type(k) == "number" then
                        table.remove(core.Threads, k)
                    else
                        core.Threads[k] = nil
                    end
                elseif wait then
                    thread.wake = Applet.GetMillis() + wait
                end
                ran_any_threads = true
            end

            if Applet.GetMillis() - core.frameStart > max_time then
                coroutine.yield()
            end
        end
        if not ran_any_threads then coroutine.yield() end
    end
end)

function core.Step()
    local didRedraw = false
    if core.Redraw == true then
        core.StatusBar:draw()
        core.CommandBar:draw()
        core.DebugConsole:draw()
        Renderer.ClearClipStack() -- Just in case...
        Renderer.Invalidate()
        core.Redraw = false
        didRedraw = true
    end
    local event = table.pack(Applet.PollEvent())
    local max_time = 1 / 60 - 0.004
    while #event > 0 do
        if Applet.GetMillis() - core.frameStart > max_time then
            return didRedraw
        end
        if event[1] == "AppletQuit" then
            core.Exit = true
            return didRedraw
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
            core.DebugConsole:onKeyPress(event[2])
        elseif event[1] == "AppletKeyUp" then
            Keybind.onKeyRelease(event[2])
        elseif event[1] == "AppletText" then
            core.CommandBar:onTextType(event[2])
            if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onTextType(event[2]) end
            core.DebugConsole:onTextType(event[2])
        elseif event[1] == "AppletMouseDown" then
            core.CommandBar:onMouseDown(event[2],event[3],event[4],event[5])
            core.StatusBar:onMouseDown(event[2],event[3],event[4],event[5])
            if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseDown(event[2],event[3],event[4],event[5]) end
        elseif event[1] == "AppletMouseUp" then
            if core.StatusBar.tabs[core.StatusBar.currentTab] then core.StatusBar:getCurrent():onMouseUp(event[2],event[3],event[4]) end
        end
        event = table.pack(Applet.PollEvent())
    end
    return didRedraw
end

return core
