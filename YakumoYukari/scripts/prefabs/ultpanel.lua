function MakeUltimate(name, value)

	local fname = name.."ult"
	
	local assets=
	{   
		Asset("ANIM", "anim/spell.zip"),   
		Asset("ATLAS", "images/inventoryimages/"..fname..".xml"),    
		Asset("IMAGE", "images/inventoryimages/"..fname..".tex"),
	}

	local function DoUpgrade(inst)
		
		local caster = inst.components.inventoryitem.owner
		local spellcard = inst.components.spellcard
		local index = spellcard.index
		local name = spellcard.name
		local level = spellcard:GetLevel(caster, index)
		local difficulty = GetModConfigData("difficulty", "YakumoYukari")
		local language = GetModConfigData("language", "YakumoYukari")
		local ultreq = 25
		if difficulty == "easy" then ultreq = 20
		elseif difficulty == "hard" then ultreq = 30 end
		
		local str = {}
			str[1] = "I can now evade from death.."
			str[2] = "Now I have the World's power."
			str[3] = "The world is beginning to show with new sights."
			str[4] = "Yes... this is my power I had."
		if language == "chinese" then
			str[1] = "现 在 我 可 以 避 开 死 亡.."
			str[2] = "现 在 我 有 了 世 界 之 力."
			str[3] = "世 界 开 始 以 新 的 视 角 展 现."
			str[4] = "是 的... 这 是 我 的 力 量."
		end
		
		if level >= ultreq then
			if not caster.components.upgrader.ability[index][5] then
				caster.components.talker:Say(str[index])
				caster.components.upgrader.ability[index][5] = true
				caster.components.upgrader:DoUpgrade(caster)
				inst:Remove()
			else
				if caster.components.talker then
					caster.components.talker:Say(GetString(caster.prefab, "DESCRIBE_ABILITY_ALREADY"))
				end
			end
		else
			if caster.components.talker then
				if difficulty == "chinese" then
					caster.components.talker:Say("我 必 须 要 把 "..name.." 升 级 到 "..ultreq.."之 上")
				else
					caster.components.talker:Say("I must do "..name.." upgrade over "..ultreq)
				end
			end
		end
	end
		
	local function fn()  
		
		local inst = CreateEntity()    
		local trans = inst.entity:AddTransform()    
		local anim = inst.entity:AddAnimState()   
		
		MakeInventoryPhysics(inst)   
		if IsDLCEnabled(CAPY_DLC) then    
			MakeInventoryFloatable(inst, "idle", "idle")
		end	
		
		local function IsHanded()
			local hands = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil
			if hands then return false else return true end
		end
		
		local function CallFn()
			inst.components.spellcard:SetCondition( IsHanded() )
		end
		
		anim:SetBank("spell")    
		anim:SetBuild("spell")    
		anim:PlayAnimation("idle")    
		
		inst:AddComponent("inspectable")        
		
		inst:AddComponent("inventoryitem") 
		inst.components.inventoryitem.imagename = fname    
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..fname..".xml"    
		
		inst:AddComponent("spellcard")
		inst.components.spellcard.index = value
		inst.components.spellcard.name = fname
		inst.components.spellcard:SetSpellFn( DoUpgrade )
		inst.components.spellcard:SetCondition( IsHanded() )
		
		GetPlayer():ListenForEvent("equip", CallFn )
		GetPlayer():ListenForEvent("unequip", CallFn )
		
		return inst
	end
	
	return Prefab("common/inventory/"..fname, fn, assets)
end

return MakeUltimate("health", 1),
       MakeUltimate("hunger", 2),
       MakeUltimate("sanity", 3),
       MakeUltimate("power", 4)