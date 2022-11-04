local core = {}

function core.Initialize()

end

function core.Run()
    while true do
        local event = table.pack(AppletEvents.PollEvent())
        if #event > 0 then
            if event[1] == "AppletQuit" then
                break
            end
        end
    end
end

return core