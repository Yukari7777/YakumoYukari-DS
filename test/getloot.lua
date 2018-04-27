local list = {
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
	{"bamboo", math.random(2), "common", nil, "sw"},
	
	{"vine", math.random(2), "common", nil, "rog"},
	{"seashell", math.random(3), "common", nil, "rog"},
}
local loot = {}

function IsModeShipwrecked()
  return true
end

for i=1, #list, 1 do
	-- loot = t
	-- table.remove(loot, i) 
	-- This can't be used because Lua doesn't have hashmap-delete function which means, you can't use 'table.remove's renumbering function.
	if list[i][5] == nil then
		table.insert(loot, list[i])
	elseif IsModeShipwrecked() then
		if list[i][5] == "sw" then
			table.insert(loot, list[i])
		end
	else
		if list[i][5] == "rog" then
			table.insert(loot, list[i])
		end
	end
end

for i, v in pairs(loot) do
    for i2, v2 in pairs(loot[i]) do
      print (i, i2, v, v2)
    end
end