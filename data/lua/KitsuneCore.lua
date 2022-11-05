local core = {}

core.Redraw = true

function core.Initialize()
    local StatusBar = require "KitsuneStatusBar"
    core.StatusBar = StatusBar()
    Renderer.Clear(64,62,63,255)
    core.StatusBar.pos.y = table.pack(Applet.GetResolution())[2]-32
    core.StatusBar.size.w = table.pack(Applet.GetResolution())[1]
end

function core.Run()
    local frameStart = Applet.GetMillis()
    while true do
        if core.Redraw then
            Renderer.Clear(64,62,63,255)
            core.StatusBar:draw()
            core.Redraw = false
        end
        local event = table.pack(Applet.PollEvent())
        if #event > 0 then
            if event[1] == "AppletQuit" then
                break
            elseif event[1] == "AppletResized" then
                core.StatusBar.pos.y = event[3]-32
                core.StatusBar.size.w = event[2]
                core.Redraw = true
            end
        end
        if Applet.GetMillis() - frameStart >= 1 / 60 then
            Applet.Sleep(math.max(0, 1 / 60 - (Applet.GetMillis() - frameStart)))
            frameStart = Applet.GetMillis()
        end
    end
end

return core