local assets=
{   
	Asset("ANIM", "anim/yukariumbre.zip"),    
	Asset("ANIM", "anim/swap_yukariumbre.zip"),   
	Asset("ANIM", "anim/swap_yukariumbre2.zip"),
	Asset("ATLAS", "images/inventoryimages/yukariumbre.xml"),    
	Asset("IMAGE", "images/inventoryimages/yukariumbre.tex"),
}

prefabs = {}

local function UpdateSound(inst)
    local soundShouldPlay = (GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped() and inst.isunfolded)
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function onuse(staff, pos, caster)

    if caster.components.power then
		if staff.isunfolded then
			caster.components.power:DoDelta(-50, false)
		else
			caster.components.power:DoDelta(-15, false)
		end
    end

end

local function OnEquipYukari(inst, owner)        
	owner.AnimState:OverrideSymbol("swap_object", "swap_yukariumbre", "swap")
	owner.AnimState:Show("ARM_carry")        
	owner.AnimState:Hide("ARM_normal")
	
	inst.components.useableitem.inuse = false -- I HAVE NO IDEA WHY THIS IS NOT WORKING AUTOMATLY.
end    

local function OnUnequipYukari(inst, owner)   
	owner.AnimState:Hide("ARM_carry")        
	owner.AnimState:Show("ARM_normal")
	owner.DynamicShadow:SetSize(1.3, 0.6)	
	UpdateSound(inst)
	
	inst.isunfolded = false
	inst.components.weapon:SetDamage(6)
	inst.components.dapperness.mitigates_rain = false
	inst.components.waterproofer:SetEffectiveness(0)
end    

local function unfoldit(inst)
	local owner = inst.components.inventoryitem.owner
	
	if inst.isunfolded then
		owner:PushEvent("unequip", {item=inst, eslot=EQUIPSLOTS.HANDS})
		owner:PushEvent("equip", {item=inst, eslot=EQUIPSLOTS.HANDS})
		owner.AnimState:OverrideSymbol("swap_object", "swap_yukariumbre", "swap")
		owner.SoundEmitter:PlaySound("dontstarve/wilson/use_umbrella_down")
		owner.DynamicShadow:SetSize(1.3, 0.6)
		inst.components.weapon:SetDamage(6)
		inst.components.dapperness.mitigates_rain = false
		inst.components.waterproofer:SetEffectiveness(0)
		
		inst.isunfolded = false
		UpdateSound(inst)
	else
		owner:PushEvent("unequip", {item=inst, eslot=EQUIPSLOTS.HANDS})
		owner:PushEvent("equip", {item=inst, eslot=EQUIPSLOTS.HANDS})
		owner.AnimState:OverrideSymbol("swap_object", "swap_yukariumbre2", "swap")
		owner.SoundEmitter:PlaySound("dontstarve/wilson/use_umbrella_up") 
		owner.DynamicShadow:SetSize(2.2, 1.4)
		inst.components.weapon:SetDamage(1)
		inst.components.dapperness.mitigates_rain = true
		inst.components.waterproofer:SetEffectiveness(1)
		
		inst.isunfolded = true
		UpdateSound(inst)
	end
	
	inst.components.useableitem.inuse = false
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
	
	anim:SetBank("yukariumbre")    
	anim:SetBuild("yukariumbre")    
	anim:PlayAnimation("idle")  

	inst:AddTag("nopunch")
	inst:AddTag("umbrella")
	inst:AddTag("irreplaceable")
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)
	
	inst:AddComponent("makegate")
	if GetPlayer().components.power then
		inst.components.makegate.onusefn = onuse
	end
	
	inst.isunfolded = false
	
	inst:AddComponent("dapperness")
    inst.components.dapperness.mitigates_rain = false
	
	inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
	
	inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.makegate:GetBlinkPoint()
    end
    inst.components.reticule.ease = true
	
	inst:AddComponent("inspectable")        
	inst:AddComponent("inventoryitem") 
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(6)
	
	inst.components.inventoryitem.imagename = "yukariumbre"    
	inst.components.inventoryitem.atlasname = "images/inventoryimages/yukariumbre.xml"  
	
	inst:AddComponent("equippable")  
	
	inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(unfoldit)
	
	inst.components.equippable:SetOnEquip( OnEquipYukari )    
	inst.components.equippable:SetOnUnequip( OnUnequipYukari )
	
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("yakumoyukari")
	
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("yukariumbre.tex")
	
	inst:ListenForEvent("rainstop", function() UpdateSound(inst) end, GetWorld()) 
	inst:ListenForEvent("rainstart", function() UpdateSound(inst) end, GetWorld()) 
	
	inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

	return inst
end
	
return Prefab("common/inventory/yukariumbre", fn, assets, prefabs)