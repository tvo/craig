-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- NOTE: this modinfo.lua is only used for developing,
-- the released modinfo.lua is embedded in make_release.sh

local modinfo = {
	name = "Spring: 1944 SVN + AI",
	shortName = "S44",
	game = "Spring 1944",
	shortGame = "S44",
	mutator = "AI for Spring: 1944",
	description = "AI for Spring: 1944",
	url = "http://www.spring1944.com",
	modtype = "1",
	depend = {
		"Spring: 1944 SVN"
	},
}

return modinfo
