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
        if Core.DocumentView.document ~= nil then
            moveToChar(Core.DocumentView,Core.DocumentView.selection.to.x,Core.DocumentView.selection.to.y,-1)
            Core.DocumentView.ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_next_char"] = function()
        if Core.DocumentView.document ~= nil then
            moveToChar(Core.DocumentView,Core.DocumentView.selection.to.x,Core.DocumentView.selection.to.y,1)
            Core.DocumentView.ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_prev_line"] = function()
        if Core.DocumentView.document ~= nil then
            moveToLine(Core.DocumentView,Core.DocumentView.selection.to.x,Core.DocumentView.selection.to.y,-1)
            Core.DocumentView.ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:move_to_next_line"] = function()
        if Core.DocumentView.document ~= nil then
            moveToLine(Core.DocumentView,Core.DocumentView.selection.to.x,Core.DocumentView.selection.to.y,1)
            Core.DocumentView.ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:newline"] = function()
        if Core.DocumentView.document ~= nil then
            local movingOverText = Core.DocumentView.document.lines[Core.DocumentView.selection.to.y]:sub(Core.DocumentView.selection.to.x)
            Core.DocumentView.document.lines[Core.DocumentView.selection.to.y] = Core.DocumentView.document.lines[Core.DocumentView.selection.to.y]:sub(1,Core.DocumentView.selection.to.x-1)
            table.insert(Core.DocumentView.document.lines,Core.DocumentView.selection.to.y+1,movingOverText)
            Core.DocumentView.selection.to.y = Core.DocumentView.selection.to.y + 1
            Core.DocumentView.selection.to.x = 1
            Core.DocumentView.selection.from.x = Core.DocumentView.selection.to.x
            Core.DocumentView.selection.from.y = Core.DocumentView.selection.to.y
            Core.DocumentView.ticks = 0
            Core.Redraw = true
        end
    end,
    ["edit:backspace"] = function()
        if Core.DocumentView.document ~= nil then
        end
    end
}

Keybinds.Add {
    ["left"] = "edit:move_to_prev_char",
    ["right"] = "edit:move_to_next_char",
    ["up"] = "edit:move_to_prev_line",
    ["down"] = "edit:move_to_next_line",
    ["return"] = "edit:newline",
    ["backspace"] = "edit:backspace"
}