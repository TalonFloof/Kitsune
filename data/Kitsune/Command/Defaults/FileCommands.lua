local Commands = require 'Kitsune.Command'
local Core = require 'Kitsune'

local function fileSuggest(text)
    local path, name = text:match("^(.-)([^/\\]*)$")
    local files = System.ListDirectory(path == "" and "." or path) or {}
    local res = {}
    for _, file in ipairs(files) do
        file = path .. file
        local info = System.GetFileInformation(file)
        if info then
            if info.type == "dir" then
                file = file .. SEPERATOR
            end
            if file:lower():find(text:lower(), nil, true) == 1 then
                table.insert(res, {text=file,cmd=file,score=#res+1})
            end
        end
    end
    return res
end

Commands.Add {
    ["file:new"] = function()
        Core.DocumentView.document = {lines={""}}
        Core.DocumentView.caretPos = {x=1,y=1}
    end,
    ["file:open"] = function()
        Core.CommandBar:createPrompt("Path",function(txt, option)
            local result, val = Core.DocumentView.OpenDoc(txt)
            if not result and val then
                Core.StatusBar:displayAlert(val)
            elseif not result and not val then
                Core.StatusBar:displayAlert("An unknown error occured while opening the file")
            elseif result then
                Core.DocumentView.document = val
                Core.DocumentView.caretPos = {x=1,y=1}
            end
        end,fileSuggest)
    end,
    ["file:save"] = function()
        if Core.DocumentView.document == nil then
            Core.StatusBar:displayAlert("No buffers can be saved")
        else
            if Core.DocumentView.document.path ~= nil then
                xpcall(function()
                    local file = io.open(Core.DocumentView.document.path,"w")
                    file:write(table.concat(Core.DocumentView.document.lines,"\n"))
                    file:close()
                    Core.StatusBar:displayAlert("Successfully saved file")
                end,function(e)
                    Core.StatusBar:displayAlert(e)
                end)
            else
                Core.CommandBar:createPrompt("Path",function(txt, option)
                    xpcall(function()
                        local file = io.open(txt,"w")
                        file:write(table.concat(Core.DocumentView.document.lines,"\n"))
                        file:close()
                        Core.StatusBar:displayAlert("Successfully saved file")
                        Core.DocumentView.document["path"] = txt
                    end,function(e)
                        Core.StatusBar:displayAlert(e)
                    end)
                end,fileSuggest)
            end
        end
    end,
    ["file:close"] = function()
        if Core.DocumentView.document == nil then
            Core.StatusBar:displayAlert("No buffers can be closed")
        else
            Core.DocumentView.document = nil
        end
    end
}