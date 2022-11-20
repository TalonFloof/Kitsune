local Util = require "Kitsune.Util"
local Theme = {}

Theme.docBackground = { Util.GetColor "#2e2e32" }
Theme.commandBackground = { Util.GetColor "#202024" }
Theme.statusBackground = { Util.GetColor "#252529" }
Theme.docText = { Util.GetColor "#e1e1e6" }
Theme.text = { Util.GetColor "#97979c" }
Theme.dimText = { Util.GetColor "#525257" }
Theme.lightText = { Util.GetColor "#e1e1e6" }
Theme.lineNumber1 = { Util.GetColor "#48484f" }
Theme.lineNumber2 = { Util.GetColor "#83838f" }
Theme.caret = { Util.GetColor "#93ddfa" }
Theme.lineHighlight = { Util.GetColor "#48484f" }
Theme.highlight = { Util.GetColor "#4b4b52" }
Theme.commandHighlight = { Util.GetColor "#343438" }

return Theme
