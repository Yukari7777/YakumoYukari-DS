local function YukariIntro(inst)
	local function TakeOff(inst)
		local bird = SpawnPrefab("wallyintro_bird")
		bird.Transform:SetPosition(inst:GetPosition():Get())
		bird.Transform:SetRotation(inst.Transform:GetRotation())
		bird.AnimState:PlayAnimation("takeoff_diagonal_pre")
		local toplayer = (GetPlayer():GetPosition() - inst:GetPosition()):Normalize()

		bird.animoverfn = function()
			bird:RemoveEventCallback("animover", bird.animoverfn)

			bird.AnimState:PlayAnimation("takeoff_diagonal_loop", true)

			bird:DoTaskInTime(2, function() bird:Remove() end)

			bird:DoPeriodicTask(7 * GLOBAL.FRAMES, function()
				bird.SoundEmitter:PlaySound("dontstarve/birds/flyin")
			end)

			bird:DoPeriodicTask(0, function()
				local currentpos = bird:GetPosition()
				local flightspeed = 7.5
				local posdelta = GLOBAL.Vector3(toplayer.x * flightspeed, flightspeed, toplayer.z * flightspeed) * GLOBAL.FRAMES
				local newpos = currentpos + posdelta
				bird.Transform:SetPosition(newpos:Get())
			end)
		end

		bird:ListenForEvent("animover", bird.animoverfn)
		
		local mast = SpawnPrefab("wallyintro_shipmast")
		mast.Transform:SetPosition(inst:GetPosition():Get())
		mast.Transform:SetRotation(inst.Transform:GetRotation())
		
		inst:Remove()
	end
	local PlayPecks = nil
	PlayPecks = function(inst)
		inst:RemoveEventCallback("animover", PlayPecks)
		local peckfn = function() 
			if inst then 
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/parrot/peck") 
			end
		end
		inst:DoTaskInTime(6*GLOBAL.FRAMES, peckfn)
		inst:DoTaskInTime(11*GLOBAL.FRAMES, peckfn)
	end
    if GetPlayer().prefab == "yakumoyukari" then
		if GLOBAL.SaveGameIndex:IsModeShipwrecked() then
			inst.components.maxwelltalker.speeches.SHIPWRECKED_1 = {
				voice = "dontstarve_DLC002/creatures/parrot/chirp",
				idleanim= "idle",
				dialoganim="speak",
				disappearanim = TakeOff,
				disableplayer = true,
				skippable = true,
				{
					string = nil,
					wait = 1,
					anim = "idle",
					pushanim = true,
					sound = nil,
				},
				{
					string = "Who R You",
					wait = 1,
					anim = nil,
					sound = nil,
				},
				{
					string = nil,
					wait = 3,
					anim = "idle_peck",
					pushanim = true,
					sectionfn = function(inst)
						inst:ListenForEvent("animover", PlayPecks)
					end,
				},
				{
					string = "StranGer", 
					wait = 1.5, 
					anim = nil, 
					sound = nil,
				},
				{
					string = nil,
					wait = 2.5,
					anim = "idle_peck",
					pushanim = true,
					sectionfn = function(inst)
						inst:ListenForEvent("animover", PlayPecks)
					end,
				},
				{
					string = "You Better Out", 
					wait = 1.5, 
					anim = nil, 
					sound = nil,
				},
			}
			if Language == "chinese" then
				inst.components.maxwelltalker.speeches.SHIPWRECKED_1 = {
					voice = "dontstarve_DLC002/creatures/parrot/chirp",
					idleanim= "idle",
					dialoganim="speak",
					disappearanim = TakeOff,
					disableplayer = true,
					skippable = true,
					{
						string = nil,
						wait = 1,
						anim = "idle",
						pushanim = true,
						sound = nil,
					},
					{
						string = "       ",
						wait = 1,
						anim = nil,
						sound = nil,
					},
					{
						string = nil,
						wait = 3,
						anim = "idle_peck",
						pushanim = true,
						sectionfn = function(inst)
							inst:ListenForEvent("animover", PlayPecks)
						end,
					},
					{
						string = "          ", 
						wait = 1.5, 
						anim = nil, 
						sound = nil,
					},
					{
						string = nil,
						wait = 2.5,
						anim = "idle_peck",
						pushanim = true,
						sectionfn = function(inst)
							inst:ListenForEvent("animover", PlayPecks)
						end,
					},
					{
						string = "          ", 
						wait = 1.5, 
						anim = nil, 
						sound = nil,
					},
				}
			end
		else
			inst.components.maxwelltalker.speeches.SANDBOX_1 = {
				appearsound = "dontstarve/maxwell/disappear",
				voice = "dontstarve/maxwell/talk_LP_world5",
				appearanim = "appear5",
				idleanim= "idle5_loop",
				dialogpreanim = "dialog5_pre",
				dialoganim="dialog5_loop",
				dialogpostanim = "dialog5_pst",
				disappearanim = "disappear5",
				-- these one gonna make maxwell very very mad.
				disableplayer = true,
				skippable = true,
				{
					string = "OWWWWWWAAAAAAWWWW!!!!!",
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = "HOW THE HECK CAN YOU JUST PASS THROUGH OUR BOUNDARIES?!",
					wait = 4,
					anim = nil,
					sound = nil,
				},
				{
					string = "Well, whatever you were strong or not,",
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = "I just MESSED you up!",
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = "YOU MUST DIE. YOU MUST NOT SURVIVE,",
					wait = 4,
					anim = nil,
					sound = nil,
				},
				{
					string = "BECAUSE OF YOUR GODDAMN WEAKNESS!!",
					wait = 4,
					anim = nil,
					sound = nil,
				},
			}
			if Language == "chinese" then
				inst.components.maxwelltalker.speeches.SANDBOX_1 =
				{
					appearsound = "dontstarve/maxwell/disappear",
					voice = "dontstarve/maxwell/talk_LP_world5",
					appearanim = "appear5",
					idleanim= "idle5_loop",
					dialogpreanim = "dialog5_pre",
					dialoganim="dialog5_loop",
					dialogpostanim = "dialog5_pst",
					disappearanim = "disappear5",
					-- these one gonna make maxwell very very mad.
					disableplayer = true,
					skippable = true,
					{
						string = "哦 哦 哦 哦 哦 哦 哦 哇 啊 啊 啊 啊 哦 哦!!",
						wait = 3,
						anim = nil,
						sound = nil,
					},
					{
						string = "你 是 怎 么 打 破 结 界 来 到 这 里 的?!",
						wait = 4,
						anim = nil,
						sound = nil,
					},
					{
						string = "不 过 没 关 系，无 论 你 以 前 是 否 强 大,",
						wait = 3,
						anim = nil,
						sound = nil,
					},
					{
						string = "我 刚 让 你 变 得 一 团 糟!",
						wait = 3,
						anim = nil,
						sound = nil,
					},
					{
						string = "你 不 可 能 活 下 去，你 必 须 死 ！",
						wait = 4,
						anim = nil,
						sound = nil,
					},
					{
						string = "因 为 你 现 在 很 虚 弱!!",
						wait = 4,
						anim = nil,
						sound = nil,
					},
				}
			end
		end
    end
end
-------------------------------
AddPrefabPostInit("maxwellintro", YukariIntro)                                            
AddPrefabPostInit("wallyintro", YukariIntro)       