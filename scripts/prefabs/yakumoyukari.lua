local MakePlayerCharacter = require "prefabs/player_common"
local STATUS = TUNING.YUKARI_STATUS
local CONST = TUNING.YUKARI

local assets = {
	Asset("ANIM", "anim/yakumoyukari.zip"),    
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SOUND", "sound/willow.fsb"),
	Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),
}

local prefabs = { }

-- Custom starting items
local function GetStartInv()
	local difficulty = _G.YUKARI_DIFFICULTY
	if difficulty == "EASY" then
		return {"meat",
				"meat",
				"meat",
				"meat",
				"meat",
				"scheme",
				"yukarisumbre",
				"yukarihat"}
	else return {"scheme",
				"yukariumbre",
				"yukarihat"}
	end
end

local start_inv = GetStartInv()

local important_items = {
	"yukarisumbre",
	"yukarihat",
	"scheme",
}

local function onsave(inst, data)
	data.regen_cool = inst.regen_cool
	data.poison_cool = inst.poison_cool
	data.invin_cool = inst.invin_cool
	data.grazecnt = inst.grazecnt
	data.naughtiness = inst.naughtiness
	data.health_level = inst.components.upgrader.health_level
	data.hunger_level = inst.components.upgrader.hunger_level
	data.sanity_level = inst.components.upgrader.sanity_level
	data.power_level = inst.components.upgrader.power_level
	data.skilltree = inst.components.upgrader.ability
	data.HatLevel = inst.components.upgrader.HatLevel
end

local function onpreload(inst, data)
	if data then
		if inst.components.power then
			inst.regen_cool = data.regen_cool or 0 
			inst.poison_cool = data.poison_cool or 0 
			inst.invin_cool = data.invin_cool or 0 
			inst.grazecnt = data.grazecnt or 0
			inst.components.upgrader.health_level = data.health_level or 0 
			inst.components.upgrader.hunger_level = data.hunger_level or 0
			inst.components.upgrader.sanity_level = data.sanity_level or 0 
			inst.components.upgrader.power_level = data.power_level or 0	
			inst.components.upgrader.HatLevel = data.HatLevel or 1
			inst.components.upgrader.ability = data.skilltree or {}
			inst.components.upgrader:ApplyStatus()

			--re-set these from the save data, because of load-order clipping issues
			if data.health ~= nil and data.health.health ~= nil then inst.components.health.currenthealth = data.health.health end
			if data.hunger ~= nil and data.hunger.hunger ~= nil then inst.components.hunger.current = data.hunger.hunger end
			if data.sanity ~= nil and data.sanity.current ~= nil then inst.components.sanity.current = data.sanity.current end
			if data.power ~= nil and data.power.current ~= nil then inst.components.power.current = data.power.current end
			inst.components.health:DoDelta(0)
			inst.components.hunger:DoDelta(0)
			inst.components.sanity:DoDelta(0)
			inst.components.power:DoDelta(0)
		end
	end
end

local function CompatiblePatch(inst)
	rawset(_G, "IsHamletEnabled", IsDLCEnabled(PORKLAND_DLC))
	rawset(_G, "IsShipwreckedEnabled", SaveGameIndex:IsModeShipwrecked())
	rawset(_G, "IsRoGEnabled", PrefabExists("acorn"))
	rawset(_G, "DLC_ENABLED_FLAG", (_G.IsRoGEnabled and 1 or 0) + (_G.IsShipwreckedEnabled and 2 or 0) + (_G.IsHamletEnabled and 4 or 0))
	rawset(_G, "IsVanilla", _G.DLC_ENABLED_FLAG == 0)

	if not _G.IsRoGEnabled then
		inst.components.health.SetAbsorptionAmount = inst.components.health.SetAbsorbAmount

		function inst.components.temperature.GetInsulation(self)
			local insulation = 0

			insulation = insulation + self.inherentinsulation

			if self.inst.components.inventory then
				for k,v in pairs (self.inst.components.inventory.equipslots) do
					if v.components.insulator then
						insulation = insulation + v.components.insulator.insulation
					end
				end
			end

			return insulation, 0
		end
	end

	inst.components.health.GetMaxWithPenalty = inst.components.health.GetPenaltyPercent

	local _GetString = GetString
	GetString = function(character, stringtype, ...)
		if type(character) == "table" then
			character = string.upper(character.prefab)
		end

		return _GetString(character, stringtype, ...)
	end

	inst:DoTaskInTime(0, function()
		if not _G.IsShipwreckedEnabled and handlers then
			local keys = {"KEY_4", "KEY_5", "KEY_6"}
			for k, v in pairs(keys) do 
				handlers[_G[v]] = {}
			end
		end
	end)
end	

local function GetEquippedYukariHat(inst)
	return inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD).prefab == "yukarihat" and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
end

local function IsPreemitive(ent)
	return ent.components.combat ~= nil and ent.components.combat.target ~= nil
end

local function OnAttackOther(inst, data)
	local target = data.target
	if target == nil then return end
	local CanAOE = inst.components.upgrader.IsAOE and math.random() < 0.4

	if inst.components.upgrader.IsVampire then
		if target.components.health ~= nil and not target:HasTag("chester") and not target:HasTag("wall") and not target:HasTag("companion") then
			inst.components.health:DoDelta(1, nil, nil, true)
			if CanAOE then
				inst.components.health:DoDelta(1, nil, nil, true)
			end
		end
	end

	if CanAOE and (data.weapon == nil or data.weapon.components.projectile == nil) then	
		inst.components.combat:DoAreaAttack(target, CONST.AOE_RADIUS, data.weapon, IsPreemitive, data.stimuli, { "INLIMBO", "companion", "wall" })
	end
end

local function TelePortDelay(inst)
	inst:DoTaskInTime(0.5, function()
		inst.istelevalid = true 
	end)
end

local function DoPowerRestore(inst, amount)
	local delta = amount * inst.components.upgrader.PowerGainMultiplier
	inst.components.power:DoDelta(delta)
	--inst.HUD.controls.status.power:PulseGreen() 
	--inst.HUD.controls.status.power:ScaleTo(1.3,1,.7)
end

local function CurePoison(inst)
	if inst.components.poisonable and inst.components.upgrader.IsPoisonCure then
		inst.components.poisonable:Cure(inst)
	end
end

local function MakeInvincible(inst)
	inst.components.upgrader.CanbeInvincibled = false
	inst.invin_cool = STATUS.INVINCIBLE_COOLTIME
	inst.IsInvincible = true
	inst.components.health:SetInvincible(true)
	inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_INVINCIBILITY_ACTIVATE"), nil, nil, true, nil, {1,0,0,1})
	inst:DoTaskInTime(10, function()
		inst.IsInvincible = false
		inst.components.health:SetInvincible(false)
		inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_INVINCIBILITY_DONE"))
	end)
end

local function OnHealthDelta(inst, data)
	if inst.components.upgrader.InvincibleLearned 
	and inst.components.upgrader.CanbeInvincibled
	and inst.components.health.currenthealth <= math.max(30, inst.components.health:GetMaxWithPenalty() * 0.15) then
		MakeInvincible(inst)
	end
end

local function HealthRegen(inst)
	if inst.components.health ~= nil then
		inst.components.health:DoDelta(inst.components.upgrader.RegenAmount)
	end
end

local function InvincibleRegen(inst)
	if inst.components.health ~= nil and inst.IsInvincible then
		inst.components.health:DoDelta(inst.components.upgrader.EmergencyRegenAmount, nil, nil, true)
	end
end

function OnHungerDelta(inst, data)
	if inst.components.combat ~= nil then
		local dmgmult = CONST.BASE_DAMAGE_MULT + math.max(data.newpercent - (1 - inst.components.upgrader.PowerUpValue * CONST.POWERUP_MULT), 0)
		local scale = CONST.BASE_SCALE + (dmgmult - CONST.BASE_DAMAGE_MULT) * CONST.SCALING_MULT
		inst.components.combat.damagemultiplier = dmgmult

		inst.components.upgrader:ApplyScale("dreadful", scale)
	end
end

local function SetLight(inst, var)
	if var then
		local gappercent = math.min((var - 0.9) * 100, 1)
		local powerpercent = inst.components.power ~= nil and inst.components.power:GetPercent() or 0
		inst.Light:SetRadius((1 + powerpercent * 3) * gappercent);inst.Light:SetFalloff((.9 - powerpercent * 0.25) * gappercent);inst.Light:SetIntensity(0.3);inst.Light:SetColour((127 + powerpercent * 128) * gappercent/255,0,(127 + powerpercent * 128)/255 * gappercent);inst.Light:Enable(true)
	else
		inst.Light:SetRadius(0);inst.Light:Enable(false)
	end
end

local function OnSanityDelta(inst, data)
	if inst.components.upgrader.NightVision and (GetClock():IsNight() or GetWorld():HasTag("cave")) and inst.sleepingbag == nil then
		local sanitypercent = data.newpercent
		if sanitypercent > CONST.NIGHT_VISION_SANITY then
			inst:SetLight(sanitypercent)
		else
			inst:SetLight(false)
		end
	else
		inst:SetLight(false)
	end
end

local function GetPoint(pt)
	local theta = math.random() * 2 * PI
	local radius = CONST.SIGHT_RADIUS + math.random() * CONST.SIGHT_RADIUS
	
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

local function Cooldown(inst)
	if inst.components.upgrader.ability[1][2] then
		if inst.regen_cool > 0 then
			inst.regen_cool = inst.regen_cool - 1
		elseif inst.regen_cool == 0 
		and inst.components.health ~= nil 
		and inst.components.health:IsHurt() 
		and inst.components.hunger:GetPercent() > CONST.REGEN_HEALTH then
			HealthRegen(inst)
			inst.regen_cool = inst.components.upgrader.RegenCool
		end
	end

	if inst.invin_cool > 0 then
		inst.invin_cool = inst.invin_cool - 1
	elseif inst.invin_cool == 0 then
		inst.components.upgrader.CanbeInvincibled = true
	end

	if inst.naughtiness > 0 then
		inst.naughtiness = inst.naughtiness - 1
	end
end

local function PeriodicFunction(inst, data)
	inst.components.sanity.night_drain_mult = 1 - inst.components.upgrader.ResistDark - (inst.components.upgrader.HatEquipped and CONST.HAT_NIGHT_DRAIN_ABSORB_MULT or 0)

	if inst.components.health ~= nil then
		if inst.IsInvincible then
			InvincibleRegen(inst)
		end
	end

	Cooldown(inst)
	
	if inst.components.upgrader.SightDistance and inst.components.upgrader.SightDistance > 0 then
		local dis = inst.components.upgrader.SightDistance
		local pt = GetPoint(Vector3(GetPlayer().Transform:GetWorldPosition()))
		GetWorld().minimap.MiniMap:ShowArea(pt.x, pt.y, pt.z, 50 * dis)
		GetWorld().Map:VisitTile(GetWorld().Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z))
	end
end

local function Graze(inst)
	if inst.components.upgrader.Ability_45 and not inst.IsGrazing then
		inst.IsGrazing = true
		inst:DoTaskInTime(0.75, function(inst)
			inst.IsGrazing = false
		end)
	end
	local pt = Vector3(inst.Transform:GetWorldPosition())
	for i = 1, math.random(3, 10) do
		local fx = SpawnPrefab("graze_fx")
		fx.Transform:SetPosition(pt.x + math.random() / 2, pt.y + 0.7 + math.random() / 2 , pt.z + math.random() / 2 )
	end
	inst.grazecnt = inst.grazecnt + 1
	DoPowerRestore(inst, math.random(0, 2))
end

local powertable = {
	-- Rule : 10 per meat value 1, reduced by 25% when cooked or dried.
	P300 = {"minotaurhorn", "deerclops_eyeball", "tigereye"},
	P100 = {"humanmeat"},
	P80 = {"humanmeat_cooked", "humanmeat_dried"},
	P40 = {"surfnturf"},
	P30 = {"bonestew", "dragoonheart", "trunk_winter"},
	P25 = {"baconeggs"},
	P20 = {"honeyham", "tallbirdegg", "trunk_summer", "turkeydinner", "monsterlasagna"},
	P15 = {"tallbirdegg_cooked", "trunk_cooked", "honeynuggets", "hotchili"},
	P10 = {"meat", "plantmeat", "shark_fin", "fish", "fish_med", "perogies", "guacamole", "monstermeat"},
	P8 = {"meat_dried", "plantmeat_cooked", "fish_med_cooked"},
	P5 = {"smallmeat", "eel", "kabobs", "tropical_fish", "batwing", "froglegs", "bird_egg", "fish_raw_small", "meatballs", "frogglebunwich", "unagi", "drumstick" , "doydoyegg"},
	P4 = {"monstermeat_dried", "cookedsmallmeat","froglegs_cooked","batwing_cooked", "fish_raw_small_cooked", "cookedmonstermeat", "smallmeat_dried", "eel_cooked", "doydoyegg_cooked", "drumstick_cooked", "bird_egg_cooked"}
}

local function oneat(inst, food)
	local key

	for k, v in pairs(powertable) do
		for k2, v2 in pairs(v) do 
			if food.prefab == v2 then
				key = k
				local delta = tonumber(string.sub(key, 2))
				if food.components.perishable ~= nil then
					delta = delta - delta * ( (1 - food.components.perishable:GetPercent()) * STATUS.POWER_RESTORE_PERISH_MULT )
				end 

				DoPowerRestore(inst, delta)
				break
			end
		end
	end
end

local function MakeSaneOnEatMeat(inst)
	local _Eat = inst.components.eater.Eat
	function inst.components.eater.Eat(self, food)
		if self:CanEat(food) then
			if food.components.edible.foodtype == "MEAT" and food.components.edible.sanityvalue < 0 then
				food.components.edible.sanityvalue = 0
			end
			if food.prefab == "humanmeat" or food.prefab == "humanmeat_cooked" or food.prefab == "humanmeat_dried" then
				food.components.edible.sanityvalue = TUNING.SANITY_LARGE
				food.components.edible.healthvalue = TUNING.HEALING_MED
				inst:PushEvent("makefriend") -- Just for sound effect
				inst:DoTaskInTime(math.random() * 0.5, function()
					inst.components.talker:Say(GetString(inst.prefab, "ONEATHUMAN"))
				end)
			end
		end
		return _Eat(self, food)
	end
end

local function MakeToolEfficient(item)
	function item.components.tool.GetEffectiveness(self, action)
		local owner = item.components.inventoryitem ~= nil and item.components.inventoryitem.owner
		if owner ~= nil and owner.components.upgrader ~= nil and owner.components.upgrader.IsEfficient and action ~= ACTIONS.HAMMER then
			return self.actions[action] * 1.5 or 0
		end
		return self.actions[action] or 0
	end
end

local function MakeGrazeable(inst)
	local _ApplyDamage = inst.components.inventory.ApplyDamage
	function inst.components.inventory.ApplyDamage(self, damage, attacker, weapon)
		local totaldodge = (inst.components.upgrader.DodgeChance + inst.components.upgrader.HatDodgeChance) * (inst.sg:HasStateTag("moving") and 2 or 1) -- double when is moving
		local candodge = inst.IsGrazing or math.random() < totaldodge and inst.components.freezeable == nil and not inst.components.health:IsInvincible() and (attacker ~= nil and attacker.components ~= nil and attacker.components.combat ~= nil)

		if candodge then
			inst:PushEvent("graze")
			return 0
		end
		return _ApplyDamage(self, damage, attacker, weapon)
	end
end

local function MakeDapperOnEquipItem(inst)
	local _Recalc = inst.components.sanity.Recalc
	function inst.components.sanity.Recalc(self, dt)
		local NumBeforeCalc = 0
		for k, v in pairs(self.inst.components.inventory.equipslots) do
			if v.components.equippable ~= nil then
				local itemdap = v.components.equippable:GetDapperness(self.inst)
				NumBeforeCalc = itemdap < 0 and NumBeforeCalc + itemdap * self.inst.components.upgrader.SanityAbsorption or NumBeforeCalc
			end
		end
		self.dapperness = NumBeforeCalc ~= 0 and -NumBeforeCalc or 0
		return _Recalc(self, dt)
	end
end

local function OnEquipHat(inst, data)
	inst.components.upgrader.HatEquipped = data.isequipped
end

local ShouldApplyStatus = {
	"armordragonfly", "armorobsidian", "yukarihat"
}

local function OnEquip(inst, data) 
	local item = data ~= nil and data.item ~= nil and data.item or nil
	if item == nil then return end

	if inst.components.upgrader ~= nil and inst.components.upgrader.IsEfficient and data.eslot == EQUIPSLOTS.HANDS and item.components.tool ~= nil then
		MakeToolEfficient(item)
	end
	
	local ShouldApply = false
	for k, v in pairs(ShouldApplyStatus) do
		if item.prefab == v then
			ShouldApply = true
			break
		end
	end

	if ShouldApply then
		-- I don't like how Klei sets the fire_damage_scale.
		inst.components.upgrader.FireImmuned = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY).prefab == "armordragonfly"

		if item.prefab == "yukarihat" then
			inst.components.upgrader:ApplyHatAbility(item)
		end
		inst.components.upgrader:ApplyStatus()
	end
end

local function OnSetLaplace(inst, val)
	if val then
		GetClock():SetNightVision(true)
		GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/purple_moon_cc.tex", .5)
	else
		GetClock():SetNightVision(false)
		GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
	end
end

local function SetSpellActive(inst, key, val)
	inst._spellsactive[key] = val

	if key == "laplace" then
		OnSetLaplace(inst, val)
	end
end

local function IsSpellActive(inst, key)
	return inst._spellsactive[key] == true -- return false if false or nil.
end

local function OnContinue()
	if math.random() < 0.15 then
		GetPlayer().components.talker:Say(GetString(GetPlayer(), "UNPAUSED"))
	end
end

local function DebugFunction(inst)
	inst:DoPeriodicTask(1, function()
		if inst.components.power ~= nil and inst.infpower then
			inst.components.power.max = 300
			inst.components.power.current = 300
		end
		inst.components.hunger.current = 250
		--inst.components.hunger:Pause(true)
		--inst.components.health:SetInvincible(true)
	end)
end	

local fn = function(inst)
	CompatiblePatch(inst)
	inst.entity:AddLight()

	inst:AddTag("youkai")
	inst:AddTag("yakumoga")
	inst:AddTag("yakumoyukari")

	inst.MiniMapEntity:SetIcon( "yakumoyukari.tex" )

	inst:AddComponent("upgrader")
	inst:AddComponent("power")
	
	inst.IsInvincible = false
	inst.IsGrazing = false
	inst.naughtiness = 0
	inst.regen_cool = 0
	inst.poison_cool = 0
	inst.invin_cool = 0
	inst.grazecnt = 0
	inst.infopage = 0
	inst._spellsactive = {}
	
	require("recipes_yukari")
	inst.soundsname = "willow"
	inst.components.sanity:SetMax(75)
	inst.components.health:SetMaxHealth(80)
	inst.components.hunger:SetMax(150)
	inst.components.hunger.hungerrate = 1.5 * TUNING.WILSON_HUNGER_RATE
	inst.components.combat.damagemultiplier = CONST.BASE_DAMAGE_MULT
	if _G.DLC_ENABLED_FLAG >= 2 then
		inst.components.combat:AddDamageModifier("dreadful", CONST.BASE_DAMAGE_MULT - 1)
	end
	inst.components.combat.areahitdamagepercent = CONST.AOE_DAMAGE_PERCENT
	inst.components.builder.science_bonus = 1
	inst.components.eater:SetOnEatFn(oneat)
	
	MakeSaneOnEatMeat(inst)
	MakeGrazeable(inst)
	MakeDapperOnEquipItem(inst)
	
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
	inst.GetYukariHat = GetEquippedYukariHat
	inst.SetLight = SetLight
	inst.SetSpellActive = SetSpellActive
	inst.IsSpellActive = IsSpellActive

	inst:DoPeriodicTask(1, PeriodicFunction)
	inst:ListenForEvent("healthdelta", OnHealthDelta )
	inst:ListenForEvent("hungerdelta", OnHungerDelta )
	inst:ListenForEvent("sanitydelta", OnSanityDelta )
	inst:ListenForEvent("onattackother", OnAttackOther )
	inst:ListenForEvent("hatequipped", OnEquipHat )
	inst:ListenForEvent("equip", OnEquip )
	inst:ListenForEvent("unequip", OnEquip )
	inst:ListenForEvent("graze", Graze )
	inst:ListenForEvent("debugmode", DebugFunction, inst)
	inst:ListenForEvent("continuefrompause", OnContinue, GetWorld())
end

return MakePlayerCharacter("yakumoyukari", prefabs, assets, fn, start_inv)