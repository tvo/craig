-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- unit names must be lowercase!

-- Format: factory = { "unit to build 1", "unit to build 2", ... }
gadget.unitBuildOrder = {
	-- Imperial remmnats
	imp_commander = {
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_c_protocon",
		"imp_sc_probedroid", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_sc_speederbike", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_sc_probedroid",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_sc_probedroid", "imp_i_scouttrooper",
	},
	imp_b_barracks = {
		"imp_is_assault", "imp_is_heavy",
		"imp_c_condroid", "imp_d_antiair",
		"imp_is_assault", "imp_is_heavy",
		"imp_is_defense", "imp_is_assault",
		"imp_w_atrt", "imp_is_assault",
		"imp_is_scout", "imp_is_heavy",
		"imp_is_defense",
	},
	imp_b_droidplant = {
		"imp_is_b1",
		"imp_is_b1",
		"imp_i_superbattledroid",
		"imp_is_b1",
		"imp_i_superbattledroid",
		"imp_v_hailfire",
		"imp_is_b1",
		"imp_c_condroid",
		"imp_i_superbattledroid",
		"imp_is_b1",
		"imp_i_superbattledroid",
		"imp_v_hailfire",
		"imp_is_b1",
		"imp_is_b1",
		"imp_is_b1",
		"imp_i_superbattledroid",
		"imp_is_b1",
		"imp_i_droideka",
		"imp_i_droideka",
		"imp_is_b1",
		"imp_w_crabdroid",
		"imp_i_superbattledroid",
		"imp_is_b1",
		"imp_v_hailfire",
		"imp_i_superbattledroid",
		"imp_is_b1",
	},
	imp_b_vehicleplant = {
		"imp_v_tiecrawler", "imp_v_tx130",
		"imp_v_tiecrawler", "imp_v_tiecrawler",
		"imp_v_tiecrawler", "imp_v_tx130",
		"imp_v_mobileartillery",
	},
	imp_b_airplant = {
		"imp_a_tiefighter",
		"imp_a_tiefighter", "imp_a_laat",
		"imp_a_tiefighter", "imp_a_tiefighter",
		"imp_a_laat", "imp_a_tiefighter",
		"imp_a_tiefighter", "imp_a_tiefighter",
		"imp_a_tiefighter",
		"imp_a_tieinterceptor",
		"imp_a_tiefighter", "imp_a_tiebomber",
		"imp_a_tiefighter", "imp_a_laat",
		"imp_a_tiefighter", "imp_a_tiebomber",
	},
}

-- Format: side = { "unit to build 1", "unit to build 2", ... }
gadget.baseBuildOrder = {
	["galactic empire"] = {
		-- I used storages basically to delay tech up a bit :P Making GBR the easy faction to play against.
		"imp_b_barracks", "imp_p_solar", "imp_p_solar",
		"imp_p_solar", "imp_p_solar", "imp_p_solar",
		"imp_b_droidplant", "imp_p_solar", "imp_p_solar",
		"imp_p_solar", "imp_d_antiair", "imp_p_solar",
		"imp_b_barracks", "imp_p_estore", "imp_p_solar",
		"imp_p_solar", "imp_p_solar", "imp_p_solar",
		"imp_b_vehicleplant", "imp_p_estore", "imp_p_solar",
		"imp_d_ioncannon", "imp_p_fusion", "imp_p_fusion",
		"imp_b_airplant", "imp_p_estore", "imp_p_solar",
		"imp_d_ioncannon", "imp_p_fusion", "imp_p_fusion",
		"imp_b_barracks", "imp_p_fusion", "imp_p_fusion",
		"imp_d_ioncannon", "imp_d_antiair", "imp_p_fusion",
		"imp_b_droidplant", "imp_p_fusion", "imp_b_droidplant",
		"imp_b_droidplant", "imp_p_fusion", "imp_b_droidplant",
	},
}

-- This lists all the units (of all sides) that are considered "base builders"
gadget.baseBuilders = {
	"imp_c_condroid",
	"imp_c_protocon",
}

-- This lists all the units that should be considers flags.
gadget.flags = {
	"a_p_flag",
	"imp_p_flag",
	"imp_p_flagmil1",
	"imp_p_flagecon1",
	"reb_p_flag",
	"reb_p_flagmil1",
	"reb_p_flagecon1",
}

-- This lists all the units (of all sides) that may be used to cap flags.
gadget.flagCappers = {
	--TODO: add flag cappers
	"imp_i_scouttrooper",
}

-- Number of units per side used to cap flags.
gadget.reservedFlagCappers = {
	["galactic empire"] = 24,
	--TODO: add other sides
}

-- Currently I'm only configuring the the unitLimits per difficulty level,
-- it's easy however to use a similar structure for the buildorders above.

-- Do not limit units spawned through LUA! (infantry that is build in platoons,
-- deployed supply trucks, deployed guns, etc.)

if (gadget.difficulty == "easy") then

	-- On easy, limit both engineers and buildings until I've made an economy
	-- manager that can tell the AI whether it has sufficient income to build
	-- (and sustain) a particular building (factory).
	-- (AI doesn't use resource cheat in easy)
	gadget.unitLimits = {
		-- engineers
		imp_c_protocon       = 1,
		imp_c_condroid	   = 1,
		-- buildings
		imp_b_barracks       = 5,
		imp_b_droidplant     = 5,
		imp_b_vehicleplant   = 5,
		imp_b_airplant       = 5,
	}

elseif (gadget.difficulty == "medium") then

	-- On medium, limit engineers (much) more then on hard.
	gadget.unitLimits = {
		imp_c_protocon       = 2,
		imp_c_condroid	   = 2,
		-- buildings
		imp_b_barracks       = 5,
		imp_b_droidplant     = 5,
		imp_b_vehicleplant   = 5,
		imp_b_airplant       = 5,
	}

else

	-- On hard, limit only engineers (because they tend to get stuck if the
	-- total group of engineers and construction vehicles is too big.)
	gadget.unitLimits = {
		imp_c_protocon       = 5,
		imp_c_condroid	   = 5,
	}
end
