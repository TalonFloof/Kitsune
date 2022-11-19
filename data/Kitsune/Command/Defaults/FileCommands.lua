local Commands = require 'Kitsune.Command'
local Keybinds = require 'Kitsune.Command.Keybind'
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

local function directorySuggest(text)
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
            if file:lower():find(text:lower(), nil, true) == 1 and info.type == "dir" then
                table.insert(res, {text=file,cmd=file,score=#res+1})
            end
        end
    end
    return res
end

Commands.Add {
    ["file:new"] = function()
        Core.DocumentView.document = {lines={""}}
        Core.DocumentView.selection = {from={x=1,y=1},to={x=1,y=1}}
        Core.DocumentView.scrollPos.dest = {x=0,y=0}
        Core.Redraw = true
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
                Core.DocumentView.selection = {from={x=1,y=1},to={x=1,y=1}}
                Core.DocumentView.scrollPos.dest = {x=0,y=0}
            end
        end,fileSuggest)
    end,
    ["file:save"] = function()
        if Core.DocumentView.document == nil then
            Core.StatusBar:displayAlert("No buffers can be saved")
        else
            if Core.DocumentView.document.path ~= nil then
                Core.try(function()
                    local file = io.open(Core.DocumentView.document.path,"w")
                    file:write(table.concat(Core.DocumentView.document.lines,"\n"))
                    file:close()
                    Core.StatusBar:displayAlert("Successfully saved file")
                end)
            else
                Core.CommandBar:createPrompt("Path",function(txt, option)
                    Core.try(function()
                        local file = io.open(txt,"w")
                        file:write(table.concat(Core.DocumentView.document.lines,"\n"))
                        file:close()
                        Core.StatusBar:displayAlert("Successfully saved file")
                        Core.DocumentView.document["path"] = txt
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
            Core.Redraw = true
        end
    end,
    ["file:change_working_directory"] = function()
        Core.CommandBar:createPrompt("Path",function(txt, option)
            Core.try(function()
                System.ChangeCurrentWorkingDirectory(txt)
                Core.StatusBar:displayAlert("Successfully changed Working Directory")
            end)
        end,directorySuggest)
    end,
}

Keybinds.Add {
    ["ctrl+s"] = "file:save",
    ["ctrl+w"] = "file:close",
    ["ctrl+o"] = "file:open",
    ["ctrl+shift+o"] = "file:change_working_directory",
    ["ctrl+n"] = "file:new"
}