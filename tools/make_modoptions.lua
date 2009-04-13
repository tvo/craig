-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- This LUA script reads ModOptions from stdin and then writes out new
-- modoptions which include the modoption for C.R.A.I.G to stdout.

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  C.R.A.I.G. specific option(s)
--
local extra_options = {
	{
		key    = 'craig_difficulty',
		name   = 'C.R.A.I.G. difficulty level',
		desc   = 'Sets the difficulty level of the C.R.A.I.G. bot.',
		type   = 'list',
		def    = '2',
		items = {
			{
				key = '1',
				name = 'Easy',
				desc = 'No resource cheating.'
			},
			{
				key = '2',
				name = 'Medium',
				desc = 'Little bit of resource cheating.'
			},
			{
				key = '3',
				name = 'Hard',
				desc = 'Infinite resources.'
			},
		}
	},
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function serialize(f, v, lvl)
	if (type(v) == "string") then
		f:write(string.format("%q", v))
	elseif (type(v) == "number") or (type(v) == "boolean") then
		f:write(tostring(v))
	else
		error("unserializable entity: " .. tostring(v))
	end
end

local function serialize_table(f, t, lvl)
	local indent = string.rep("\t", lvl)
	for _,v in ipairs(t) do
		if (type(v) == "table") then
			f:write(indent .. "{\n")
			serialize_table(f, v, lvl + 1)
			f:write(indent .. "},\n")
		else
			f:write(indent)
			serialize(f, v, lvl)
			f:write(",\n")
		end
	end
	for k,v in pairs(t) do
		if (type(k) == "string") then
			f:write(indent)
			f:write(k)
			f:write(" = ")
			if (type(v) == "table") then
				f:write("{\n")
				serialize_table(f, v, lvl + 1)
				f:write(indent .. "},\n")
			else
				serialize(f, v, lvl)
				f:write(",\n")
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local chunk = assert(loadfile("/dev/stdin"))
local options = chunk()

local optionKeys = {}

for i,v in ipairs(options) do
	optionKeys[v.key] = i
end

for _,v in ipairs(extra_options) do
	if (optionKeys[v.key]) then
		options[optionKeys[v.key]] = v
	else
		options[#options+1] = v
	end
end

local f = io.output()

f:write("-- THIS IS A GENERATED FILE, DO NOT EDIT\n\n")
f:write("local options = {\n")

serialize_table(f, options, 1)

f:write("}\n\n")
f:write("return options\n")
