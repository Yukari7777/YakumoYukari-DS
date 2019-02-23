local Ingredients = TUNING.YUKARI.UPGRADEPANEL_INGREDIENT
local Ingredients_sw = TUNING.YUKARI.UPGRADEPANEL_INGREDIENT_SW

local function GetIngameName(prefab)
	return STRINGS.NAMES[string.upper(prefab)]
end

local function GetStatLevel(owner, index)
	return owner.components.upgrader[_G.YUKARISTATINDEX[index].."_level"]
end

local function GetIngreCount(owner, index)
	local difficulty = _G.YUKARI_DIFFICULTY
	local level = GetStatLevel(owner, index) + 1
	
	local a = math.ceil(level * 0.7) + math.min(1, math.floor(level/10)) * math.floor(1.155 ^ (level - 10) ) -- 25 / 267 - 18 / 159
	local b = math.min(1, math.floor(level/10)) * math.floor(1.1336 ^ (level - 10) + 0.2 * (level - 10) ) -- 9 / 64 - 5 / 28 
	if difficulty == "HARD" then
		a = level + math.min(1, math.floor(level/10)) * math.floor(1.162 ^ (level - 10) ) -- 50 / 595
		b = math.min(1, math.floor(level/10)) * math.floor(1.1336 ^ (level - 10) + 0.3 * (level - 10) ) -- 18 / 150
	end
	local c = math.min(1, math.floor(level/20)) * (level - 20) -- 10 / 55
		
	local info = {a,b,c}
	
	return info
end

local function GetTable(index)
	if IsDLCEnabled(GLOBAL.CAPY_DLC) and SaveGameIndex:IsModeShipwrecked() then
		return Ingredients_sw[index]
	else
		return Ingredients[index]
	end
end

local function CountInventoryItem(owner, item)
	local inventory = owner.components.inventory
	local count = 0

	local function countitem(item, count)
		if item.components.stackable ~= nil then
			count = count + item.components.stackable.stacksize
		else 
			count = count + 1
		end
		return count
	end
	
	for k,v in pairs(inventory.itemslots) do
		if v.prefab == item then
			count = countitem(v, count)
		end
	end
	
	for k,v in pairs(inventory.equipslots) do
		if type(v) == "table" and v.components.container then
			for k, v2 in pairs(v.components.container.slots) do
				if v2.prefab == item then
					count = countitem(v2, count)
				end
			end
		end
	end
	
	return count
end

local function GetStr(owner, index)
	local items = GetTable(index)
	local count = GetIngreCount(owner, index)
	local currentLevel = GetStatLevel(owner, index)
	
	local text = ""
	if currentLevel < TUNING.YUKARI_STATUS.MAX_UPGRADE then
		for i = 1, 3, 1 do
			if count[i] > 0 then
				text = text.."\n"..GetIngameName(items[i]).." - "..CountInventoryItem(owner, items[i]).." / "..count[i]
			end
		end
	else
		text = "\n"..STRINGS.YUKARI_UPGRADE_FINISHED
	end

	return text
end

local function GetCanpell(inst, owner)
	local index = inst.index 
	local items = GetTable(index)
	local count = GetIngreCount(owner, index)
	local currentLevel = GetStatLevel(owner, index)

	local condition = owner.components.inventory ~= nil
	if currentLevel < TUNING.YUKARI_STATUS.MAX_UPGRADE then 
		for i = 1, 3, 1 do 
			condition = condition and ( CountInventoryItem(owner, items[i]) >= count[i] )
		end	
	else
		condition = false 
	end

	return condition
end

local function SetCanspell(inst, data)
	local owner = data.owner or data
	local var = GetCanpell(inst, owner)
	inst.components.spellcard:SetCondition(var)
	inst.canspell = var
end

local function GetDesc(inst, viewer)
	if viewer:HasTag("yakumoyukari") then
		local index = inst.index 
		local CurrentLevel = GetStatLevel(viewer, index)
		local condition = GetCanpell(inst, viewer)
		SetCanspell(inst, viewer)

		return string.format( STRINGS.YUKARI_CURRENT_LEVEL.." - "..CurrentLevel..GetStr(viewer, index)..(condition and "\nI can spell." or "") )
	end

	return ""
end

local function DoUpgrade(inst, owner)
	if not GetCanpell(inst, owner) then
		inst.components.spellcard:SetCondition(false)
		inst.canspell:set(false)
		owner.components.talker:Say(GetString(owner.prefab, "DESCRIBE_INGREDIENTS"))
		return false
	end

	local index = inst.index 
	local items = Ingredients[index]
	local count = GetIngreCount(owner, index)
	local inventory = owner.components.inventory
	
	local function remove(item, left_count)
		if left_count > 0 then
			if item.components.stackable ~= nil then
				if item.components.stackable.stacksize >= left_count then
					item.components.stackable:Get(left_count):Remove()
					return 0
				else 
					left_count = left_count - item.components.stackable.stacksize
					item:Remove()
				end
			else 
				left_count = left_count - 1
				item:Remove()
			end
		end
		return left_count
	end

	for i = 1, 3, 1 do -- I won't use RemoveItem function in inventory components because it doesn't get items in custom backpack slot. 
		local left_count = count[i]

		while left_count > 0 do
			for k,v in pairs(inventory.itemslots) do
				if items[i] == "berries" and (v.prefab == "berries" or v.prefab == "berries_juicy") or v.prefab == items[i] then
					left_count = remove(v, left_count)
				end
			end

			for k,v in pairs(inventory.equipslots) do
				if type(v) == "table" and v.components.container ~= nil then
					for k, v2 in pairs(v.components.container.slots) do
						if items[i] == "berries" and (v2.prefab == "berries" or v2.prefab == "berries_juicy") or v2.prefab == items[i] then
							left_count = remove(v2, left_count)
						end
					end
				end
			end
		end
	end

	local stat = _G.YUKARISTATINDEX[index]
	owner.components.upgrader[stat.."_level"] = owner.components.upgrader[stat.."_level"] + 1
	owner.components.talker:Say(GetString(owner.prefab, "DESCRIBE_UPGRADE_"..stat:upper()))

	owner.components.upgrader:ApplyStatus()
end

local function OnFinish(inst, owner)
	local var = GetCanpell(inst, owner)
	inst.components.spellcard:SetCondition(var)
	inst.canspell = var
end

function MakePanel(id)
	local stat = _G.YUKARISTATINDEX[id]
	local fname = stat.."panel"
	local fup = string.upper(stat).."UP"
	
	local assets =
	{   
		Asset("ANIM", "anim/"..fname..".zip"),
		Asset("ATLAS", "images/inventoryimages/"..fname..".xml"),    
		Asset("IMAGE", "images/inventoryimages/"..fname..".tex"),
	}
	
	local function fn()  

		local inst = CreateEntity()    
		inst.entity:AddTransform()    
		inst.entity:AddAnimState()    	
		
		MakeInventoryPhysics(inst)   
		if IsDLCEnabled(CAPY_DLC) then    
			MakeInventoryFloatable(inst, "idle", "idle")
		end	
		
		inst.AnimState:SetBank(fname)    
		inst.AnimState:SetBuild(fname)    
		inst.AnimState:PlayAnimation("idle")

		inst:AddTag("spellcard")

		inst.canspell = false
		inst.index = id

		inst:AddComponent("inspectable")			
		inst.components.inspectable.description = GetDesc

		inst:AddComponent("inventoryitem") 
		inst.components.inventoryitem.imagename = fname    
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..fname..".xml" 	
		
		inst:AddComponent("spellcard")
		inst.components.spellcard.name = fname
		inst.components.spellcard:SetSpellFn( DoUpgrade )
		inst.components.spellcard:SetOnFinish( OnFinish )
		inst.components.spellcard:SetCondition( false )
		
		return inst
	end
	
	return Prefab("common/inventory/"..fname, fn, assets)
end

local panels = {}
for i = 1, 4 do
    table.insert(panels, MakePanel(i))
end

return unpack(panels)