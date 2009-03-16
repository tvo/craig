-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- Currently I'm only configuring the the unitLimits per difficulty level,
-- it's easy however to use a similar structure for the buildorders above.

-- Do not limit units spawned through LUA! (infantry that is build in platoons,
-- deployed supply trucks, deployed guns, etc.)

if (gadget.difficulty == "easy") then

	-- On easy, limit both engineers and buildings until I've made an economy
	-- manager that can tell the AI whether it has sufficient income to build
	-- (and sustain) a particular building (factory).
	-- (AI doesn't use resource cheat in easy)
	gadget.unitLimits = UnitBag{
		-- engineers
		gbrhqengineer        = 2,
		gbrengineer          = 1,
		gbrmatadorengvehicle = 1,
		gerhqengineer        = 2,
		gerengineer          = 1,
		gersdkfz9            = 1,
		ruscommissar         = 4, --2 for flag capping + 2 for base building
		rusengineer          = 2,
		rusk31               = 1,
		ushqengineer         = 2,
		usengineer           = 1,
		usgmcengvehicle      = 1,
		-- buildings
		gbrbarracks    = 3,
		gerbarracks    = 3,
		rusbarracks    = 3,
		usbarracks     = 3,
		ruspshack      = 2, --partisan shack
		gbrgunyard     = 1,
		gbrstorage     = 10,
		gerstorage     = 10,
		russtorage     = 10,
		usstorage      = 10,
		gbrsupplydepot = 1,
		gersupplydepot = 1,
		russupplydepot = 1,
		ussupplydepot  = 1,
		gbrtankyard    = 1,
		gertankyard    = 1,
		rustankyard    = 1,
		ustankyard     = 1,
		gbrvehicleyard = 1,
		gervehicleyard = 1,
		rusvehicleyard = 1,
		usvehicleyard  = 1,
	}

elseif (gadget.difficulty == "medium") then

	-- On medium, limit engineers (much) more then on hard.
	gadget.unitLimits = UnitBag{
		gbrhqengineer        = 3,
		gbrengineer          = 2,
		gbrmatadorengvehicle = 1,
		gerhqengineer        = 3,
		gerengineer          = 2,
		gersdkfz9            = 1,
		ruscommissar         = 5, --2 for flag capping + 3 for base building
		rusengineer          = 2,
		rusk31               = 1,
		ushqengineer         = 3,
		usengineer           = 2,
		usgmcengvehicle      = 1,
	}

else

	-- On hard, limit only engineers (because they tend to get stuck if the
	-- total group of engineers and construction vehicles is too big.)
	gadget.unitLimits = UnitBag{
		gbrengineer          = 7,
		gbrmatadorengvehicle = 1,
		gerengineer          = 7,
		gersdkfz9            = 1,
		rusengineer          = 7,
		rusk31               = 1,
		usengineer           = 7,
		usgmcengvehicle      = 1,
	}
end
