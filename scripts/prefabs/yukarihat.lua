local assets=
{   
	Asset("ANIM", "anim/yukarihat.zip"),    
	Asset("ANIM", "anim/yukarihat_swap.zip"),    
	Asset("ATLAS", "images/inventoryimages/yukarihat.xml"),    
}

prefabs = {}

local function UpdateSound(inst)
    local soundShouldPlay = (GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped() and inst.upgraded)
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function firedmg(amount)
	if GetPlayer().fireimmuned == false and GetPlayer().components.health then
		GetPlayer().components.health.fire_damage_scale = amount
	end
end

local function Ability(inst, owner)

	if owner.components.upgrader:IsHatValid(owner) then
		if owner.hatlevel >= 3 then
			inst.components.dapperness.mitigates_rain = true
			inst.components.waterproofer:SetEffectiveness(1)
		end
		
		if owner.hatlevel >= 4 then
			inst.components.equippable.poisonblocker = true
			inst.components.equippable.poisongasblocker = true
			if not owner.fireimmuned and owner.components.health then
				owner.components.health.fire_damage_scale = 0
			end
		end
	else
		inst.components.dapperness.mitigates_rain = false
		inst.components.waterproofer:SetEffectiveness(0)
		inst.components.equippable.poisonblocker = false
		inst.components.equippable.poisongasblocker = false
		if not owner.fireimmuned == false and owner.components.health then
			owner.components.health.fire_damage_scale = 1
		end
	end
	
end

local function fn()  
	
	local function onequiphat(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", "yukarihat_swap", "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR") 
    end

    local function onunequiphat(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR") 
    end

	local inst = CreateEntity()    
	local trans = inst.entity:AddTransform()    
	local anim = inst.entity:AddAnimState()    
	local sound = inst.entity:AddSoundEmitter()   
	
	MakeInventoryPhysics(inst)    
	if IsDLCEnabled(CAPY_DLC) then    
		MakeInventoryFloatable(inst, "idle", "idle")
	end	
		
	anim:SetBank("yukarihat")    
	anim:SetBuild("yukarihat")    
	anim:PlayAnimation("idle")    

	inst:AddTag("hat")
	inst:AddTag("irreplaceable")
	inst:AddComponent("inspectable")        
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/yukarihat.xml"  
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)
	
	inst:AddComponent("dapperness")
    inst.components.dapperness.mitigates_rain = false	
	
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("yukarihat.tex")
	
	inst:AddComponent("equippable")    
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip( onequiphat )
    inst.components.equippable:SetOnUnequip( onunequiphat )
	inst.components.equippable.poisonblocker = false	
	inst.components.equippable.poisongasblocker = false
	
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("yakumoyukari")
	
	local function CallFn()
		Ability(inst, GetPlayer()) 
	end
	
	inst:DoTaskInTime(0, CallFn)
	GetPlayer():ListenForEvent( "equip", CallFn )
	GetPlayer():ListenForEvent( "unequip", CallFn )
	
	return inst
end
	
return Prefab("common/inventory/yukarihat", fn, assets, prefabs)