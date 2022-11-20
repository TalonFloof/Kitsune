local Commands = require 'Kitsune.Command'
local Keybinds = require 'Kitsune.Command.Keybind'
local DocView = require 'Kitsune.DocumentView'
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
        local docView = DocView()
        docView.document = {lines={""},unsavedChanges=false}
        Core.StatusBar:OpenTab("unnamed",docView)
        Core.Redraw = true
    end,
    ["file:open"] = function()
        Core.CommandBar:createPrompt("Path",function(txt, option)
            local result, val = DocView.OpenDoc(txt)
            if not result and val then
                Core.StatusBar:displayAlert(val)
            elseif not result and not val then
                Core.StatusBar:displayAlert("An unknown error occured while opening the file")
            elseif result then
                local docView = DocView()
                docView.document = val
                Core.StatusBar:OpenTab(val.path,docView)
            end
        end,fileSuggest)
    end,
    ["file:save"] = function()
        if #Core.StatusBar.tabs == 0 then
            Core.StatusBar:displayAlert("No buffers can be saved")
        else
            if Core.StatusBar:getCurrent().document.path ~= nil then
                Core.try(function()
                    local file = io.open(Core.StatusBar:getCurrent().document.path,"w")
                    file:write(table.concat(Core.StatusBar:getCurrent().document.lines,"\n"))
                    file:close()
                    Core.StatusBar:displayAlert("Successfully saved file")
                    Core.StatusBar:getCurrent().document.unsavedChanges = false
                end)
            else
                Core.CommandBar:createPrompt("Path",function(txt, option)
                    Core.try(function()
                        local file = io.open(txt,"w")
                        file:write(table.concat(Core.StatusBar:getCurrent().document.lines,"\n"))
                        file:close()
                        Core.StatusBar:displayAlert("Successfully saved file")
                        Core.StatusBar:getCurrent().document.unsavedChanges = false
                        Core.StatusBar:getCurrent().document["path"] = txt
                    end)
                end,fileSuggest)
            end
        end
    end,
    ["file:close"] = function()
        if #Core.StatusBar.tabs == 0 then
            Core.StatusBar:displayAlert("No buffers can be closed")
        else
            if Core.StatusBar:getCurrent().document.unsavedChanges then
                Core.CommandBar:createPrompt("Unsaved Changes",function(txt, option)
                    if option.cmd == "1" then
                        Core.StatusBar:CloseTab()
                        Core.Redraw = true
                    elseif option.cmd == "2" then
                        Commands.Execute("file:save")
                    end
                end,function(text)
                    return {{text="Save And Close",cmd="2",score=0},{text="Close Without Saving",cmd="1",score=1}}
                end)
            else
                Core.StatusBar:CloseTab()
                Core.Redraw = true
            end
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