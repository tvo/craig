local GetGameSeconds = Spring.GetGameSeconds
local GetSelectedUnits = Spring.GetSelectedUnits
local GetCommandQueue = Spring.GetCommandQueue
local GetUnitCommands = Spring.GetUnitCommands
local GetMouseState = Spring.GetMouseState
local GiveOrderToUnit = Spring.GiveOrderToUnit
local SelectUnitArray = Spring.SelectUnitArray

local WorldToScreenCoords = Spring.WorldToScreenCoords
local TraceScreenRay = Spring.TraceScreenRay

local floor = math.floor
local mod = math.fmod
local sqrt = math.sqrt
local getn = table.getn
local insert = table.insert

local glVertex = gl.Vertex
local glBeginEnd = gl.BeginEnd
local glColor = gl.Color
local glLineStipple = gl.LineStipple
local glDrawGroundCircle = gl.DrawGroundCircle

local shiftKey = 304
local controlKey = 306
local altKey = 308
local shiftPressed = false
local controlPressed = false
local altPressed = false
local lmbOld = false
local tweakMode = false
local selectedWayPoints = {}

local noShift = false
local doUpdate = false



function widget:GetInfo()
	return {
		name      = "WaypointDragger",
		desc      = "Enables Waypoint Dragging",
		author    = "Kloot",
		date      = "August 8, 2007",
		license   = "GNU GPL v2",
		layer     = 5,
		enabled   = true
	}
end

function widget:Initialize()
end

function widget:Shutdown()
end



function widget:KeyPress(key, modifier, isRepeat)
	if (modifier.shift) then
		shiftPressed = true
	end
	if (modifier.alt) then
		altPressed = true
	end
	if (modifier.ctrl) then
		controlPressed = true
	end
end

function widget:KeyRelease(key)
	if (key == shiftKey) then
		shiftPressed = false
	end
	if (key == altKey) then
		altPressed = false
	end
	if (key == controlKey) then
		controlPressed = false
	end
end



function GetDist(x, y, p, q)
	local dx = x - p
	local dy = y - q
	return sqrt(dx * dx + dy * dy)
end



function UpdateWayPoints(mx, my)
	local _, coors = TraceScreenRay(mx, my, true)
	local dict = {}

	if (coors ~= nil) then
		local x, y, z = coors[1], coors[2], coors[3]

		for key, waypoint in pairs(selectedWayPoints) do
			local commandNum = waypoint[4]
			local commandID = waypoint[5]
			local commandTag = waypoint[6]
			local unitID = waypoint[7]
			local key = tostring(unitID)
			local b = (dict[key] == nil)

			-- TODO: check if waypoint still valid (if WP
			-- of type CMD_MOVE then unit may have already
			-- reached it when button released) otherwise
			-- we end up inserting new one at end of queue
			if (true) then
				if (b) then
					-- if we have already given an insert order to
					-- this unit, just delete the other waypoints
					-- belonging to it that we've selected (instead
					-- of moving them to the same new position too)
					GiveOrderToUnit(unitID, CMD.INSERT, {commandNum, commandID, 0, x, y, z}, {"alt"})
					dict[key] = 1
				end

				if (not altPressed) then
					-- NOTE: broken for idle factories prior to
					-- Spring r4162 (for move and patrol orders)
					GiveOrderToUnit(unitID, CMD.REMOVE, {commandTag}, {""})
				end
			end
		end
	end
end



function AddWayPoint(waypoint, key)
	selectedWayPoints[key] = waypoint
end

function ClearWayPoints()
	selectedWayPoints = {}
end



function MouseReleased(mx, my)
	-- we were dragging a waypoint and released LMB
	-- while holding shift, finalize new waypoint
	UpdateWayPoints(mx, my)

	-- TODO: reselect all units from before LMB was
	-- released via SelectUnitArray(units) for better
	-- alwaysDrawQueue=1 support
end



function widget:Update(_)
	tweakMode = widgetHandler:InTweakMode()
	doUpdate = (shiftPressed or noShift)

	if (doUpdate) then
		local selUnits = GetSelectedUnits()
		local mx, my, lmb, _, _ = GetMouseState()

		if (not lmb) then
			if (lmbOld) then
				-- we stopped dragging
				MouseReleased(mx, my)
				ClearWayPoints()
			end
			if (not controlPressed) then
				-- if we aren't holding control then
				-- continuously clear all waypoints
				-- so we can drag only one per unit
				ClearWayPoints()
			end
		end

		for i = 1, getn(selUnits) do
			local unitID = selUnits[i]
			local commands = GetCommandQueue(unitID)

			for j = 1, getn(commands) do
				local commandNum = j
				local command = commands[j]
				local commandID = command.id
				local commandTag = command.tag
				local params = command.params
				local options = command.options
				local draggable = (commandID == CMD.MOVE or commandID == CMD.PATROL)

				if (draggable) then
					-- measure distance from waypoint to cursor in screen-coors
					local x, y, z = params[1], params[2], params[3]
					local p, q = WorldToScreenCoords(x, y, z)
					local d = GetDist(mx, my, p, q)

					if (d < 64) then
						local waypoint = {x, y, z, commandNum, commandID, commandTag, unitID}
						local key = tostring(unitID) .. "-" .. tostring(commandNum)

						AddWayPoint(waypoint, key)
					end
				end

			end
		end

		lmbOld = lmb
	end
end



function widget:DrawWorld()
	local mx, my, lmb, _, _ = GetMouseState()
	local _, coors = TraceScreenRay(mx, my, true)

	for _, waypoint in pairs(selectedWayPoints) do
		local x, y, z = waypoint[1], waypoint[2], waypoint[3]
		local p, q = WorldToScreenCoords(x, y, z)
		local d = GetDist(mx, my, p, q)
		local commandID = waypoint[5]

		if (doUpdate and (d < 64 or lmb or controlPressed)) then
			if (commandID == CMD.MOVE) then glColor(0.5, 1.0, 0.5, 0.7) end
			if (commandID == CMD.PATROL) then glColor(0.3, 0.3, 1.0, 0.7) end

			glDrawGroundCircle(x, y, z, 64, 16)
		end

		if (doUpdate and lmb) then
			if (coors ~= nil) then
				-- draw line from waypoint to world-coors of mouse cursor
				local k, l, m = coors[1], coors[2], coors[3]
				local pattern = (65536 - 775)
				local shift = floor(mod(GetGameSeconds() * 16, 16))

				glLineStipple(2, pattern, -shift)
				glBeginEnd(GL.LINES,
					function()
						glVertex(x, y, z)
						glVertex(k, l, m)
					end
				)
				glLineStipple(false)
			end
		end
	end
end
