-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- unit names must be lowercase!

-- Format: factory = { "unit to build 1", "unit to build 2", ... }
gadget.unitBuildOrder = {
	-- rebel alliance
	reb_b_barracks = {
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_bothan", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_c_condroid", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_bothan", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_wookiee", "reb_w_espo",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_trooper", "reb_w_espo",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_combat", "reb_w_espo",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_combat",
		"reb_i_combat", "reb_i_combat",
		"reb_w_espo", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
		"reb_i_wookiee", "reb_i_combat",
		"reb_i_combat", "reb_w_espo",
		"reb_i_combat", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
		"reb_i_wookiee", "reb_i_combat",
		"reb_w_espo", "reb_i_combat",
		"reb_i_combat", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
		"reb_i_wookiee", "reb_i_combat",
		"reb_w_espo", "reb_i_combat",
		"reb_i_combat", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
	},
	reb_b_repulsorliftplant = {
		"reb_v_ulav", "reb_v_ulav",
		"reb_v_ulav", "reb_v_ulav",
		"reb_v_t1b", "reb_v_t2b",
		"reb_v_t1b", "reb_v_t2b",
		"reb_v_t2b", "reb_v_ulav",
		"reb_v_t1b", "reb_v_ulav",
		"reb_a_airspeeder", "reb_a_airspeeder",
		"reb_a_airspeeder", "reb_a_airspeeder",
		"reb_v_t1b", "reb_v_t2b",
		"reb_v_t2b", "reb_v_ulav",
		"reb_v_t1b", "reb_v_t2b",
	},
	reb_b_airplant = {
		"reb_a_z95", "reb_a_z95",
		"reb_a_z95", "reb_a_z95",
		"reb_a_z95", "reb_a_z95",
		"reb_a_awing", "reb_a_z95",
		"reb_a_z95", "reb_a_ywing",
		"reb_a_ywing", "reb_a_ywing",
	},
	-- Imperial Remmnants
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
		"imp_sc_speederbike", "imp_sc_speederbike",
		"imp_sc_speederbike", "imp_sc_speederbike",
		"imp_sc_speederbike", "imp_i_scouttrooper",
		"imp_sc_probedroid", "imp_sc_speederbike",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_c_protocon",
		"imp_sc_probedroid", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_sc_speederbike", "imp_sc_speederbike",
		"imp_sc_speederbike", "imp_sc_speederbike",
		"imp_sc_speederbike", "imp_sc_probedroid",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_i_scouttrooper",
		"imp_i_scouttrooper", "imp_sc_speederbike",
		"imp_sc_probedroid", "imp_sc_speederbike",
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
		"imp_v_mobileartillery", "imp_v_tiecrawler",
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
		"imp_p_solar", "imp_b_barracks", "imp_p_solar",
		"imp_b_vehicleplant", "imp_p_solar", "imp_p_solar",
		"imp_p_solar", "imp_d_antiair", "imp_p_solar",
		"imp_b_barracks", "imp_p_estore", "imp_p_fusion",
		"imp_b_droidplant", "imp_p_solar", "imp_p_solar",
		"imp_b_vehicleplant", "imp_p_estore", "imp_p_fusion",
		"imp_d_ioncannon", "imp_p_fusion", "imp_b_vehicleplant",
		"imp_b_airplant", "imp_p_estore", "imp_b_barracks",
		"imp_d_ioncannon", "imp_p_fusion", "imp_p_fusion",
		"imp_b_barracks", "imp_p_fusion", "imp_b_barracks",
		"imp_b_barracks", "imp_d_antiair", "imp_p_fusion",
	},
	["rebel alliance"] = {
		"reb_b_barracks", "reb_p_fusion", "reb_b_barracks",
		"reb_p_fusion", "reb_b_barracks", "reb_p_fusion",
		"reb_is_sniper",  "reb_is_sniper", "reb_is_heavy",
		"reb_b_repulsorliftplant", "reb_p_fusion", "reb_is_sniper",
		"reb_b_repulsorliftplant", "reb_p_fusion", "reb_p_fusion",
		"reb_is_sniper", "reb_p_fusion", "reb_b_barracks",
		"reb_p_fusion", "reb_b_barracks", "reb_d_golan",
		"reb_d_golan", "reb_d_golan", "reb_p_fusion",
		"reb_b_airplant", "reb_is_sniper", "reb_p_fusion",
		"reb_d_atgar", "reb_p_fusion", "reb_is_sniper",
		"reb_b_barracks", "reb_p_fusion", "reb_is_sniper",
		"reb_d_atgar", "reb_p_fusion", "reb_is_sniper",
		"reb_b_repulsorliftplant", "reb_p_fusion", "reb_is_sniper",
		"reb_b_barracks", "reb_b_repulsorliftplant", "reb_is_sniper",
		"reb_d_atgar", "reb_p_fusion", "reb_is_sniper",
	},
}

-- This lists all the units (of all sides) that are considered "base builders"
gadget.baseBuilders = {
	"imp_c_condroid",
	"imp_c_protocon",
	"reb_commander",
	"reb_c_condroid",
	"reb_i_bothan",
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
	"imp_i_reptrooper",
	"imp_i_stormtrooper",
	"imp_i_flametrooper",
	"imp_i_rockettrooper",
	"reb_i_trooper",
	"reb_i_combat",
	"reb_i_mrb",
	"reb_i_wookiee",
}

-- Number of units per side used to cap flags.
gadget.reservedFlagCappers = {
	["galactic empire"] = 18,
	["rebel alliance"] = 18
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
		reb_c_condroid	   = 1,
		reb_c_condroid	   = 1,
		reb_i_bothan	   = 2,
		-- buildings
		imp_b_barracks       = 3,
		imp_b_droidplant     = 5,
		imp_b_vehicleplant   = 1,
		imp_b_airplant       = 1,

	}

elseif (gadget.difficulty == "medium") then

	-- On medium, limit engineers (much) more then on hard.
	gadget.unitLimits = {
		imp_c_protocon       = 1,
		imp_c_condroid	   = 1,
		reb_c_condroid	   = 1,
		reb_i_bothan	   = 2,
		-- buildings
		imp_b_barracks       = 4,
		imp_b_droidplant     = 5,
		imp_b_vehicleplant   = 1,
		imp_b_airplant       = 1,
	}

else

	-- On hard, limit only engineers (because they tend to get stuck if the
	-- total group of engineers and construction vehicles is too big.)
	gadget.unitLimits = {
		reb_c_condroid	   = 2,
		reb_i_bothan	   = 3,
		imp_c_protocon       = 2,
		imp_c_condroid	   = 2,
	}
end
