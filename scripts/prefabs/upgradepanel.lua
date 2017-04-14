local Ingredients = {
	{"spidergland", "healingsalve", "bandage"},
	{"berries", "meatballs", "bonestew"},
	{"petals", "nightmarefuel", "livinglog"},
	{"goldnugget", "purplegem", "thulecite"}
}

local Ingredients_sw = {
	{"spidergland", "healingsalve", "bandage"},
	{"berries", "fishsticks", "surfnturf"},
	{"petals", "taffy", "livinglog"},
	{"goldnugget", "nightmarefuel", "obsidian"}
}

local function GetIngameName(prefab)
	return STRINGS.NAMES[string.upper(prefab)]
end

local function GetIndex(inst)
	local utype = inst.components.spellcard.name
	if utype == "healthpanel" then return 1
	elseif utype == "hungerpanel" then return 2
	elseif utype == "sanitypanel" then return 3
	elseif utype == "powerpanel" then return 4
	end
end

local function GetStatLevel(index)
	if index == 1 then return GetPlayer().health_level
	elseif index == 2 then return GetPlayer().hunger_level
	elseif index == 3 then return GetPlayer().sanity_level
	elseif index == 4 then return GetPlayer().power_level
	end
end

local function GetIngreCount(index)
	-- this contains Ingredient's formula
	local difficulty = GetModConfigData("difficulty", "YakumoYukari")
	local level = (GetStatLevel(index) or 0) + 1
	
	local a = math.ceil(level * 0.7) + math.min(1, math.floor(level/10)) * math.floor(1.155 ^ (level - 10) ) -- 25 / 267 - 18 / 159
	local b = math.min(1, math.floor(level/10)) * math.floor(1.1336 ^ (level - 10) + 0.2 * (level - 10) ) -- 9 / 64 - 5 / 28 
	if difficulty == "hard" then
		a = level + math.min(1, math.floor(level/10)) * math.floor(1.162 ^ (level - 10) ) -- 50 / 595
		b = math.min(1, math.floor(level/10)) * math.floor(1.1336 ^ (level - 10) + 0.3 * (level - 10) ) -- 18 / 150
	end
	local c = math.min(1, math.floor(level/20)) * (level - 20) -- 10 / 55
		
	local info = {a,b,c}
	
	return info
	
end

local function GetTable(index)
	if SaveGameIndex:IsModeShipwrecked() then
		return Ingredients_sw[index]
	else
		return Ingredients[index]
	end
end

local function GetBackpack()
	local Chara = GetPlayer()
	local backpack
	
	if EQUIPSLOTS.BACK and Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK) then -- check if backpack slot mod is enabled.
		backpack = Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
	elseif Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) 
	and Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY).components.container then
		backpack = Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	end
	
	if backpack and backpack.components.container then 
		return backpack.components.container 
	end
end

local function CountInventoryItem(prefab)
	local inventory = GetPlayer().components.inventory
	local backpack = GetBackpack()
	local count = 0
	
	for k,v in pairs(inventory.itemslots) do
		if v.prefab == prefab then
			if v.components.stackable then
				count = count + v.components.stackable.stacksize
			else 
				count = count + 1
			end
		end
	end
	
	if backpack then
		for k,v in pairs(backpack.slots) do
			if v.prefab == prefab then
				if v.components.stackable then
					count = count + v.components.stackable.stacksize
				else 
					count = count + 1
				end
			end
		end
	end
	
	return count
end

local function GetStr(index)
	local items = GetTable(index)
	local count = GetIngreCount(index)
	local CurrentLevel = GetStatLevel(index) or 0
	local Language = GetModConfigData("language", "YakumoYukari")
	local difficulty = GetModConfigData("difficulty", "YakumoYukari")
	local maxlevel = 25
	if difficulty == "easy" then
		maxlevel = 20
	elseif difficulty == "hard" then
		maxlevel = math.huge -- um... 
	end
	local text = ""
	
	if CurrentLevel < maxlevel then
		for i = 1, 3, 1 do
			if count[i] > 0 then
				text = text.."\n"..GetIngameName(items[i]).." - "..CountInventoryItem(items[i]).." / "..count[i]
			end
		end
	else
		if Language == "chinese" then
			text = "\n升 级 完 成"
		else
			text = "\nUpgrade Finished"
		end
	end

	return text
end

local function GetCondition(index)

	local items = GetTable(index)
	local count = GetIngreCount(index)
	local CurrentLevel = GetStatLevel(index) or 0
	local difficulty = GetModConfigData("difficulty", "YakumoYukari")
	local maxlevel = 25
	if difficulty == "easy" then
		maxlevel = 20
	elseif difficulty == "hard" then
		maxlevel = math.huge
	end
	local condition = true
	
	if CurrentLevel < maxlevel then 
		for i = 1, 3, 1 do 
			condition = condition and ( CountInventoryItem(items[i]) >= count[i] )
		end	
	else
		condition = false 
	end
	
	return condition
	
end

local function SetDesc(index)
	local CurrentLevel = GetStatLevel(index) or 0
	local condition = GetCondition(index)
	local Language = GetModConfigData("language", "YakumoYukari")
		
	local function IsHanded()
		local hands = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil
		if hands and condition then
			if Language == "chinese" then
				return "\n我 手 里 必 须 拿 点 东 西."
			else
				return "\nI should bring something on my hand."
			end
		else
			return ""
		end
	end
	
	local str = "Current Level - "..CurrentLevel..GetStr(index)..IsHanded()
	if Language == "chinese" then 
		str = "目 前 的 等 级 - "..CurrentLevel..GetStr(index)..IsHanded()
	end
	
	if index == 1 then STRINGS.CHARACTERS.GENERIC.DESCRIBE.HEALTHPANEL = str
	elseif index == 2 then STRINGS.CHARACTERS.GENERIC.DESCRIBE.HUNGERPANEL = str
	elseif index == 3 then STRINGS.CHARACTERS.GENERIC.DESCRIBE.SANITYPANEL = str
	elseif index == 4 then STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWERPANEL = str
	end
	
end

local function SetCondition(inst)
	local index = GetIndex(inst)
	local condition = GetCondition(index)
	inst.components.spellcard:SetCondition( condition )
	SetDesc(index)
end

local function DoUpgrade(inst)
	
	local backpack = GetBackpack()
	local Chara = GetPlayer()
	local index = GetIndex(inst)
	local items = GetTable(index)
	local count = GetIngreCount(index)
	local inventory = Chara.components.inventory
	
	for i = 1, 3, 1 do
		local function consume(name, left_count, backpack)
			
			for k,v in pairs(inventory.itemslots) do
				if v.prefab == name[i] then
					if v.components.stackable then
						if v.components.stackable.stacksize >= left_count then
							v.components.stackable:Get(left_count):Remove()
							left_count = 0
						else 
							v:Remove()
							left_count = left_count - v.components.stackable.stacksize
						end
					else 
						v:Remove()
						left_count = left_count - 1
					end
				end
			end
			
			if backpack then
				for k,v in pairs(backpack.slots) do
					if v.prefab == name[i] then
						if v.components.stackable then
							if v.components.stackable.stacksize >= left_count then
								v.components.stackable:Get(left_count):Remove()
								left_count = 0
							else 
								v:Remove()
								left_count = left_count - v.components.stackable.stacksize
							end
						else 
							v:Remove()
							left_count = left_count - 1
						end
					end
				end
			end
			if left_count >= 1 then consume(name, left_count, backpack) end
			
		end
		consume(items, count[i], backpack)
	end
	
	Chara.components.upgrader:DoUpgrade(Chara, index)
	
end

function MakePanel(iname)

	local fname = iname.."panel"
	local fup = string.upper(iname).."UP"
	
	local assets =
	{   
		Asset("ANIM", "anim/"..fname..".zip"),
		Asset("ATLAS", "images/inventoryimages/"..fname..".xml"),    
		Asset("IMAGE", "images/inventoryimages/"..fname..".tex"),
	}
	
	local function fn()  

		local inst = CreateEntity()    
		local trans = inst.entity:AddTransform()    
		local anim = inst.entity:AddAnimState()    		
		
		MakeInventoryPhysics(inst)   
		if IsDLCEnabled(CAPY_DLC) then    
			MakeInventoryFloatable(inst, "idle", "idle")
		end	
		
		anim:SetBank(fname)    
		anim:SetBuild(fname)    
		anim:PlayAnimation("idle")   

		inst:AddTag("spellcard")
		inst:AddComponent("inspectable")			
		
		inst:AddComponent("inventoryitem") 
		inst.components.inventoryitem.imagename = fname    
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..fname..".xml" 	
		
		inst:AddComponent("spellcard")
		inst.components.spellcard.name = fname
		inst.components.spellcard:SetSpellFn( DoUpgrade )
		inst.components.spellcard:SetCondition( false )
		
		inst:DoPeriodicTask(1, SetCondition)
		
		return inst
	end
	
	return Prefab("common/inventory/"..fname, fn, assets)
end

return MakePanel("health"),
       MakePanel("hunger"),
       MakePanel("sanity"),
       MakePanel("power")