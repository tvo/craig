-- unit names must be lowercase!

-- Format: factory = { "unit to build 1", "unit to build 2", ... }
gadget.unitBuildOrder = UnitBag{
	-- rebel alliance
	reb_b_barracks = UnitArray{
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_bothan", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_w_espo", "reb_w_espo",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_c_condroid", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_bothan", "reb_i_trooper",
		"reb_i_trooper", "reb_i_wookiee",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_wookiee", "reb_w_espo",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_trooper",
		"reb_i_trooper", "reb_w_espo",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_trooper", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_wookiee",
		"reb_i_combat", "reb_w_espo",
		"reb_i_mrb", "reb_i_trooper",
		"reb_i_rockettrooper", "reb_i_trooper",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_w_espo", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
		"reb_i_wookiee", "reb_i_combat",
		"reb_i_combat", "reb_w_espo",
		"reb_i_combat", "reb_i_combat",
		"reb_i_wookiee", "reb_i_combat",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_w_espo", "reb_i_wookiee",
		"reb_i_combat", "reb_i_combat",
		"reb_i_mrb", "reb_i_combat",
		"reb_i_wookiee", "reb_i_wookiee",
		"reb_w_espo", "reb_i_combat",
		"reb_i_combat", "reb_i_combat",
		"reb_i_mrb", "reb_i_wookiee",
	},
	reb_b_repulsorliftplant = UnitArray{
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
	reb_b_airplant = UnitArray{
		"reb_a_z95", "reb_a_z95",
		"reb_a_z95", "reb_a_z95",
		"reb_a_z95", "reb_a_z95",
		"reb_a_awing", "reb_a_z95",
		"reb_a_z95", "reb_a_ywing",
		"reb_a_ywing", "reb_a_ywing",
	},
	-- Imperial Remmnants
	imp_commander = UnitArray{
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
	imp_b_barracks = UnitArray{
		"imp_is_assault", "imp_w_atrt",
		"imp_c_condroid", "imp_d_antiair",
		"imp_w_atrt", "imp_is_heavy",
		"imp_is_defense", "imp_is_assault",
		"imp_w_atrt", "imp_is_assault",
		"imp_w_atrt", "imp_is_heavy",
		"imp_is_defense", "imp_w_atrt",
	},
	imp_b_droidplant = UnitArray{
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
	imp_b_vehicleplant = UnitArray{
		"imp_v_tiecrawler", "imp_v_tiecrawler",
		"imp_v_mobileartillery", "imp_v_tiecrawler",
		"imp_v_tiecrawler", "imp_v_tiecrawler",
		"imp_v_mobileartillery",
	},
	imp_b_airplant = UnitArray{
		"imp_a_tiefighter",
	},
}

-- Format: side = { "unit to build 1", "unit to build 2", ... }
gadget.baseBuildOrder = {
	["galactic empire"] = UnitArray{
		"imp_b_barracks", "imp_p_solar", "imp_p_solar",
		"imp_p_solar", "imp_b_droidplant", "imp_p_solar",
		"imp_b_vehicleplant", "imp_p_solar", "imp_p_solar",
		"imp_p_solar", "imp_d_antiair", "imp_p_solar",
		"imp_b_barracks", "imp_p_estore", "imp_p_fusion",
		"imp_b_droidplant", "imp_p_solar", "imp_b_droidplant",
		"imp_b_vehicleplant", "imp_p_estore", "imp_p_fusion",
		"imp_d_ioncannon", "imp_p_fusion", "imp_b_vehicleplant",
		"imp_b_airplant", "imp_p_estore", "imp_b_barracks",
		"imp_d_ioncannon", "imp_p_fusion", "imp_p_fusion",
		"imp_b_barracks", "imp_p_fusion", "imp_b_barracks",
		"imp_b_barracks", "imp_d_antiair", "imp_p_fusion",
	},
	["rebel alliance"] = UnitArray{
		"reb_b_barracks", "reb_p_fusion", "reb_p_fusion",
		"reb_b_barracks", "reb_p_fusion", "reb_b_barracks",
		"reb_is_heavy",  "reb_p_fusion", "reb_is_heavy",
		"reb_b_airplant", "reb_p_fusion", "reb_is_heavy",
		"reb_b_airplant", "reb_p_fusion", "reb_p_fusion",
		"reb_is_heavy", "reb_p_fusion", "reb_b_airplant",
		"reb_p_fusion", "reb_b_barracks", "reb_d_golan",
		"reb_d_golan", "reb_d_golan", "reb_p_fusion",
		"reb_b_airplant", "reb_is_sniper", "reb_p_fusion",
		"reb_d_atgar", "reb_p_fusion", "reb_is_sniper",
		"reb_b_barracks", "reb_p_fusion", "reb_is_heavy",
		"reb_d_atgar", "reb_p_fusion", "reb_is_heavy",
		"reb_b_repulsorliftplant", "reb_p_fusion", "reb_is_sniper",
		"reb_b_barracks", "reb_b_repulsorliftplant", "reb_is_heavy",
		"reb_d_atgar", "reb_p_fusion", "reb_is_heavy",
	},
}
