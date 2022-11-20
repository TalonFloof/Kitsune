local Commands = require 'Kitsune.Command'
local Keybinds = require 'Kitsune.Command.Keybind'
local Core = require 'Kitsune'

local function moveToChar(self, x, y, offset)
    x,y = self:clampPosition(x, y)
    x = x + offset
    while y > 1 and x < 1 do
        y = y - 1
        x = x + #self.document.lines[y] + 1
    end
    while y < #self.document.lines and x > #self.document.lines[y]+1 do
        x = x - (#self.document.lines[y]+1)
        y = y + 1
    end
    x,y = self:clampPosition(x, y)
    self.selection.to.x = x
    self.selection.to.y = y
    self.selection.from.x = x
    self.selection.from.y = y
end

local function moveToLine(self, x, y, offset)
    x,y = self:clampPosition(x, y)
    y = y + offset
    x,y = self:clampPosition(x, y)
    self.selection.to.x = x
    self.selection.to.y = y
    self.selection.from.x = x
    self.selection.from.y = y
end

Commands.Add {
    ["edit:move_to_prev_char"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            moveToChar(Core.StatusBar:getCurrent(),Core.StatusBar:getCurrent().selection.to.x,Core.StatusBar:getCurrent().selection.to.y,-1)
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_next_char"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            moveToChar(Core.StatusBar:getCurrent(),Core.StatusBar:getCurrent().selection.to.x,Core.StatusBar:getCurrent().selection.to.y,1)
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_prev_line"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            moveToLine(Core.StatusBar:getCurrent(),Core.StatusBar:getCurrent().selection.to.x,Core.StatusBar:getCurrent().selection.to.y,-1)
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_next_line"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            moveToLine(Core.StatusBar:getCurrent(),Core.StatusBar:getCurrent().selection.to.x,Core.StatusBar:getCurrent().selection.to.y,1)
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:newline"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            local movingOverText = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]:sub(Core.StatusBar:getCurrent().selection.to.x)
            Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y] = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]:sub(1,Core.StatusBar:getCurrent().selection.to.x-1)
            table.insert(Core.StatusBar:getCurrent().document.lines,Core.StatusBar:getCurrent().selection.to.y+1,movingOverText)
            Core.StatusBar:getCurrent().selection.to.y = Core.StatusBar:getCurrent().selection.to.y + 1
            Core.StatusBar:getCurrent().selection.to.x = 1
            Core.StatusBar:getCurrent().selection.from.x = Core.StatusBar:getCurrent().selection.to.x
            Core.StatusBar:getCurrent().selection.from.y = Core.StatusBar:getCurrent().selection.to.y
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
            Core.StatusBar:getCurrent().document.unsavedChanges = true
        end
    end,
    ["edit:backspace"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            if Core.StatusBar:getCurrent().selection.to.x ~= Core.StatusBar:getCurrent().selection.from.x or Core.StatusBar:getCurrent().selection.to.y ~= Core.StatusBar:getCurrent().selection.from.y then
                print("Selection Removal")
            elseif Core.StatusBar:getCurrent().selection.to.x > 1 then
                local text = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]
                text = text:sub(1,Core.StatusBar:getCurrent().selection.to.x-2)..text:sub(Core.StatusBar:getCurrent().selection.to.x)
                Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y] = text
                Core.StatusBar:getCurrent().selection.to.x = math.max(1,Core.StatusBar:getCurrent().selection.to.x - 1)
                Core.StatusBar:getCurrent().selection.from.x = Core.StatusBar:getCurrent().selection.to.x
                Core.StatusBar:getCurrent().ticks = 0
                Core.Redraw = true
                Core.StatusBar:getCurrent().document.unsavedChanges = true
            elseif Core.StatusBar:getCurrent().selection.to.x <= 1 and Core.StatusBar:getCurrent().selection.to.y > 1 then
                local text = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]
                if Core.StatusBar:getCurrent().selection.to.y-1 >= 1 then
                    Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y-1] = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y-1] .. text
                end
                Core.StatusBar:getCurrent().selection.to.y = Core.StatusBar:getCurrent().selection.to.y - 1
                Core.StatusBar:getCurrent().selection.to.x = #Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]-#text+1
                Core.StatusBar:getCurrent().selection.from.x = Core.StatusBar:getCurrent().selection.to.x
                Core.StatusBar:getCurrent().selection.from.y = Core.StatusBar:getCurrent().selection.to.y
                table.remove(Core.StatusBar:getCurrent().document.lines,Core.StatusBar:getCurrent().selection.to.y+1)
                Core.StatusBar:getCurrent().ticks = 0
                Core.Redraw = true
                Core.StatusBar:getCurrent().document.unsavedChanges = true
            end
        end
    end,
    ["edit:indent"] = function()
        if #Core.StatusBar.tabs ~= 0 then
            local text = Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y]
            text = text:sub(1,Core.StatusBar:getCurrent().selection.to.x-1).."    "..text:sub(Core.StatusBar:getCurrent().selection.to.x)
            Core.StatusBar:getCurrent().document.lines[Core.StatusBar:getCurrent().selection.to.y] = text
            Core.StatusBar:getCurrent().selection.to.x = Core.StatusBar:getCurrent().selection.to.x + 4
            Core.StatusBar:getCurrent().selection.from.x = Core.StatusBar:getCurrent().selection.to.x
            Core.StatusBar:getCurrent().ticks = 0
            Core.Redraw = true
            Core.StatusBar:getCurrent().document.unsavedChanges = true
        end
    end
}

Keybinds.Add {
    ["left"] = "edit:move_to_prev_char",
    ["right"] = "edit:move_to_next_char",
    ["up"] = "edit:move_to_prev_line",
    ["down"] = "edit:move_to_next_line",
    ["return"] = "edit:newline",
    ["backspace"] = "edit:backspace",
    ["tab"] = "edit:indent"
}