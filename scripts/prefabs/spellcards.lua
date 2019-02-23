local TUNING = TUNING.YUKARI

local function SetInitialCost(inst, cost)
	inst.components.spellcard.costpower = cost
	inst.costpower = cost
end

local function MakeStackableCommon(inst, cost)
	SetInitialCost(inst, cost)
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SPELLCARD
end

local function MakeBuffSpellCommon(inst, uses, costmult)
	SetInitialCost(inst, TUNING.SPELL_POWERCOST_NORMAL * (costmult or 1))
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(uses)
	inst.components.finiteuses:SetUses(uses)
end

local function test(inst)
	MakeStackableCommon(inst, TUNING.SPELLTEST_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		if owner.components.health then
			owner.components.health:DoDelta(20)
		end
		if owner.components.power then
			owner.components.power:DoDelta(-TUNING.SPELLTEST_POWERCOST)
		end
		inst.components.stackable:Get():Remove()
	end)
end

local function mesh(inst)
	MakeStackableCommon(inst, TUNING.SPELLMESH_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		if owner.components.sanity ~= nil then
			owner.components.sanity:SetPercent(1)
			owner.components.sanity:DoDelta(-owner.components.sanity:GetMaxSanity() * owner.components.sanity:GetPercent())
		end
		if owner.components.power ~= nil then
			owner.components.power:DoDelta(-TUNING.SPELLMESH_POWERCOST)
		end
		inst.components.stackable:Get():Remove()
	end)
end

local function away(inst)
	MakeBuffSpellCommon(inst, TUNING.SPELLAWAY_USES)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		owner.components.talker:Say(GetString(owner.prefab, "DESCRIBE_CLOAKING"))
		owner.AnimState:SetMultColour(0.3,0.3,0.3,.3)
	end)
	inst.components.spellcard:SetTaskFn(function(inst, owner)
		local x,y,z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 100)
		for k,v in pairs(ents) do
			if v.components.combat ~= nil and v.components.combat.target == owner then
				v.components.combat.target = nil
			end
		end
		owner.components.power:DoDelta(-TUNING.SPELL_POWERCOST_NORMAL)
		inst.components.finiteuses:Use(1)
	end)
	inst.components.spellcard:SetDoneSpeech("DESCRIBE_DECLOAKING")
	inst.components.spellcard:SetOnRemoveTask(function(inst, owner)
		owner.AnimState:SetMultColour(1,1,1,1)
	end)
	inst.components.finiteuses:SetOnFinished(function()
		inst:Remove()
	end)
end

local function necro(inst)
	MakeStackableCommon(inst, TUNING.SPELLNECRO_POWERCOST)
	inst.components.spellcard.action = ACTIONS.CASTTOHOH
	inst.components.spellcard:SetDoneSpeech("NECRO")
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		local x,y,z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 40)

		for k,v in pairs(ents) do
			v:DoTaskInTime(math.random() * 1.2, function()
				if v.components.health ~= nil and not v:HasTag("player") and not v:HasTag("wall") then
					local maxhealth = v.components.health.maxhealth
					v.components.health:DoDelta(math.min(-maxhealth * 0.33, -500))
				end
				
				if v.components.pickable ~= nil then
					v.components.pickable:MakeBarren()
				end
				
				if v.components.crop ~= nil then
					v.components.crop:MakeWithered()
				end
				
				if (v:HasTag("tree") or v:HasTag("boulder") and not v:HasTag("stump") and not v:HasTag("burnt") and not v:HasTag("mushtree")) and v.components.growable ~= nil then
					v.components.growable:SetStage(4)
				end
				
				if v:HasTag("birchnut")
					or v:HasTag("mole")	
					or v:HasTag("mushtree")
					or v.prefab == "carrot_planted" then
					v:Remove()
				end
				
				if v:HasTag("flower") then
					SpawnPrefab("flower_evil").Transform:SetPosition(v:GetPosition():Get())
					v:Remove()
				end
			end)
		end
			
		if owner.components.power ~= nil then
			owner.components.power:DoDelta(-TUNING.SPELLNECRO_POWERCOST)
		end

		inst.components.stackable:Get():Remove()
	end)
end

local function curse(inst)
	MakeBuffSpellCommon(inst, TUNING.SPELLCURSE_USES, 3)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		inst.olddmg = owner.components.combat.damagemultiplier
		local YukariHat = owner:GetYukariHat()
		if YukariHat ~= nil then
			YukariHat:AddTag("shadowdominance")
		end
		owner.components.hunger.hungerrate = 0
		owner:SetSpellActive("curse", true)
	end)
	inst.components.spellcard:SetTaskFn(function(inst, owner)
		local mult = math.max(3 * (1 - owner.components.sanity:GetPercent()), inst.olddmg)
		owner.components.hunger.hungerrate = 0
		owner.components.sanity:DoDelta(- owner.components.sanity:GetMaxWithPenalty() * 0.025)
		owner.components.power:DoDelta(-TUNING.SPELL_POWERCOST_NORMAL * 1.5)
		owner.components.combat.damagemultiplier = 1 + mult * 0.5
		owner.components.combat:SetAttackPeriod(0)
		owner.components.locomotor.walkspeed = 4 + mult
		owner.components.locomotor.runspeed = 6 + mult
		owner.components.locomotor:SetExternalSpeedMultiplier(inst, "dreadful", 1)
		owner.components.upgrader:ApplyScale("dreadful", 1 + mult * 0.083)
		inst.components.finiteuses:Use(1)
	end, 0.5)
	inst.components.spellcard:SetDoneSpeech("DESCRIBE_NOREINFORCE")
	inst.components.spellcard:SetOnRemoveTask(function(inst, owner)
		local YukariHat = owner:GetYukariHat()
		if YukariHat ~= nil then
			YukariHat:RemoveTag("shadowdominance")
		end
		owner.components.upgrader:ApplyStatus()
		owner:SetSpellActive("curse", false)
	end)
	inst.components.finiteuses:SetOnFinished(function()
		inst:Remove()
	end)
end

local function balance(inst)
	MakeStackableCommon(inst, TUNING.SPELLBALANCE_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		local Inventory = owner.components.inventory
		local rotcnt = 0

		local function refresh(v)
			if v.components.perishable ~= nil then
				local max = v.components.perishable.perishtime 
				v.components.perishable:SetPerishTime(max)
			end

			if v.prefab == "spoiled_food" or v.prefab == "rottenegg" then
				if v.components.stackable ~= nil then
					rotcnt = rotcnt + v.components.stackable:StackSize()
					v:Remove()
				end
			end
		end
			
		for i = 1, rotcnt, 1 do
			owner.components.inventory:GiveItem(SpawnPrefab("wetgoop"))
		end
			
		for k,v in pairs(Inventory.itemslots) do
			refresh(v)
		end

		for k,v in pairs(Inventory.equipslots) do
			if type(v) == "table" and v.components.container ~= nil then
				for k, v2 in pairs(v.components.container.slots) do
					refresh(v2)
				end
			else
				refresh(v)
			end
		end
			
		owner.components.sanity:DoDelta(-TUNING.SPELLBALANCE_SANITYCOST)
		if owner.components.power ~= nil then
			owner.components.power:DoDelta(-TUNING.SPELLBALANCE_POWERCOST)
		end

		inst.components.stackable:Get():Remove()
	end)
end

local function laplace(inst)
	MakeBuffSpellCommon(inst, TUNING.SPELLLAPLACE_USES, 0.5)
	inst.components.spellcard.saydonespeech = true
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		owner:SetSpellActive("laplace", true)
		owner.components.talker:Say(GetString(owner.prefab, "NEWSIGHT"))
		owner.components.sanity:DoDelta(-TUNING.SPELLLAPLACE_SANITYCOST)
	end)
	inst.components.spellcard:SetTaskFn(function(inst, owner)
		local IsWearGoggle = owner.components.inventory.equipslots ~= nil and owner.components.inventory.equipslots["head"] ~= nil and owner.components.inventory.equipslots["head"].prefab == "molehat"
		owner.components.power:DoDelta(-TUNING.SPELL_POWERCOST_NORMAL / 2)
		inst.components.finiteuses:Use(1)
		if IsWearGoggle then
			owner.components.talker:Say(GetString(owner.prefab, "DESCRIBE_EYEHURT"))
			owner.components.combat:GetAttacked(inst, 1)
			owner:SetSpellActive("laplace", false)
			return inst.components.spellcard:ClearTask(owner)
		end
	end)
	inst.components.spellcard:SetOnRemoveTask(function(inst, owner)
		owner:SetSpellActive("laplace", false)
	end)
	inst.components.finiteuses:SetOnFinished(function()
		inst:Remove()
	end)
end

local function butter(inst)
	MakeStackableCommon(inst, TUNING.SPELLNECRO_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		if not (TheWorld.components.butterflyspawner ~= nil and TheWorld.components.birdspawner ~= nil) then
			owner.components.talker:Say(GetString(owner.prefab, "DESCRIBE_NOSPAWN"))
		else
			if owner.components.power ~= nil then
				owner.components.power:DoDelta(-TUNING.SPELLBUTTER_POWERCOST)
			end
			local num = 5 + math.random(5)

			if num > 0 then
				owner:StartThread(function()
					for k = 1, num do
						local pt = TheWorld.components.birdspawner:GetSpawnPoint(Vector3(owner.Transform:GetWorldPosition() ))
						local butter = SpawnPrefab("butterfly")
						butter.Transform:SetPosition(pt.x, pt.y, pt.z)
						butter:AddTag("magicbutter")
					end
				end)
			end
			inst.components.stackable:Get():Remove()
		end
	end)
end

local function bait(inst)
	MakeBuffSpellCommon(inst, TUNING.SPELLBAIT_USES)
	inst.components.spellcard.saydonespeech = true
	local function barrier(inst, owner)
		local fx = SpawnPrefab("barrierfield_fx")
		local fx_hitanim = function()
			fx.AnimState:PlayAnimation("hit")
			fx.AnimState:PushAnimation("idle_loop")
		end
		fx.entity:SetParent(owner.entity)
		fx.AnimState:SetScale(0.7,0.7,0.7)
		fx.AnimState:SetMultColour(0.5,0,0.5,0.3)
		fx.Transform:SetPosition(0, 0.2, 0)
		return fx
	end
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		owner:SetSpellActive("bait", true)
		owner.components.upgrader:ApplyStatus()
		owner.components.talker:Say(GetString(owner.prefab, "TAUNT"))
		inst.fx = barrier(inst, owner)
	end)
	inst.components.spellcard:SetTaskFn(function(inst, owner)
		owner.components.power:DoDelta(-TUNING.SPELL_POWERCOST_NORMAL)
		owner:RemoveTag("realyoukai")
		local x,y,z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 12)
		for k,v in pairs(ents) do
			if v.components.combat and v.components.combat.canattack and v.components.combat.target ~= owner and not v:HasTag("player") then
				v.components.combat:SetTarget(owner)
			end
		end
		inst.components.finiteuses:Use(1)
	end)
	inst.components.spellcard:SetOnRemoveTask(function(inst, owner)
		owner:SetSpellActive("bait", false)
		owner.components.upgrader:ApplyStatus()
		inst.fx:kill_fx()
		inst.fx = nil
	end)
	inst.components.finiteuses:SetOnFinished(function()
		inst:Remove()
	end)
end

local function addictive(inst)
	MakeStackableCommon(inst, TUNING.SPELLADDICTIVE_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		local x, y, z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 60)
		for k, v in pairs(ents) do
			v:DoTaskInTime(math.random() * 1.2, function()
				if v.components.timer ~= nil then 
					v.components.timer:SetTimeLeft("grow") 
				end

				if v.components.witherable ~= nil then
					v.components.witherable:OnRemoveFromEntity()
					v.components.witherable.withered = false
					v:RemoveTag("withered")
					v:RemoveTag("witherable")
				end

				if v.components.diseaseable ~= nil then
					v.components.diseaseable:OnRemoveFromEntity()
					v:RemoveComponent("diseaseable")
				end

				if v.components.pickable ~= nil then
					v.components.pickable.cycles_left = nil
					v.components.pickable.protected_cycles = nil
					v.components.pickable.transplanted = false
					v.components.pickable:Regen()
					if v.components.timer:TimerExists("morphing") or v.components.timer:TimerExists("morphrelay") or v.components.timer:TimerExists("morphdelay") then
						v.components.timer:OnRemoveFromEntity()
						v:RemoveComponent("timer")
					end
					if v.rain ~= nil then
						v.rain = 0
					end
					v:RemoveTag("barren")
					v:RemoveTag("quickpick")
				end
				
				if v.components.hackable ~= nil then
					v:RemoveTag("withered")
					v:RemoveTag("witherable")
					v.components.hackable.withered = false
					v.components.hackable.witherable = false
					v.components.hackable:Regen()
				end

				if v.components.crop ~= nil then
					v.components.crop:DoGrow(2400)
				end
				
				if (v:HasTag("tree") or v:HasTag("boulder") and not v:HasTag("stump") and not v:HasTag("burnt") and not v:HasTag("mushtree")) and v.components.growable ~= nil then
					v.components.growable:SetStage(2)
					v.components.growable:DoGrowth()
				end
				
				if v.components.grower ~= nil then
					v.components.grower.cycles_left = 6
				end
				
				if v.components.burnable ~= nil then
					v.components.burnable:Extinguish()
				end
			end)
		end

		owner.components.sanity:DoDelta(-TUNING.SPELLADDICTIVE_SANITYCOST)
		if owner.components.power then
			owner.components.power:DoDelta(-TUNING.SPELLADDICTIVE_POWERCOST)
		end
		inst.components.stackable:Get():Remove()
	end)
end

local function lament(inst) -- TODO : Recode with StartThread()
	MakeStackableCommon(inst, TUNING.SPELLLAMENT_POWERCOST)
	inst.Activated = false
	local LeftSpawnCount = 0
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		if inst.Activated or owner:IsSpellActive("common") then
			return false
		end

		local function GetLoot(list)
			local loot = {}
			for i=1, #list, 1 do
				if list[i][5] == nil then
					table.insert(loot, list[i])
				else
					if list[i][5] == "rog" then
						table.insert(loot, list[i])
					end
				end
			end
			return loot
		end

		local function GetPoint(pt)
			local theta = math.random() * 2 * PI
			local radius = 6 + math.random() * 6
				
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

		local function SleepNearbyPlayer(prefab, owner)
			prefab:DoTaskInTime(1, function(prefab, owner)
				local x, y, z = prefab.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 15, nil, nil, { "player" })
				for i, v in ipairs(ents) do
					v:PushEvent("yawn", { grogginess = 4, knockoutduration = 15 + math.random() })
				end
			end)
			prefab:DoTaskInTime(2.5, function(prefab)
				prefab:Remove()
			end)
		end

		local LootTable_c = { -- {name, LeftSpawnCount, grade, OnSpawnfunction, WorldTag}
			{"cutgrass", math.random(4), "common"},
			{"twigs", math.random(4), "common"},
			{"log", math.random(3), "common"},
			{"rocks", math.random(3), "common"},
			{"flint", math.random(3), "common"},
			{"silk", math.random(3), "common"},
			{"sand", math.random(3), "common", nil, "sw"},
			{"palmleaf", math.random(2), "common", nil, "sw"},
			{"seashell", math.random(2), "common", nil, "sw"},
			{"fabric", math.random(2), "common", nil, "sw"},
			{"vine", math.random(2), "common", nil, "sw"},
			{"bamboo", math.random(2), "common", nil, "sw"},
		}
		local LootTable_g = {
			{"footballhat", 1, "good", function(prefab) if prefab.components.armor then prefab.components.armor:SetCondition(math.random(prefab.components.armor.maxcondition * 0.66, prefab.components.armor.maxcondition)) end end},
			{"armorwood", 1 , "good", function(prefab) if prefab.components.armor then prefab.components.armor:SetCondition(math.random(prefab.components.armor.maxcondition * 0.66, prefab.components.armor.maxcondition)) end end},
			{"boneshard", math.random(2), "good"},
			{"nitre", math.random(2), "good"},
			{"goldnugget", math.random(3), "good"},
			{"papyrus", math.random(3), "good"},
			{"spidergland", math.random(3), "good"},
			{"livinglog", math.random(2), "good"},
			{"nightmarefuel", math.random(3), "good"},
			{"petals", math.random(2), "good", nil, "rog"},
			{"antivenom", math.random(2), "good", nil, "sw"},
			{"ice", math.random(3, 6), "good", nil, "sw"},
			{"limestone", math.random(2), "good", nil, "sw"},
			{"dubloon", math.random(4, 8), "good", nil, "sw"},
		}
		local LootTable_r = {
			{"gears", math.random(2), "rare"},
			{"redgem", math.random(4), "rare"},
			{"bluegem", math.random(4), "rare"},
			{"purplegem", math.random(4), "rare"},
			{"yellowgem", math.random(2), "rare", nil, "rog"},
			{"orangegem", math.random(2), "rare", nil, "rog"},
			{"greengem", math.random(2), "rare", nil, "rog"},
			{"thulecite", math.random(3), "rare", nil, "rog"},
			{"obsidian", math.random(3), "rare", nil, "sw"},
			{"purplegem", math.random(2), "rare", nil, "sw"},
		}
		local LootTable_b = {
			{"ash", math.random(2), "bad", function() if owner.components.health then owner.components.health:DoDelta(-10, nil, nil, true) end end},
			{"spoiled_food", math.random(2), "bad", function() if owner.components.hunger then owner.components.hunger:DoDelta(-30, nil, true) end end},
			{"rottenegg", math.random(2), "bad", function() if owner.components.hunger then owner.components.hunger:DoDelta(-30, nil, true) end end},
			{"charcoal", math.random(2), "bad", function() if owner.components.sanity then owner.components.sanity:DoDelta(-20) end end},
			{"killerbee", math.random(2), "bad"},
			{"mosquito", 1, "bad", nil, "rog"},
			{"frog", 1, "bad", nil, "rog"},
			{"monkey", 1, "bad", nil, "rog"},
			{"spider_hider", 1, "bad", nil, "rog"},
			{"spider_spitter", 1, "bad", nil, "rog"},
			{"mosquito_poison", 1, "bad", nil, "sw"},
			{"primeape", 1, "bad", nil, "sw"},
			{"spider", math.random(2), "bad", nil, "sw"},
		}
		local LootTable_h = {
			{"ash", math.random(3), "bad", function() if owner.components.health then owner.components.health:DoDelta(-10, nil, nil, true) end end},
			{"spoiled_food", math.random(3), "suck", function() if owner.components.hunger then owner.components.hunger:DoDelta(-50, nil, true) end end},
			{"rottenegg", math.random(3), "suck", function() if owner.components.hunger then owner.components.hunger:DoDelta(-50, nil, true) end end},
			{"charcoal", math.random(3), "suck", function() if owner.components.sanity then owner.components.sanity:DoDelta(-50) end end},	
			{"crawlingnightmare", math.random(2), "suck", function() if owner.components.sanity then owner.components.sanity:DoDelta(-300) end end},
			{"nightmarebeak", 1, "suck",  function() if owner.components.sanity then owner.components.sanity:DoDelta(-300) end end},
			{"killerbee", 6, "suck"},
			{"krampus", math.random(3), "suck"},
			{"panflute", math.random(3), "suck", SleepNearbyPlayer},
			{"deerclops", 1, "suck", function(prefab) prefab:DoTaskInTime(10, function() TheWorld:PushEvent("ms_sendlightningstrike", prefab.Transform:GetWorldPosition()); prefab:Remove()  end) end, "rog"},
			{"mosquito", 4, "suck", nil, "rog"},
			{"mosquito_poison", math.random(3), "suck", nil, "sw"},
		}

		local function GetColor(grade)
			if grade == "common" then
				return {r=0.5,g=0.5,b=0.5,a=1}
			elseif grade == "good" then
				return {r=0,g=1,b=0,a=1}
			elseif grade == "rare" then
				return {r=1,g=0,b=1,a=1}
			elseif grade == "bad" then
				return {r=0.3,g=0.3,b=0.3,a=1}
			elseif grade == "suck" then
				return {r=0,g=0,b=0,a=1}
			end
		end

		local function DoSpawn()
			local naughtiness = owner.naughtiness or 0
			local key, amount, grade, pt, list, loot, speech, color
			local SpawnDelay = LeftSpawnCount > 1 and 0.7 or 1.2
			local thechance = math.random()
			if owner.components.playercontroller ~= nil then
				owner.components.playercontroller:Enable(false)
			end
			owner:DoTaskInTime(SpawnDelay, function()
				if owner.components.playercontroller ~= nil then
					owner.components.playercontroller:Enable(false)
				end
				if LeftSpawnCount > 1 then 
					if naughtiness < 150 then
						if thechance < 0.66 then -- 66%, common stuff
							list = LootTable_c
						elseif thechance < 0.66 then -- 21%, good stuff
							list = LootTable_g
						elseif thechance < 0.66 then -- 7%, rare stuff
							list = LootTable_r
						else							-- 6%, bad stuff
							list = LootTable_b
						end
					elseif naughtiness < 300 then
						if thechance < 0.33 then -- 33%, common stuff
							list = LootTable_c
						elseif thechance < 0.1 then -- 6%, good stuff
							list = LootTable_g
						else							-- 60%, bad stuff
							list = LootTable_b
						end
					else
						list = LootTable_b -- 100%, bad stuff
					end
				else
					speech = GetString(owner.prefab, "LAMENT_B")
					if naughtiness < 200 then
						list = LootTable_b 
					else
						speech = GetString(owner.prefab, "LAMENT_H")
						list = LootTable_h
					end
				end
				loot = GetLoot(list)
				key = math.random(#loot)
				amount = loot[key][2]
				grade = loot[key][3]
				color = GetColor(grade)
				for i = 1, amount do
					owner:DoTaskInTime(LeftSpawnCount > 1 and 0.2 / i or 0, function()
						local prefab = SpawnPrefab(loot[key][1]) -- spawn thing
						local pt = GetPoint(Vector3(owner.Transform:GetWorldPosition()))
						prefab.Transform:SetPosition(pt.x, pt.y, pt.z)
						prefab:AddTag("spawned")
						if prefab.components.lootdropper then
							prefab.components.lootdropper.numrandomloot = 0 -- Delete item drop.
							prefab.components.lootdropper:SetLoot({})
							prefab.components.lootdropper:SetChanceLootTable('nodrop')
						end
						if prefab.components.health ~= nil then
							prefab.persists = false -- This won't be saved.
						end
						if loot[key][4] then
							loot[key][4](prefab, owner)
						end
						local fx = SpawnPrefab("puff_fx")
						fx.AnimState:SetMultColour(color.r, color.g, color.b, color.a)
						fx.Transform:SetPosition(pt.x, pt.y, pt.z)
						if grade == "bad" or grade == "suck" then
							owner.SoundEmitter:PlaySound("dontstarve/HUD/sanity_down")
						else
							owner.SoundEmitter:PlaySound("soundpack/spell/item")
						end
					end)
				end
				if LeftSpawnCount > 1 then 
					LeftSpawnCount = LeftSpawnCount - 1
					DoSpawn()
					if owner.components.playercontroller ~= nil then
						owner.components.playercontroller:Enable(false)
					end
				else
					local x,y,z = owner.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, 30)
					owner.components.health:SetInvincible(false)
					for k,v in pairs(ents) do
						if v.components.combat ~= nil and v:HasTag("spawned") then
							v.components.combat:SetTarget(owner)
						end
					end
					if owner.components.playercontroller ~= nil then
						owner.components.playercontroller:Enable(true)
					end
					owner.naughtiness = owner.naughtiness + 30 + math.random(50)
					owner:DoTaskInTime(0.8, function(owner) owner.components.talker:Say(speech) end)
					LeftSpawnCount = 0
					inst.Activated = false
					owner:SetSpellActive("common", false)
				end
			end)
		end

		inst.Activated = true
		owner:SetSpellActive("common", true)
		local x,y,z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 100)
		if owner.components.playercontroller ~= nil then
			owner.components.playercontroller:Enable(false)
		end
		owner.components.health:SetInvincible(true)
		for k,v in pairs(ents) do
			if v.components.combat and v.components.combat.target == owner then
				v.components.combat.target = nil
			end
		end
		LeftSpawnCount = math.random(3, 7)
		if owner.components.power then
			owner.components.power:DoDelta(-TUNING.SPELLLAMENT_POWERCOST)
		end
		DoSpawn()
		inst.components.stackable:Get():Remove()
	end)
end

local function matter(inst)
	MakeStackableCommon(inst, TUNING.SPELLMATTER_POWERCOST)
	inst.components.spellcard:SetSpellFn(function(inst, owner)
		local Inventory = owner.components.inventory
		local function repair(v)
			if v.components.fueled ~= nil 
			and v.components.fueled.fueltype ~= "MAGIC"	
			and v.components.fueled.fueltype ~= "NIGHTMARE" then
				v.components.fueled:DoDelta(3600)
			end
				
			if v.components.finiteuses ~= nil
			and not v:HasTag("icestaff")
			and not v:HasTag("firestaff")
			and not v:HasTag("spellcard")
			and not v:HasTag("shadow")
			and v.prefab ~= "greenamulet"
			and v.prefab ~= "yellowamulet"
			and v.prefab ~= "orangeamulet"
			and v.prefab ~= "amulet"
			and v.prefab ~= "batbat"
			and not v.components.spellcaster ~= nil 
			and not v.components.blinkstaff ~= nil
			or v.components.instrument ~= nil 
			or v.prefab == "staff_tornado" then
				local maxuse = v.components.finiteuses.total
				v.components.finiteuses:SetUses(maxuse)
			end
				
			if v.components.armor ~= nil and not v:HasTag("sanity") then
				local maxcon = v.components.armor.maxcondition
				v.components.armor:SetCondition(maxcon)
			end
		end
			
		for k,v in pairs(Inventory.itemslots) do
			repair(v)
		end

		for k,v in pairs(Inventory.equipslots) do
			if type(v) == "table" and v.components.container ~= nil then
				for k, v2 in pairs(v.components.container.slots) do
					repair(v2)
				end
			else
				repair(v)
			end
		end

		owner.components.sanity:DoDelta(-TUNING.SPELLMATTER_SANITYCOST)
		if owner.components.power ~= nil then
			owner.components.power:DoDelta(-TUNING.SPELLMATTER_POWERCOST)
		end
		inst.components.stackable:Get():Remove()
	end)
end

local function MakeCard(name)

	local fname = "spellcard_"..name
	
	local assets =
	{   
		Asset("ANIM", "anim/spell_none.zip"),   
		Asset("ATLAS", "images/inventoryimages/"..fname..".xml"),    
		Asset("IMAGE", "images/inventoryimages/"..fname..".tex"),
	}

	local function onfinished(inst)
		inst:Remove()
	end
		
	local function commonfn()  
		local inst = CreateEntity()    
		inst.entity:AddTransform()    
		inst.entity:AddAnimState()   
		
		MakeInventoryPhysics(inst)  
		if IsSWEnabled then    
			MakeInventoryFloatable(inst, "idle", "idle")
		end	
		
		inst.AnimState:SetBank("spell_none")    
		inst.AnimState:SetBuild("spell_none")    
		inst.AnimState:PlayAnimation("idle")    
		
		inst:AddTag("spellcard")

		inst:AddComponent("inspectable")        
		
		inst:AddComponent("inventoryitem") 
		inst.components.inventoryitem.imagename = fname    
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..fname..".xml"   
		
		inst:AddComponent("spellcard")
		inst.components.spellcard.name = name

		if name == "test" then
			test(inst)
		elseif name == "mesh" then
			mesh(inst)
		elseif name == "away" then
			away(inst)
		elseif name == "necro" then
			necro(inst)
		elseif name == "curse" then
			curse(inst)
		elseif name == "balance" then
			balance(inst)
		elseif name == "laplace" then
			laplace(inst)
		elseif name == "butter" then
			butter(inst)
		elseif name == "bait" then
			bait(inst)
		elseif name == "addictive" then
			addictive(inst)
		elseif name == "lament" then
			lament(inst)
		elseif name == "matter" then
			matter(inst)
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