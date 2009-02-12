-- Author: Tobi Vollebregt

-- unit names must be lowercase!

gadget.unitBuildOrder = {
	gbrhq = {
		"gbrhqengineer",
		"gbrhqengineer",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
		"gbr_platoon_hq",
	},
	gbrbarracks = {
		"gbrengineer",
		"gbr_platoon_rifle",
		"gbr_platoon_assault",
		"gbr_platoon_mortar",
	},
	gbrvehicleyard = {
		"gbrmatadorengvehicle",
		"gbrmatadorengvehicle"
	},
}

gadget.baseBuildOrder = {
	"gbrbarracks",
	"gbrstorage",
	"gbrbarracks",
	"gbrvehicleyard",
	"gbrstorage",
	"gbrstorage",
	"gbrgunyard",
	"gbrtankyard",
}

gadget.baseBuilders = {
	"gbrhqengineer",
	"gbrengineer",
	"gbrmatadorengvehicle",
	"gerengineer",
	"gerhqengineer",
	--TODO: eng vehicle
	"rusengineer",
	--TODO: commisar, eng vehicle
	"ushqengineer",
	"usengineer",
	"usgmcengvehicle",
}
