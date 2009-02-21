-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

--[[
Public interface:

function PathFinder.Dijkstra(graph, source, blocked)
	Returns a dictionary which gives for each vertex the previous vertex
	in a shortest path from source to that vertex, never moving over vertices
	in the blocked set.

function PathFinder.ReverseShortestPath(previous, target)
	Builds an array containing all vertices on the path from target to source.
	Usage: 'local rpath = ReverseShortestPath(Dijkstra(graph, source), target)'

function PathFinder.ShortestPath(previous, target)
	Builds an array containing all vertices on the path from source to target.
	Usage: 'local path = ShortestPath(Dijkstra(graph, source), target)'

function PathFinder.PathIterator(previous, target)
	Equivalent to ipairs(ShortestPath(previous, target)), but less allocations.
	Usage: 'for index, vertex in PathIterator(Dijkstra(graph, source), target)'

The Dijkstra and ShortestPath functions have been separated because Dijkstra
generates the shortest path from source to all vertices in the graph at once.
]]--

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  From gadgets.lua: Reverse integer iterator for reversing reverse paths
--

local function rev_iter(t, key)
  if (key <= 1) then
    return nil
  else
    local nkey = key - 1
    return nkey, t[nkey]
  end
end

local function ripairs(t)
  return rev_iter, t, (1 + #t)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

PathFinder = {}


local function ExtractMin(dist, q)
	local minDist = 1.0e20
	local nearest = nil
	-- TODO: this is the most naive implementation, bumping up the complexity
	-- of Dijkstra below to O(n^2) with n = number of vertices in the graph.
	-- http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
	-- http://lua-users.org/lists/lua-l/2008-03/msg00534.html
	for v,_ in pairs(q) do
		if (dist[v] < minDist) then
			minDist = dist[v]
			nearest = v
		end
	end
	return nearest
end


function PathFinder.Dijkstra(graph, source, blocked)
	local previous = {} -- maps waypoint to previous waypoint on shortest path
	local dist = {}     -- maps waypoint to shortest distance to it
	local q = {}        -- set of all waypoints which still need to be processed

	blocked = (blocked or {})
	if blocked[source] then
		return previous
	end

	for _,v in ipairs(graph) do
		if (not blocked[v]) then
			q[v] = true
			dist[v] = 1.0e20
		end
	end
	dist[source] = 0

	while true do
		local u = ExtractMin(dist, q)
		if (u == nil) then
			return previous
		end
		q[u] = nil
		for v,edge in pairs(u.adj) do
			if (not blocked[v]) then
				local alt = dist[u] + edge
				if (alt < dist[v]) then
					dist[v] = alt
					previous[v] = u
				end
			end
		end
	end
end


function PathFinder.ReverseShortestPath(previous, target)
	local path = {}
	while (target ~= nil) do
		path[#path+1] = target
		target = previous[target]
	end
	return path
end

local ReverseShortestPath = PathFinder.ReverseShortestPath


function PathFinder.ShortestPath(previous, target)
	local path = {}
	for i,v in ripairs(ReverseShortestPath(previous, target)) do
		path[#path+1] = v
	end
	return path
end


function PathFinder.PathIterator(previous, target)
	local t = ReverseShortestPath(previous, target)
	return rev_iter, t, 1 + #t
end


-- some test code (not a complete test!)
if true then
	local function Connect(a, b, edge)
		a.adj[b], b.adj[a] = edge, edge
	end

	local a, b, c = { name = "a", adj = {} }, { name = "b", adj = {} }, { name = "c", adj = {} }
	local graph = {a, b, c}
	Connect(a, b, 10)
	Connect(b, c, 10)

	local blocked = {}
	blocked[b] = true

	local previous = PathFinder.Dijkstra(graph, a, blocked)

	print("'previous' set:")
	for k,v in pairs(previous) do
		print(k.name, "->", v.name)
	end

	print("reverse shortest path:")
	for i,p in pairs(PathFinder.ReverseShortestPath(previous, c)) do
		print(i, p.name)
	end

	print("shortest path:")
	for i,p in pairs(PathFinder.ShortestPath(previous, c)) do
		print(i, p.name)
	end

	print("shortest path, using iterator:")
	for i,p in PathFinder.PathIterator(previous, c) do
		print(i, p.name)
	end
end

return PathFinder
