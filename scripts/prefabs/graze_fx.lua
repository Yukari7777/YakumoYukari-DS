local assets = {
	Asset("ANIM", "anim/graze_fx.zip"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.entity:AddPhysics() -- minimal setup to move thing. no collision
	inst.Physics:SetMass(1)
	inst.Physics:SetCapsule(0, 1)
	
	inst.AnimState:SetBank("graze_fx")
    inst.AnimState:SetBuild("graze_fx")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetLayer(math.random(2, 4)) -- this is real rendering hack

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst.Transform:SetRotation(math.random() * 360)
	inst.Physics:SetMotorVel(math.random(50)/10, 3, 0)

	inst.SoundEmitter:PlaySound("soundpack/spell/graze")

	inst.persists = false -- handled in a special way
	inst:DoTaskInTime(math.random(), inst.Remove)
	
	return inst
end

return Prefab("fx/graze_fx", fn, assets)