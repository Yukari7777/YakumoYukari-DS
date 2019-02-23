local assets = {
   Asset("ANIM", "anim/barrifield.zip")
}

local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst.components.lighttweener:StartTween(nil, 0, .9, 0.9, nil, .2)
    inst:DoTaskInTime(0.6, function() inst:Remove() end)    
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("barrifield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst:AddTag("FX")

    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(inst.light, 0, .9, 0.9, {1,1,1}, 0)
    inst.components.lighttweener:StartTween(nil, 1.6, .9, 0.9, nil, .2)

    inst.kill_fx = kill_fx

	inst.persists = false
    inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    return inst
end

return Prefab("fx/barrierfield_fx", fn, assets) 