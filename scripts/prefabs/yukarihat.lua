local assets=
{   
	Asset("ANIM", "anim/yukarihat.zip"),    
	Asset("ANIM", "anim/yukarihat_swap.zip"),    
	Asset("ATLAS", "images/inventoryimages/yukarihat.xml"),    
}

prefabs = {}

local function UpdateSound(inst)
	local equipper = inst.components.equippable:IsEquipped() and inst.components.equippable.equipper
    local soundShouldPlay = GetSeasonManager():IsRaining() and equipper and not equipper.sg:HasStateTag("rowing")
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function GetPercentTweak(self)
	if self.condition == 1 then
		return 0 
	end
	return self.condition / self.maxcondition
end

local function MakeIndestructible(inst)
	inst.components.armor.SetCondition = function() return end
	inst.components.armor.GetPercent = GetPercentTweak
	inst.components.armor.condition = 1
end

local function SetAbsorbPercent(inst, percent)
	inst.components.armor.absorb_percent = percent
	inst.components.armor.condition = percent * 100
	inst:PushEvent("percentusedchange", { percent = percent })
end

local function SetSpeedMult(inst, mult)
	inst.components.equippable.walkspeedmult = mult
end

local function SetWaterProofness(inst, val)
	inst.components.waterproofer:SetEffectiveness(val and 1 or 0)
	if val then inst:AddTag("waterproofer") else inst:RemoveTag("waterproofer") end
end

local function SetGasBlocker(inst, val)
	inst.components.equippable.poisonblocker = val	
	inst.components.equippable.poisongasblocker = val
end

local function Initialize(inst)
	inst:RemoveTag("shadowdominance")
	inst:SetWaterProofness(false)
	inst:SetAbsorbPercent(.01)
	inst:SetSpeedMult(1)
	inst:SetGasBlocker(false)
end

local function onequiphat(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "yukarihat_swap", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR") 
	owner:PushEvent("hatequipped", {isequipped = true, inst = inst})
	UpdateSound(inst)
end

local function onunequiphat(inst, owner)
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR") 
	owner:PushEvent("hatequipped", {isequipped = false, inst = inst})
	Initialize(inst)
	UpdateSound(inst)
end

local function fn()  

	local inst = CreateEntity()    

	inst.entity:AddTransform()    
	inst.entity:AddAnimState()    
	inst.entity:AddSoundEmitter()   
	inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("yukarihat.tex")

	MakeInventoryPhysics(inst)    
	if IsDLCEnabled(CAPY_DLC) then    
		MakeInventoryFloatable(inst, "idle", "idle")
	end	
		
	inst.AnimState:SetBank("yukarihat")
	inst.AnimState:SetBuild("yukarihat")
	inst.AnimState:PlayAnimation("idle")   

	inst:AddTag("hat")
	inst:AddTag("yukarihat")

	inst:AddComponent("inspectable")        
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/yukarihat.xml"  
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("armor")
	MakeIndestructible(inst)
	
	inst:AddComponent("equippable")    
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip( onequiphat )
    inst.components.equippable:SetOnUnequip( onunequiphat )
	inst.components.equippable.poisonblocker = false	
	inst.components.equippable.poisongasblocker = false

	inst.Initialize = Initialize
	inst.SetWaterProofness = SetWaterProofness
	inst.SetAbsorbPercent = SetAbsorbPercent
	inst.SetSpeedMult = SetSpeedMult
	inst.SetGasBlocker = SetGasBlocker
	
	return inst
end
	
return Prefab("common/inventory/yukarihat", fn, assets, prefabs)