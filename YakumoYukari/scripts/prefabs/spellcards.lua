function MakeCard(name)

	local fname = "spellcard_"..name
	
	local assets =
	{   
		Asset("ANIM", "anim/spell.zip"),   
		Asset("ATLAS", "images/inventoryimages/"..fname..".xml"),    
		Asset("IMAGE", "images/inventoryimages/"..fname..".tex"),
	}

	local function onfinished(inst)
		inst:Remove()
	end
		
	local function test(inst)
		inst.components.spellcard.costpower = 5
		inst.components.finiteuses:SetMaxUses(3)
		inst.components.finiteuses:SetUses(3)
		inst.components.spellcard:SetSpellFn(function()
			if GetPlayer().components.health then
				GetPlayer().components.health:DoDelta(20)
			end
			if GetPlayer().components.power then
				GetPlayer().components.power:DoDelta(-5, false)
			end
			inst.components.finiteuses:Use(1)
		end)
	end
	
	local function mesh(inst)
		inst.components.spellcard.costpower = 60
		inst.components.finiteuses:SetMaxUses(3)
		inst.components.finiteuses:SetUses(3)
		inst.components.spellcard:SetSpellFn(function()
			if GetPlayer().components.sanity then
				local amount = GetPlayer().components.sanity:GetMaxSanity() * GetPlayer().components.sanity:GetPercent()
				GetPlayer().components.sanity:SetPercent(1)
				GetPlayer().components.sanity:DoDelta(-amount)
			end
			if GetPlayer().components.power then
				GetPlayer().components.power:DoDelta(-60, false)
			end
			inst.components.finiteuses:Use(1)
		end)
	end
	
	local function away(inst)
		inst.components.spellcard.costpower = 50
		inst.components.finiteuses:SetMaxUses(5)
		inst.components.finiteuses:SetUses(5)
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		inst.IsInvisible = nil
		inst.Duration = 0
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			if inst.IsInvisible == true then
				inst.Duration = inst.Duration + 10
				Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_INVINCIBILITY_DURATION"))
				if Chara.components.power then
					Chara.components.power:DoDelta(-50, false)
				end
				inst.components.finiteuses:Use(1)
			else
				Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_CLOAKING"))
				Chara.AnimState:SetMultColour(0.3,0.3,0.3,.3)
				Chara:AddTag("notarget")
				inst.Duration = 10
				if inst.IsInvisible == nil then -- to prevent DoPeriodicTask overlapping
					Chara:DoPeriodicTask(1, function() -- So, this one is set only once.
						if inst.IsInvisible == true and inst.Duration > 0 then
							local x,y,z = Chara.Transform:GetWorldPosition()
							local ents = TheSim:FindEntities(x, y, z, 100)
							for k,v in pairs(ents) do
								if v.components.combat and v.components.combat.target == Chara then
									v.components.combat.target = nil
								end
							end
						end
						if inst.Duration > 0 then
							inst.Duration = inst.Duration - 1
						end
						if inst.Duration <= 0 and inst.IsInvisible == true then
							Chara:RemoveTag("notarget")
							Chara.AnimState:SetMultColour(1,1,1,1)
							inst.IsInvisible = false
							Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_DECLOAKING"))
						end
					end)
				end
				inst.IsInvisible = true
				if Chara.components.power then
					Chara.components.power:DoDelta(-50, false)
				end
				inst.components.finiteuses:Use(1)
			end
		end)
	end
	
	local function necro(inst)
		inst:RemoveComponent("finiteuses")
		inst.components.spellcard.action = ACTIONS.CASTTOHOH
		inst.components.spellcard.costpower = 300
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local x,y,z = Chara.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x, y, z, 40)
			local Language = GetModConfigData("language", "YakumoYukari")
			SetSharedLootTable('nodrop', {})
			
			for k,v in pairs(ents) do
				if v.components.health and not v:HasTag("yakumoga") then
					if v.components.lootdropper and not v:HasTag("epic") then
						v.components.lootdropper.numrandomloot = 0 -- Delete item drop.
						v.components.lootdropper:SetLoot({})
						v.components.lootdropper:SetChanceLootTable('nodrop')
					end
					v.components.health:DoDelta(-2147483647)
				end
				
				if v.components.pickable then
					v.components.pickable:MakeBarren()
				end
				
				if v.components.crop then
					v.components.crop:MakeWithered()
				end
				
				if v:HasTag("tree") and v.components.growable and not v:HasTag("stump") then
					v.components.growable:SetStage(4)
				end
				
				if v:HasTag("birchnut")
					or v:HasTag("mole")	
					or v.prefab == "carrot_planted" then
					v:Remove()
				end
				
				if v:HasTag("flower") then
					local Evil = SpawnPrefab("flower_evil")
					Evil.Transform:SetPosition(v:GetPosition():Get())
					v:Remove()
				end
				
			end
			-- TODO : Delete moleworm, crab pile -> sand pile
			if Chara.components.power then
				Chara.components.power:DoDelta(-300, false)
			end

			local str = {}
				str[1] = "You were nothing but a piece of paper..."
				str[2] = "Go rest in the void.."
				str[3] = "You were just nothing.."
			if Language == "chinese" then
				str[1] = "你 只 不 过 是 一 张 纸..."
				str[2] = "在 虚 空 中 永 眠 吧.."
				str[3] = "你 什 么 都 不 是.."
			end
			Chara.components.talker:Say(str[math.random(3)])
			inst:Remove()
		end)
	end
	
	local function curse(inst)
		inst.components.spellcard.costpower = 50
		inst.components.finiteuses:SetMaxUses(3)
		inst.components.finiteuses:SetUses(3)
		inst.Duration = 0
		inst.Activated = nil
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local old_dmg = Chara.components.combat.damagemultiplier
			if IsDLCEnabled(CAPY_DLC) then
				old_dmg = Chara.components.combat:GetDamageModifier("yukari_bonus")
			end
			local old_speed = Chara.components.upgrader.bonusspeed
			local isfast = 1
			if Chara:HasTag("realyoukai") then
				isfast = 0
			end
			
			local function GetMultipulier()
				if Chara.components.sanity then
					return 3 * (1 - math.ceil(10 * Chara.components.sanity:GetPercent())/10)
				end
			end
			if inst.Activated == true then
				Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_CANNOTRESIST"))
			else
				inst.Duration = 20
				if inst.Activated == nil then
					Chara:DoPeriodicTask(1, function()
						if inst.Duration > 0 then
							inst.Activated = true
							inst.Duration = inst.Duration - 1
							if Chara:HasTag("inspell") then else
								Chara:AddTag("inspell")
							end
							if inst.Duration == 0 then
								inst.Activated = false
								
								Chara.components.combat.damagemultiplier = 1.2
								if IsDLCEnabled(CAPY_DLC) then
									Chara.components.combat:AddDamageModifier("yukari_bonus", 0.2)
								end
								Chara.components.locomotor.walkspeed = 4
								Chara.components.locomotor.runspeed = 6
								Chara.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
								
								Chara.components.upgrader:DoUpgrade(Chara)
								Chara:RemoveTag("inspell")
								Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_NOREINFORCE"))
							end
						end
						if inst.Activated then
							if Chara.components.sanity then
								Chara.components.sanity:DoDelta(- Chara.components.sanity:GetMaxSanity() * 0.025)
							end
							Chara.components.combat.damagemultiplier = math.max(GetMultipulier(), old_dmg)
							if IsDLCEnabled(CAPY_DLC) then
								Chara.components.combat:AddDamageModifier("yukari_bonus", math.max(GetMultipulier()-1, old_dmg))
							end
							Chara.components.locomotor.walkspeed = 6 + math.max(GetMultipulier(), old_speed)
							Chara.components.locomotor.runspeed = 8 + math.max(GetMultipulier(), old_speed)
							Chara.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD * math.min(1, 1 - GetMultipulier()/3, isfast))
						end
					end)
				end
				if Chara.components.power then
					Chara.components.power:DoDelta(-50, false)
				end
				inst.components.finiteuses:Use(1)
			end
			
		end)
	end
		
	local function balance(inst)
		inst.components.spellcard.costpower = 100
		inst.components.finiteuses:SetMaxUses(5)
		inst.components.finiteuses:SetUses(5)
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local x,y,z = Chara.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x, y, z, 50)
			for k,v in pairs(ents) do
				if v.components.pickable then
					v.components.pickable:FinishGrowing()
				end
				
				if v.components.hackable then
					v.components.hackable:FinishGrowing()
				end
				
				if v.components.crop then
					v.components.crop:DoGrow(TUNING.TOTAL_DAY_TIME*5)
				end
				
				if v:HasTag("tree") and v.components.growable and not v:HasTag("stump") then
					v.components.growable:DoGrowth()
					v.components.growable:SetStage(3) -- tallest
				end
			end
		
			if Chara.components.power then
				Chara.components.power:DoDelta(-100, false)
			end
			inst.components.finiteuses:Use(1)
		end)
	end
	
	local function laplace(inst)
		inst.components.spellcard.costpower = 1
		table.insert(assets, Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"))
		table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_on_cc.tex"))
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_off_cc.tex"))
		inst.components.finiteuses:SetMaxUses(1500)
		inst.components.finiteuses:SetUses(1500)
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		inst.Activated = nil
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			if Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD).prefab == "molehat" then
				Chara.components.talker:Say(GetString(Chara.prefab, "ACTIONFAIL_GENERIC"))
			else
				if inst.Activated == nil then
					Chara:DoPeriodicTask(1, function()
						if inst.Activated then
							if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
								GetClock():SetNightVision(true)
								GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/purple_moon_cc.tex", .5)
							end
							if Chara.components.power and Chara.components.power.current >= 1 then
								Chara.components.power:DoDelta(-1, false)
							else 
								Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_LOWPOWER"))
								if GetWorld() and GetWorld().components.colourcubemanager then
									GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
								end
								GetClock():SetNightVision(false)
								inst.Activated = false
							end
							if Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and Chara.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD).prefab == "molehat" then
								Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_EYEHURT"))
								if Chara.components.combat then
									Chara.components.combat:GetAttacked(inst, 10)
								end
								inst.Activated = false
								 if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
									if GetClock():IsDay() and not GetWorld():IsCave() then
										GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_off_cc.tex", .25)
									else
										GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", .25)
									end
								end
							end
							inst.components.finiteuses:Use(1)
						end
					end)
					inst.Activated = true
					Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_NEWSIGHT"))
				else
					if inst.Activated then
						inst.Activated = false
						if GetWorld() and GetWorld().components.colourcubemanager then
							GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
						end
						GetClock():SetNightVision(false)
					else 
						inst.Activated = true
						Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_NEWSIGHT"))
					end
				end
			end
		end)
		inst.components.finiteuses:SetOnFinished(function()
			if GetWorld() and GetWorld().components.colourcubemanager then
				GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
			end
			inst.Activated = false
			GetClock():SetNightVision(false)
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "DESCRIBE_DONEEFFCT"))
			inst:Remove()
		end)
	end
	
	local function butter(inst)
		inst.components.spellcard.costpower = 80
		inst:RemoveComponent("finiteuses")
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			if not (GetWorld().components.butterflyspawner and GetWorld().components.birdspawner) then
				Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_NOSPAWN"))
			else
				if Chara.components.power then
					Chara.components.power:DoDelta(-80, false)
				end
				local num = 5 + math.random(5)
				
				local x, y, z = Chara.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x,y,z, 12, nil, nil, {'magicbutter'})
				if #ents > 10 then
					num = 0
					Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_TOOMANYBUTTER"))
					return
				end
				
				if num > 0 then
					Chara:StartThread(function()
						for k = 1, num do
							local pt = GetWorld().components.birdspawner:GetSpawnPoint(Vector3(GetPlayer().Transform:GetWorldPosition() ))
							local butter = SpawnPrefab("butterfly")
							butter.Transform:SetPosition(pt.x, pt.y, pt.z)
							butter:AddTag("magicbutter")
						end
					end)
				end
				inst:Remove()
			end
		end)
	end
	
	local function bait(inst) -- name : Bewitching Bait
		inst.components.spellcard.costpower = 1
		inst.components.finiteuses:SetMaxUses(300)
		inst.components.finiteuses:SetUses(300)
		inst.Activated = nil
		local function barrier()
			if inst.fx == nil then 
				local fx = SpawnPrefab("barrierfieldfx")
				local fx_hitanim = function()
				fx.AnimState:PlayAnimation("hit")
				fx.AnimState:PushAnimation("idle_loop")
				end
				fx.entity:SetParent(GetPlayer().entity)
				fx.AnimState:SetScale(0.7,0.7,0.7)
				fx.AnimState:SetMultColour(0.5,0,0.5,0.3)
				fx.Transform:SetPosition(0, 0.2, 0)
				return fx
			else
				return inst.fx
			end
		end
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local fx = barrier()
			inst.fx = fx
			if inst.Activated == nil then
				inst.Activated = true
				Chara:DoPeriodicTask(1, function()
					if inst.Activated then
						if Chara.components.power and Chara.components.power.current >= 1 then
							fx = barrier()
							Chara.components.power:DoDelta(-1, false)
							Chara:AddTag("IsDamage")
							local x,y,z = Chara.Transform:GetWorldPosition()
							local ents = TheSim:FindEntities(x, y, z, 6)
							for k,v in pairs(ents) do
								if v.components.combat and v.components.combat.target ~= Chara then
									v.components.combat.target = Chara
								end
							end
							inst.components.finiteuses:Use(1)
						else 
							Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_LOWPOWER"))
							inst.Activated = false
							fx.kill_fx(inst.fx)
							inst.fx = nil
						end
					else
						Chara:RemoveTag("IsDamage")
					end
				end)
			else
				if inst.Activated then
					inst.Activated = false
					fx.kill_fx(fx)
					inst.fx = nil
				else
					inst.Activated = true -- create barrier
				end
			end
		end)
		inst.components.finiteuses:SetOnFinished(function()
			inst.Activated = false
			fx.kill_fx(fx)
			inst.fx = nil
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "DESCRIBE_DONEEFFCT"))
			inst:Remove()
		end)
	end
	
	local function addictive(inst)
		inst.components.spellcard.costpower = 200
		inst:RemoveComponent("finiteuses")
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local x,y,z = Chara.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x, y, z, 60)
			for k,v in pairs(ents) do
				if v.components.pickable then
					v.components.pickable.withered = false
					v.components.pickable.inst:RemoveTag("withered")
					v.components.pickable.witherable = false
					v.components.pickable.inst:RemoveTag("witherable")
					v.components.pickable.shouldwither = true
					v.components.pickable:Regen()
				end
				
				if v.components.hackable then
					v.components.hackable.withered = false
					v.components.hackable.inst:RemoveTag("withered")
					v.components.hackable.witherable = false
					v.components.hackable.inst:RemoveTag("witherable")
					v.components.hackable.shouldwither = true
					v.components.hackable:Regen()
				end
				
				if v.components.grower then
					v.components.grower.cycles_left = 30
				end
				
				if v.components.burnable then
					v.components.burnable:Extinguish()
				end
			end
			if Chara.components.power then
				Chara.components.power:DoDelta(-200, false)
			end
			inst:Remove()
		end)
	end
	
	local function lament(inst) -- Urashima's Box
		inst:RemoveComponent("finiteuses")
		inst.components.spellcard.costpower = 20
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
		inst.Activated = false
		local count = 0
		local LootTable_c = {
			{"cutgrass", math.random(2, 4), "common"},
			{"twigs", math.random(2, 4), "common"},
			{"log", math.random(1, 3), "common"},
			{"rocks", math.random(1, 3), "common"},
			{"flint", math.random(1, 3), "common"},
			{"silk", math.random(1, 3), "common"},
			-- SW
			{"sand", math.random(1, 3), "common", nil,"sw"},
			{"palmleaf", math.random(1, 2), "common", nil, "sw"},
			{"seashell", math.random(1, 2), "common", nil, "sw"},
			{"fabric", math.random(1, 2), "common", nil, "sw"},
			{"vine", math.random(1, 2), "common", nil, "sw"},
			{"bamboo", math.random(1, 2), "common", nil, "sw"},
		}
		local LootTable_g = {
			{"footballhat", 1, "good", function(prefab) if prefab.components.armor then prefab.components.armor:SetCondition(math.random(prefab.components.armor.maxcondition * 0.66, prefab.components.armor.maxcondition)) end end},
			{"armorwood", 1 , "good", function(prefab) if prefab.components.armor then prefab.components.armor:SetCondition(math.random(prefab.components.armor.maxcondition * 0.66, prefab.components.armor.maxcondition)) end end},
			{"petals", 2, "good"},
			{"boneshard", 1, "good"},
			{"nitre", 2, "good"},
			{"goldnugget", 3, "good"},
			{"papyrus", 3, "good"},
			{"spidergland", 3, "good"},
			{"livinglog", math.random(1, 2), "good"},
			{"nightmarefuel", math.random(1, 3), "good"},
			-- SW
			{"antivenom", 2, "good", nil, "sw"},
			{"ice", math.random(3, 6), "good", nil, "sw"},
			{"limestone", math.random(1, 2), "good", nil, "sw"},
			{"dubloon", math.random(4, 8), nil, "good", "sw"},
		}
		local LootTable_r = {
			{"gears", 2, "rare"},
			{"redgem", 2, "rare"},
			{"bluegem", 2, "rare"},
			{"purplegem", 2, "rare"},
			{"yellowgem", 1, "rare"},
			{"orangegem", 1, "rare"},
			{"greengem", 1, "rare"},
			{"thulecite", math.random(1, 3), "rare"},
			-- SW
			{"obsidian", math.random(2,4), "rare", nil,"sw"},
			{"purplegem", 2, "rare", nil, "sw"}, -- gives additional chance
		}
		local LootTable_b = {
			{"ash", 2, "bad"},
			{"spoiled_food", 2, "bad"},
			{"charcoal", 1, "bad"},
			{"rottenegg", 1, "bad"},
			{"monkey", 1, "bad"}, 
			{"mosquito", 1, "bad"},
			{"frog", 1, "bad"},
			{"spider_hider", 1, "bad"},
			{"spider_spitter", 1, "bad"}
		}
		local LootTable_h = {
			{"killerbee", 4, "bad"},
			{"Krampus", 1, "bad"},
			{"tallbird", 1, "bad"},
			{"crawlingnightmare", 1, "bad"},
			{"nightmarebeak", 1, "bad"},
			{"deerclops", 1, "bad", function(prefab) prefab:Remove(); GetSeasonManager():DoLightningStrike(TheInput:GetWorldPosition()) end},
		}
		local function spawn() -- TODO : makes character stop while spelling
			local Chara = GetPlayer()
			if GetPlayer().components.kramped.threshold == nil then
				GetPlayer().components.kramped.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
			end -- just in case
			local threshold = GetPlayer().components.kramped.threshold
			local actions = GetPlayer().components.kramped.actions
			local naughtiness = actions / threshold -- just percentage
			local key, amount, grade, pt, name
			local function GetPoint(pt)
				local theta = math.random() * 2 * PI
				local radius = 6+math.random()*6
				
				local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
					local ground = GetWorld()
					local spawn_point = pt + offset
					if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE) then
						return true
					end
					return false
				end)
				
				if result_offset then
					return pt+result_offset
				end
			end
			if count > 1 then
				Chara:DoTaskInTime(0.5, function()
					if naughtiness < 0.33 then
						if math.random() < 0.66 then -- 66%, common stuff
							name = LootTable_c
						elseif math.random() < 0.66 then -- 21%, good stuff
							name = LootTable_g
						elseif math.random() < 0.66 then -- 7%, rare stuff
							name = LootTable_r
						else							-- 6%, bad stuff
							name = LootTable_b
						end
					elseif naughtiness < 0.66 then
						if math.random() < 0.33 then -- 33%, common stuff
							name = LootTable_c
						elseif math.random() < 0.1 then -- 6%, good stuff
							name = LootTable_g
						else							-- 60%, bad stuff
							name = LootTable_b
						end
					else
						name = LootTable_b -- 100%, bad stuff
					end
					local function GetKey(name)
					
						local value
						
						if SaveGameIndex:IsModeShipwrecked() then
							value = math.random(table.maxn(name))
						else
							local valid = 0
							for i = 1, table.maxn(name) do
								if not name[i][5] then
									valid = valid + 1
								end
							end
							value = math.random(valid)
						end
						
						return value
					end
					local key = GetKey(name)
					amount = name[key][2]
					grade = name[key][3]
					local color = {}
					if grade == "common" then
						color = {r=0,g=0,b=0,a=0.5}
					elseif grade == "good" then
						color = {r=0,g=1,b=0,a=1}
					elseif grade == "rare" then
						color = {r=1,g=0,b=1,a=1}
					elseif grade == "bad" then
						color = {r=0,g=0,b=0,a=1}
					end
					for i = 1, amount do
						local prefab = SpawnPrefab(name[key][1])
						prefab:AddTag("spawned")
						pt = GetPoint(Vector3(GetPlayer().Transform:GetWorldPosition()))
						if name[key][4] then
							name[key][4](prefab) -- problem
						end
						local fx = SpawnPrefab("small_puff")
						fx.AnimState:SetMultColour(color.r, color.g, color.b, color.a)
						fx.Transform:SetPosition(pt.x, pt.y, pt.z)
						if grade ~= "bad" then
							Chara.SoundEmitter:PlaySound("soundpack/spell/item")
						else
							Chara.SoundEmitter:PlaySound("dontstarve/HUD/sanity_down")
						end
						prefab.Transform:SetPosition(pt.x, pt.y, pt.z)
					end
					count = count - 1
					spawn()
				end)
			elseif count == 1 then
				Chara:DoTaskInTime(1.2, function()
					if naughtiness < 0.8 then
						name = LootTable_b 
					else
						name = LootTable_h
					end
					local key = math.random(table.maxn(name))
					amount = name[key][2]
					grade = name[key][3]
					for i = 1, amount do
						local prefab = SpawnPrefab(name[key][1])
						prefab:AddTag("spawned")
						pt = GetPoint(Vector3(GetPlayer().Transform:GetWorldPosition()))
						if name[key][4] then
							name[key][4](prefab)
						end
						local fx = SpawnPrefab("small_puff")
						fx.AnimState:SetMultColour(0,0,0,1)
						fx.Transform:SetPosition(pt.x, pt.y, pt.z)
						Chara.SoundEmitter:PlaySound("dontstarve/HUD/sanity_down")
						prefab.Transform:SetPosition(pt.x, pt.y, pt.z)
					end
					 
					Chara.components.kramped:OnNaughtyAction( math.min(threshold - (actions + 1), math.random(4, 9)) )
					-- So Naughty points can be gained until 'threshold - 1' so that prevent spawning Krampus.
					local x,y,z = Chara.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, 14)
					for k,v in pairs(ents) do
						if v.components.combat and v:HasTag("spawned")then
							v.components.combat.target = Chara
						end
					end
					Chara:RemoveTag("notarget")
					count = count - 1
					Chara.components.health:SetInvincible(false)
					Chara.components.playercontroller:Enable(true)
					Chara.components.talker:Say(GetString(Chara.prefab, "ANNOUNCE_TRAP_WENT_OFF"))
					inst.Activated = false
				end)
			end
		end
		inst.components.spellcard:SetSpellFn(function()
			if inst.Activated then
				GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ACTIONFAIL_GENERIC"))
			else
				inst.Activated = true
				local Chara = GetPlayer()
				local x,y,z = Chara.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 100)
				Chara.components.playercontroller:Enable(false)
				Chara.components.health:SetInvincible(true)
				for k,v in pairs(ents) do
					if v.components.combat and v.components.combat.target == Chara then
						v.components.combat.target = nil
					end
				end
				Chara:AddTag("notarget")
				count = math.random(4, 6)
				if Chara.components.power then
					Chara.components.power:DoDelta(-20, false)
				end
				spawn()
				inst.components.stackable:Get():Remove()
			end
		end)
	end
	
	local function matter(inst) -- Universe of Matter and Antimatter
		inst.components.spellcard.costpower = 150
		inst.components.finiteuses:SetMaxUses(2)
		inst.components.finiteuses:SetUses(2)
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		inst.components.spellcard:SetSpellFn(function()
			local Chara = GetPlayer()
			local Inventory = Chara.components.inventory
			
			local function repair(v)
				
				if v.components.fueled 
				and not v.components.fueled.fueltype == "MAGIC"	
				and not v.components.fueled.fueltype == "NIGHTMARE" then
					  v.components.fueled:DoDelta(1)
				end
				
				if v.components.finiteuses
				and not v:HasTag("icestaff")
				and not v:HasTag("firestaff")
				and not v:HasTag("spellcard")
				and not v:HasTag("shadow")
				and not v.prefab == "greenamulet"
				and not v.prefab == "yellowamulet"
				and not v.prefab == "orangeamulet"
				and not v.prefab == "amulet"
				and not v.components.spellcaster
				and not v.components.blinkstaff then
					local maxuse = v.components.finiteuses.total
					v.components.finiteuses:SetUses(maxuse)
				end
				
				if v.components.armor and not v:HasTag("sanity") then
					local maxcon = v.components.armor.maxcondition
					v.components.armor:SetCondition(maxcon)
				end
			end
			
			for k,v in pairs(Inventory.itemslots) do
				repair(v)
			end
			for k,v in pairs(Inventory.equipslots) do
				repair(v)
			end
			
			if Chara.components.power then
				Chara.components.power:DoDelta(-150, false)
			end
			inst.components.finiteuses:Use(1)
		end)
	end
	
	local function commonfn()  
		
		local inst = CreateEntity()    
		local trans = inst.entity:AddTransform()    
		local anim = inst.entity:AddAnimState()   
		
		MakeInventoryPhysics(inst)   
		
		anim:SetBank("spell")    
		anim:SetBuild("spell")    
		anim:PlayAnimation("idle")    
		
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetOnFinished( onfinished )
		
		inst:AddTag("spellcard")
		inst:AddComponent("inspectable")        
		
		inst:AddComponent("inventoryitem") 
		inst.components.inventoryitem.imagename = fname    
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..fname..".xml"    
		
		inst:AddComponent("spellcard")
		inst.components.spellcard.name = name
		
		local fn = nil
		if name == "test" then
			fn = test(inst)
		elseif name == "mesh" then
			fn = mesh(inst)
		elseif name == "away" then
			fn = away(inst)
		elseif name == "necro" then
			fn = necro(inst)
		elseif name == "curse" then
			fn = curse(inst)
		elseif name == "balance" then
			fn = balance(inst)
		elseif name == "laplace" then
			fn = laplace(inst)
		elseif name == "butter" then
			fn = butter(inst)
		elseif name == "bait" then
			fn = bait(inst)
		elseif name == "addictive" then
			fn = addictive(inst)
		elseif name == "lament" then
			fn = lament(inst)
		elseif name == "matter" then
			fn = matter(inst)
		end
		
		return inst
	end
	
	return Prefab("common/inventory/"..fname, commonfn, assets)
end

return MakeCard("test"),
	   MakeCard("mesh"),
	   MakeCard("away"),
	   MakeCard("necro"),
	   MakeCard("curse"),
	   MakeCard("balance"),
	   MakeCard("laplace"),
	   MakeCard("butter"),
	   MakeCard("bait"),
	   MakeCard("addictive"),
	   MakeCard("lament"),
	   MakeCard("matter")
	   