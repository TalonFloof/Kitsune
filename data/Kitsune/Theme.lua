local Util = require "Kitsune.Util"
local Theme = {}

Theme.docBackground = { Util.GetColor "#343233" }
Theme.commandBackground = { Util.GetColor "#242223" }
Theme.statusBackground = { Util.GetColor "#2c2a2b" }
Theme.docText = { Util.GetColor "#fffffff" }
Theme.text = { Util.GetColor "#c4b398" }
Theme.dimText = { Util.GetColor "#615d5f" }
Theme.lineNumber1 = { Util.GetColor "#454244" }
Theme.lineNumber2 = { Util.GetColor "#615d5f" }
Theme.caret = { Util.GetColor "#61efce" }
Theme.lineHighlight = { Util.GetColor "#454244" }
Theme.highlight = { Util.GetColor "#524f50" }
Theme.commandHighlight = { Util.GetColor "#383637" }

return Theme
