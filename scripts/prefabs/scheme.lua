local assets=
{   
	Asset("ANIM", "anim/spell.zip"),    
	Asset("ATLAS", "images/inventoryimages/scheme.xml"),    
}

prefabs = {}

local Ingredients = {
	{{"rocks", 60}, {"log", 60}},
	{{"silk", 30}, {"pigskin", 20}, {"tentaclespots", 10}, {"strawhat", 1}},
	{{"monstermeat", 50}, {"nightmarefuel", 30}, {"livinglog", 20}, {"purplegem", 10}, {"dragon_scales", 1}},
	{{"thulecite", 40}, {"orangegem", 5}, {"greengem", 5}, {"yellowgem", 5}, {"spellcard_away", 10}, {"spellcard_matter", 5}, {"spellcard_balance", 5}, {"spellcard_curse", 3}, {"spellcard_laplace", 3}, {"spellcard_necro", 1}}
}

local Ingredients_sw = {
	{{"rocks", 30}, {"log", 30}, {"bamboo", 10}, {"vine", 10}},
	{{"tar", 30}, {"silk", 20}, {"pigskin", 10}, {"limestone", 10}, {"strawhat", 1}},
	{{"monstermeat", 30}, {"fish", 30}, {"antivenom", 10}, {"quackenbeak", 1}, {"shark_gills", 1}},
	{{"obsidian", 40}, {"dragoonheart", 20}, {"spellcard_away", 10}, {"spellcard_matter", 5}, {"spellcard_balance", 5}, {"spellcard_curse", 3}, {"spellcard_laplace", 3}, {"spellcard_necro", 1}}
}

local function GetIngameName(prefab)
	return STRINGS.NAMES[string.upper(prefab)]
end

local function onsave(inst, data)
	GetPlayer().hatlevel = inst.hatlevel
end

local function onpreload(inst, data)
	inst.hatlevel = GetPlayer().hatlevel
	if data and data.hatlevel then
		inst.hatlevel = data.hatlevel
		data.hatlevel = nil
	end
end

local function GetBackpack()
	local backpack
	local Chara = GetPlayer()
	
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

local function GetTable(inst)
	local difficulty = GetModConfigData("difficulty", "YakumoYukari")
	local hatlevel = inst.hatlevel
	local list = {}
	
	if hatlevel < 5 then
		if SaveGameIndex:IsModeShipwrecked() then
			list = Ingredients_sw[hatlevel]
		else
			list = Ingredients[hatlevel]
		end
		if list[1][2] >= 20 then
			for i = 1, table.maxn(list), 1 do 
				list[i][2] = math.ceil(list[i][2] * 0.25)
			end
		end
	end
	
	return list
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

local function GetStr(inst)
	local list = GetTable(inst)
	local Language = GetModConfigData("language", "YakumoYukari")
	local text = ""
	if inst.hatlevel < 5 then
		for i = 1, table.maxn(list), 1 do
			text = text.."\n"..GetIngameName(list[i][1]).." - "..CountInventoryItem(list[i][1]).." / "..list[i][2]
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

local function GetCondition(inst)
	local list = GetTable(inst)
	local condition = true
	
	if inst.hatlevel < 5 then 
		for i = 1, table.maxn(list), 1 do 
			condition = condition and ( CountInventoryItem(list[i][1]) >= list[i][2] )
		end
	else
		condition = false
	end
	
	return condition
end

local function SetDesc(inst)
	local CurrentLevel = inst.hatlevel
	local condition = GetCondition(inst)
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
	
	local str = "Current Level - "..CurrentLevel..GetStr(inst)..IsHanded()
	if Language == "chinese" then 
		str = "目 前 的 等 级 - "..CurrentLevel..GetStr(inst)..IsHanded()
	end
	
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.SCHEME = str
end

local function SetCondition(inst)
	local condition = GetCondition(inst)
	local hands = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil
	inst.components.spellcard:SetCondition( condition )
	SetDesc(inst)
end

local function DoUpgrade(inst)

	local Chara = GetPlayer()
	local list = GetTable(inst)
	local backpack = GetBackpack()
	
	for i = 1, table.maxn(list), 1 do
		local function consume(item, left_count, backpack)
		
			local Chara = GetPlayer()
			local Inventory = Chara.components.inventory
			for k,v in pairs(Inventory.itemslots) do
				if v.prefab == item then
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
					if v.prefab == item then
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
			if left_count >= 1 then consume(item, left_count, backpack) end
			
		end
		consume(list[i][1], list[i][2], backpack)
	end
	
end

local function OnFinish(inst)
	local Chara = GetPlayer()
	inst.hatlevel = inst.hatlevel + 1
	Chara.hatlevel = inst.hatlevel
	SetCondition(inst)
	Chara.components.upgrader:AbilityManager(Chara)
	Chara.components.upgrader:DoUpgrade(Chara)
	Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_HATUPGRADE"))
end

local function fn()  

	local inst = CreateEntity()    
	local trans = inst.entity:AddTransform()    
	local anim = inst.entity:AddAnimState()    
	local sound = inst.entity:AddSoundEmitter()   

	MakeInventoryPhysics(inst)    
	if IsDLCEnabled(CAPY_DLC) then    
		MakeInventoryFloatable(inst, "idle", "idle")
	end	
	
	anim:SetBank("spell")    
	anim:SetBuild("spell")    
	anim:PlayAnimation("idle")    

	inst:AddTag("irreplaceable")
	inst:AddTag("spellcard")
	inst:AddComponent("inspectable")    
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/scheme.xml"  
	
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("scheme.tex") 
	
	inst:AddComponent("spellcard")
	inst.components.spellcard.name = "scheme"
	inst.components.spellcard:SetSpellFn( DoUpgrade )
	inst.components.spellcard:SetOnFinish( OnFinish )
	inst.components.spellcard:SetCondition( false )
	inst.hatlevel = GetPlayer().hatlevel
	
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("yakumoyukari")
	
	local function callfn()
		SetCondition(inst)
	end
	
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
	SetCondition(inst)
	
	GetPlayer():ListenForEvent("equip", callfn )
	GetPlayer():ListenForEvent("unequip", callfn )
	inst:DoPeriodicTask(1, callfn)
	
	return inst
end
	
return Prefab("common/inventory/scheme", fn, assets, prefabs)