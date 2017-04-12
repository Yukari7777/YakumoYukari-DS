local assets_graze =
{
	Asset("ANIM", "anim/graze_fx.zip"),
}

local function kill(inst)
	inst:Remove()
end

local function fn_graze(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst.entity:AddSoundEmitter()
	inst.AnimState:SetBank("graze_fx")
    inst.AnimState:SetBuild("graze_fx")
	inst.AnimState:PlayAnimation("idle")
	inst.persists = false --handled in a special way
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	
	local physics = inst.entity:AddPhysics() -- makes no collision physics
	physics:SetMass(0)
    physics:SetCapsule(0, 0)
	
	inst:AddComponent("locomotor") -- this is the only way to move graze fx, i think.
	inst.components.locomotor.runspeed = math.random(50) / 10
	inst.components.locomotor:RunInDirection(math.random(36) * 10)
	inst.components.locomotor:RunForward()
	
	inst.SoundEmitter:PlaySound("soundpack/spell/graze")
	inst:DoTaskInTime(0.4, kill)
	
	return inst
end

return  Prefab( "fx/graze_fx", fn_graze, assets_graze)