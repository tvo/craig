--  Custom Options Definition Table format

--  NOTES:
--  - using an enumerated table lets you specify the options order

--
--  These keywords must be lowercase for LuaParser to read them.
--
--  key:      the string used in the script.txt
--  name:     the displayed name
--  desc:     the description (could be used as a tooltip)
--  type:     the option type
--  def:      the default value;
--  min:      minimum value for number options
--  max:      maximum value for number options
--  step:     quantization step, aligned to the def value
--  maxlen:   the maximum string length for string options
--  items:    array of item strings for list options
--  scope:    'all', 'player', 'team', 'allyteam'      <<< not supported yet >>>


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local options = {
	{
		key = 'always_visible_flags',
		name = 'Always Visible Flags',
		desc = 'Flags and their capping status can be seen without LOS',
		type = 'bool',
		def = true,
	},
	--[[{
    key    = 'maxammo_mult',
    name   = 'Vehicle maxammmo multiplier',
    desc   = 'Applies a multiplier to all the vehicle maxammo values',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.1,
  },]]--

  {
    key    = 'command_mult',
    name   = 'Command Point Income/Battle Significance',
    desc   = 'Sets level of Command Point income - use to adjust maps that provide too much or too little command points',
    type   = 'list',
    def    = '2',
    items  =
    {
	  {
        key  = '0',
        name = 'Very Low',
        desc = 'Very limited resources. Nothing but a minor skirmish, you must make the most of what resources you have.',
      },
      {
        key  = '1',
        name = 'Low',
        desc = 'Limited Command Points. This battle is insignificant, and you will be struggling to maintain infantry battalions',
      },
      {
        key  = '2',
        name = 'Normal',
        desc = 'Standard Command Points. The supreme commanders are keeping an eye on the outcome of this engagement. Expect medium numbers of infantry with considerable vehicle support, with armor and gun batteries appearing later.',
      },
      {
        key  = '3',
        name = 'High',
        desc = 'Abundant Command Points. The command has deemed this battle vital. You must win at all costs, and your available resources reflect that urgency.',
      },
	  {
        key  = '4',
        name = 'Very High',
        desc = 'Excessive Command Points. High command has an emotional attachment to your skirmish, and they want it won.',
      },
    },
  },

    {
    key    = 'logistics_mult',
    name   = 'Logistics Resupply Frequency',
    desc   = 'Sets the gap between Logistics Resupply',
    type   = 'list',
    def    = '1',
    items  =
    {
      {
        key  = '0',
        name = 'Low - 7.5 minute gap',
        desc = 'Limited logistics supply. Conservative play - storage buildings and well supplied infantry are the order of the day.',
      },
      {
        key  = '1',
        name = 'Normal - 5 minute gap',
        desc = 'Normal logistics supply. Supplies come on a frequent enough basis to keep the warmachine rumbling, but beware of large artillery batteries or armored thrusts.',
      },
      {
        key  = '2',
        name = 'High - 2.5 minute gap',
        desc = 'Abundant logistics supply. Supply deliveries arrive early and often, allowing for much more aggressive play.',
      },
    },
  },

	--[[{
    key    = 'weapon_range_mult',
    name   = 'Weapon range multiplier',
    desc   = 'Applies a multiplier to all the weapon ranges ingame',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.1,
  },
  {
    key    = 'weapon_reload_mult',
    name   = 'Weapon reload multiplier',
    desc   = 'Applies a multiplier to all the weapon reloadtimes ingame',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.1,
  },
  {
    key    = 'unit_los_mult',
    name   = 'Unit sight (los/airLoS) multiplier',
    desc   = 'Applies a multiplier to all the LoS ranges ingame',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.1,
  },
  {
    key    = 'unit_speed_mult',
    name   = 'Unit speed multiplier',
    desc   = 'Applies a multiplier to all the unit speeds and acceleration values ingame',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.1,
  },
  {
    key    = 'unit_metal_mult',
    name   = 'Metal extraction multiplier',
    desc   = 'Applies a multiplier to all the metal extraction values',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.05,
  },
    {
    key    = 'weapon_aoe_mult',
    name   = 'AoE multiplier',
    desc   = 'Applies a multiplier to all the weapon AoE values',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.05,
  },

   {
    key    = 'weapon_hedamage_mult',
    name   = 'HE damage multiplier',
    desc   = 'Applies a multiplier to all the HE damage values',
    type   = 'number',
    def    = 1.0,
    min	   = 0.1,
    max    = 10,
    step   = 0.05,
  },
  {
    key    = 'weapon_edgeeffectiveness_mult',
    name   = 'Weapon edgeeffectiveness multiplier',
    desc   = 'Applies a multiplier to all the weapon edgeeffectiveness ingame',
    type   = 'number',
    def    = 1.0,
    min	   = 0.01,
    max    = 10,
    step   = 0.1,
  }]]--

  --[[
  {
    key    = 'unit_buildable_airfields',
    name   = 'Airfield enabler',
    desc   = 'Adds/removes airfields from build trees',
    type   = 'number',
    def    = 0,
    min	   = 0,
    max    = 1,
    step   = 1,
  },
    {
    key    = 'unit_hq_platoon',
    name   = 'HQ-centric infantry game',
    desc   = 'Removes rifle/assault squads from barracks, puts them in HQ',
    type   = 'number',
    def    = 0,
    min	   = 0,
    max    = 1,
    step   = 1,
  }]]--

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  C.R.A.I.G. specific option(s)
--
	{
		key    = 'craig_difficulty',
		name   = 'C.R.A.I.G. difficulty level',
		desc   = 'Sets the difficulty level of the C.R.A.I.G. bot.',
		type   = 'list',
		def    = 'hard',
		items = {
			{
				key = 'easy',
				name = 'Easy',
				desc = 'No resource cheating.'
			},
			{
				key = 'medium',
				name = 'Medium',
				desc = 'Little bit of resource cheating.'
			},
			{
				key = 'hard',
				name = 'Hard',
				desc = 'Infinite resources.'
			},
		}
	},
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
}
return options
