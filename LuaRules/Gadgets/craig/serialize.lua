-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  SYNCED
--

function DeserializeOrder(msg)
	local b = {msg:byte(1, -1)}

	local unitID = b[1] * 256 + b[2]
	local cmd = b[3] * 256 + b[4] - 32768
	local options = b[5]
	local params = {}

	for i=6,#b,2 do
		params[#params+1] = b[i] * 256 + b[i+1]
	end

	return unitID, cmd, params, options
end

else

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  UNSYNCED
--

CMD.alt = CMD.OPT_ALT
CMD.ctrl = CMD.OPT_CTRL
CMD.shift = CMD.OPT_SHIFT
CMD.right = CMD.OPT_RIGHT


function SerializeOrder(unitID, cmd, params, options)
	if type(options) == "table" then
		local newOptions = 0
		for _,opt in ipairs(options) do
			newOptions = newOptions + CMD[opt]
		end
		options = newOptions
	end

	local b = {}

	b[1] = unitID / 256
	b[2] = unitID % 256
	cmd = cmd + 32768
	b[3] = cmd / 256
	b[4] = cmd % 256
	b[5] = options

	for i=1,#params do
		params[i] = math.floor(params[i])
		b[#b+1] = params[i] / 256
		b[#b+1] = params[i] % 256
	end

	return string.char(unpack(b))
end


function Spring.GiveOrderToUnit(...)
	Spring.SendLuaRulesMsg(SerializeOrder(...))
end

end
