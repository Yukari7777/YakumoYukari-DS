local t = {
	{"cutgrass", math.random(4), "common"},
	{"twigs", math.random(4), "common"},
	{"log", math.random(3), "common"},
	{"rocks", math.random(3), "common"},
	{"flint", math.random(3), "common"},
	{"silk", math.random(3), "common"},
	
	{"sand", math.random(3), "common", nil, "sw"},
	{"palmleaf", math.random(2), "common", nil, "sw"},
	{"seashell", math.random(2), "common", nil, "sw"},
	{"fabric", math.random(2), "common", nil, "sw"},
	{"vine", math.random(2), "common", nil, "sw"},
	{"bamboo", math.random(2), "common", nil, "sw"}, -- 12
	
	{"vine", math.random(2), "common", nil, "rog"},
	{"seashell", math.random(3), "common", nil, "rog"},
}
local loot = {}
local function GetKey(list)
	for i=1, #list, 1 do
		-- loot = t
		-- table.remove(loot, i) 
		-- This can't be used because Lua doesn't have hashmap-delete function which means, you can't use 'table.remove's renumbering function.
		if list[i][5] == nil then
			table.insert(loot, t[i])
		elseif SaveGameIndex:IsModeShipwrecked() and list[i][5] == "sw" then
		elseif not SaveGameIndex:IsModeShipwrecked() and list[i][5] == "rog" then
			table.insert(loot, t[i])
		end
	end
	local value
	if SaveGameIndex:IsModeShipwrecked() then
		value = math.random(#list) -- selects things randomly in table
	else
		local valid = 0
		for i = 1, table.maxn(list) do
			if not list[i][5] then -- check if shipwrecked only
				valid = valid + 1
			end
		end
		value = math.random(valid)
	end
	return value
end