local STRINGS = GLOBAL.STRINGS
local FRAMES = GLOBAL.FRAMES
GLOBAL.require "constants_yukari"

local function YukariIntro(inst)
	local function TakeOff(inst)
		local bird = GLOBAL.SpawnPrefab("wallyintro_bird")
		bird.Transform:SetPosition(inst:GetPosition():Get())
		bird.Transform:SetRotation(inst.Transform:GetRotation())
		bird.AnimState:PlayAnimation("takeoff_diagonal_pre")
		local toplayer = (GLOBAL.GetPlayer():GetPosition() - inst:GetPosition()):Normalize()

		bird.animoverfn = function()
			bird:RemoveEventCallback("animover", bird.animoverfn)

			bird.AnimState:PlayAnimation("takeoff_diagonal_loop", true)

			bird:DoTaskInTime(2, function() bird:Remove() end)

			bird:DoPeriodicTask(7 * FRAMES, function()
				bird.SoundEmitter:PlaySound("dontstarve/birds/flyin")
			end)

			bird:DoPeriodicTask(0, function()
				local currentpos = bird:GetPosition()
				local flightspeed = 7.5
				local posdelta = GLOBAL.Vector3(toplayer.x * flightspeed, flightspeed, toplayer.z * flightspeed) * FRAMES
				local newpos = currentpos + posdelta
				bird.Transform:SetPosition(newpos:Get())
			end)
		end

		bird:ListenForEvent("animover", bird.animoverfn)
		
		local mast = GLOBAL.SpawnPrefab("wallyintro_shipmast")
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
		inst:DoTaskInTime(6*FRAMES, peckfn)
		inst:DoTaskInTime(11*FRAMES, peckfn)
	end

    if GLOBAL.GetPlayer():HasTag("yakumoyukari")  then
		local SPEECH = STRINGS.YUKARI_CUSTOM_INTRO_SW
		if GLOBAL.SaveGameIndex:IsModeShipwrecked() then
			inst.components.maxwelltalker.speeches.SHIPWRECKED_1 = {
				voice = "dontstarve_DLC002/creatures/parrot/chirp",
				idleanim = "idle",
				dialoganim = "speak",
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
					string = SPEECH[1],
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
					string = SPEECH[2],
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
					string = SPEECH[3],
					wait = 1.5, 
					anim = nil, 
					sound = nil,
				},
			}
		else
			local SPEECH = STRINGS.YUKARI_CUSTOM_INTRO
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
					string = SPEECH[1],
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = SPEECH[2],
					wait = 4,
					anim = nil,
					sound = nil,
				},
				{
					string = SPEECH[3],
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = SPEECH[4],
					wait = 3,
					anim = nil,
					sound = nil,
				},
				{
					string = SPEECH[5],
					wait = 4,
					anim = nil,
					sound = nil,
				},
				{
					string = SPEECH[6],
					wait = 4,
					anim = nil,
					sound = nil,
				},
			}
		end
    end
end
-------------------------------
AddPrefabPostInit("maxwellintro", YukariIntro)                                            
AddPrefabPostInit("wallyintro", YukariIntro)       