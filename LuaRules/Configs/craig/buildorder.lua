-- Author: Tobi Vollebregt

-- unit names must be lowercase!

gadget.unitBuildOrder = {
	-- Great Britain
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
	-- Russia
	ruscommander = {
		"ruscommissar",
		"ruscommissar",
		"ruscommissar",
		"ruscommissar",
		"ruscommissar",
	},
}

gadget.baseBuildOrder = {
-- TODO: need a way to specify BO for other sides
--	"rusbarracks",
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
	--"ruscommander",
	"ruscommissar",
	"rusengineer",
	--TODO: eng vehicle
	"ushqengineer",
	"usengineer",
	"usgmcengvehicle",
}
