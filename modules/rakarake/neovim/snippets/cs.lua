local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"Console",
		fmta("Console.WriteLine(<>);", {
			i(1, ""),
		})
	),
    s(
        "main",
        fmta("void Main() {\n<>}", {
            i(1, ""),
        })
    ),
    s(
    ),
}
