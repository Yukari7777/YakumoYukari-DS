PrefabFiles = {
	"tunnel",
	"yakumoyukari",
	"yukariumbre",
	"yukarihat",
	"upgradepanel",
	"ultpanel",
	"ultpanelsw",
	"spellcards",
	"barrierfieldfx",
	"scheme",
	"effect_fx"
	--"shadowyukari"
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/yakumoyukari.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/yakumoyukari.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/yakumoyukari.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/yakumoyukari.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/yakumoyukari_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/yakumoyukari_silho.xml" ),
    Asset( "IMAGE", "bigportraits/yakumoyukari.tex" ),
    Asset( "ATLAS", "bigportraits/yakumoyukari.xml" ),
	
	Asset( "IMAGE", "images/map_icons/yakumoyukari.tex" ),
	Asset( "ATLAS", "images/map_icons/yakumoyukari.xml"  ),
	Asset( "IMAGE", "images/map_icons/minimap_tunnel.tex"),
	Asset( "ATLAS", "images/map_icons/minimap_tunnel.xml"),
	Asset( "IMAGE", "images/map_icons/yukarihat.tex"  ),
	Asset( "ATLAS", "images/map_icons/yukarihat.xml" ),
	Asset( "IMAGE", "images/map_icons/yukariumbre.tex" ),
	Asset( "ATLAS", "images/map_icons/yukariumbre.xml" ),
	Asset( "IMAGE", "images/map_icons/scheme.tex" ),
	Asset( "ATLAS", "images/map_icons/scheme.xml" ),
	
	Asset( "IMAGE", "images/inventoryimages/touhoutab.tex" ),
	Asset( "ATLAS", "images/inventoryimages/touhoutab.xml" ),
	Asset( "ANIM" , "anim/power.zip"),
	
	Asset("SOUNDPACKAGE", "sound/soundpack.fev"),
	Asset("SOUND", "sound/spell.fsb"),

}

----- GLOBAL & require set -----
local require = GLOBAL.require
require "class"

local STRINGS = GLOBAL.STRINGS
local GetClock = GLOBAL.GetClock
local ProfileStatsSet = GLOBAL.ProfileStatsSet
local TheCamera = GLOBAL.TheCamera
local IsDLCEnabled = GLOBAL.IsDLCEnabled
local SpawnPrefab = GLOBAL.SpawnPrefab
local GetPlayer = GLOBAL.GetPlayer
local GetString = GLOBAL.GetString
local TheInput = GLOBAL.TheInput
local IsPaused = GLOBAL.IsPaused
local FindEntity = GLOBAL.FindEntity
local GetSeasonManager = GLOBAL.GetSeasonManager
local Inspect = GetModConfigData("inspect")
local Language = GetModConfigData("language")
local notags = {"FX", "NOCLICK", "INLIMBO", "realyoukai"}

----- Basic settings for Yukari -----
STRINGS.CHARACTER_TITLES.yakumoyukari = "Youkai of Boundaries"
STRINGS.CHARACTER_NAMES.yakumoyukari = "Yakumo Yukari"
STRINGS.CHARACTER_DESCRIPTIONS.yakumoyukari = "has own ability 'youkai power'.\nbecomes dreadful when she get 'power' from her world."
STRINGS.CHARACTER_QUOTES.yakumoyukari = "\"I will control this world, too.\""
STRINGS.CHARACTERS.YAKUMOYUKARI = require "speech_yakumoyukari"
if Language == "chinese" then
	STRINGS.CHARACTER_TITLES.yakumoyukari = "境界的妖怪"
	STRINGS.CHARACTER_DESCRIPTIONS.yakumoyukari = "拥 有 自 己 的 能 力 '妖 力'.\n 当 她 从 自 己 的 世 界 中 获 得 ' 力 量 ' 之 后 将 变 得 极 其 可 怕."
	STRINGS.CHARACTER_QUOTES.yakumoyukari = "\"我 将 会 掌 控 这 个 世 界！.\""
	STRINGS.CHARACTERS.YAKUMOYUKARI = require "speech_yakumoyukari_ch"
end
table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "yakumoyukari")
AddModCharacter("yakumoyukari")
AddMinimapAtlas("images/map_icons/yakumoyukari.xml")
AddMinimapAtlas("images/map_icons/yukarihat.xml")
AddMinimapAtlas("images/map_icons/yukariumbre.xml")
AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/scheme.xml")

------ Function ------

function MakePowerComponents(inst)
	GLOBAL.assert( GLOBAL.GetPlayer() == nil )
	local player_prefab = GLOBAL.SaveGameIndex:GetSlotCharacter()

	GLOBAL.TheSim:LoadPrefabs( {player_prefab} )
	local oldfn = GLOBAL.Prefabs[player_prefab].fn
	GLOBAL.Prefabs[player_prefab].fn = function()
		local inst = oldfn()
		if player_prefab == "yakumoyukari" then
			inst:AddComponent("power")
		end
		return inst
	end
end

AddPrefabPostInit("world", MakePowerComponents)

GLOBAL.ACTIONS.JUMPIN.fn = function(act)
    if act.target.components.teleporter then
	    act.target.components.teleporter:Activate(act.doer)
	    return true
	elseif act.target.components.schemeteleport then 
		act.target.components.schemeteleport:Activate(act.doer)
		return true
	end
end

if IsDLCEnabled(GLOBAL.CAPY_DLC) then
	GLOBAL.ACTIONS.JUMPIN.strfn = function(act)
		if act.target.components.teleporter and act.target.components.teleporter.getverb then
			return act.target.components.teleporter.getverb(act.target, act.doer)
		elseif act.target.components.schemeteleport and act.target.components.schemeteleport.getverb then
			return act.target.components.schemeteleport.getverb(act.target, act.doer)
		end
	end
end

function AddSchemeManager(inst)
	inst:AddComponent("scheme_manager")
end

GLOBAL.jumpintimeline = {}

function SimPostInit(player)
	-- Store this timeline
	local state = player.sg.sg.states["jumpin"]
	GLOBAL.jumpintimeline = state.timeline
end

GLOBAL.DisableWormholeJumpNoise = function()
	local player = GLOBAL.GetPlayer()
	local state = player.sg.sg.states["jumpin"]
	state.timeline = nil
end

GLOBAL.EnableWormholeJumpNoise = function()
	local player = GLOBAL.GetPlayer()
	local state = player.sg.sg.states["jumpin"]
	state.timeline = GLOBAL.jumpintimeline
end

AddSimPostInit(SimPostInit)

function GodTelePort()
	if GetPlayer() and GetPlayer().prefab == "yakumoyukari" then
		if GetPlayer().components.upgrader.GodTelepoirt and GetPlayer().istelevalid and not IsPaused() then
			local Chara = GetPlayer()
			if Chara.components.power and Chara.components.power.current >= 20 then
				local function isvalid(x,y,z)
					local ground = GLOBAL.GetWorld()
					if ground then
						local tile = ground.Map:GetTileAtPoint(x,y,z)
						return tile ~= 1--[[return value of GROUND.IMPASSIBLE]] and tile < 128--return value of GROUND.UNDERGROUND
					end
					return false
				end
				local x,y,z = TheInput:GetWorldPosition():Get()
				if isvalid(x,y,z) then Chara.Transform:SetPosition(x,y,z) else return false end
				Chara.SoundEmitter:PlaySound("soundpack/spell/teleport")
				Chara:Hide()
				GetPlayer():DoTaskInTime(0.2, function() Chara:Show() end)
				Chara.components.power:DoDelta(-20, false)
			else
				Chara.components.talker:Say(GetString(Chara.prefab, "DESCRIBE_LOWPOWER"))
			end
			Chara.istelevalid = false
			Chara:PushEvent("teleported")
		end
	end
end

TheInput:AddKeyDownHandler(116, GodTelePort)

---------------- OVERRIDE -----------------

-- resurrection with full health 
local TouchstoneReturn = function(prefab)

	local oldFn = prefab.components.resurrector.doresurrect
	prefab.components.resurrector.doresurrect = function(inst, dude)
		if dude.prefab ~= "yakumoyukari" then
			return oldFn(inst, dude)
		end

		inst:AddTag("busy")
		inst.MiniMapEntity:SetEnabled(false)
		if inst.Physics then
			GLOBAL.MakeInventoryPhysics(inst)
		end
		
		ProfileStatsSet("resurrectionstone_used", true)

		dude.components.hunger:Pause()
		dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
		dude:Hide()

		GetClock():MakeNextDay()
		GLOBAL.TheCamera:SetDistance(12)
		GLOBAL.scheduler:ExecuteInTime(3, function()
			dude:Show()

			GetSeasonManager():DoLightningStrike(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))


			inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_break")
			inst.components.lootdropper:DropLoot()
			inst:Remove()
			
			if dude.components.hunger then
				dude.components.hunger:SetPercent(1)
			end

			if dude.components.health then
				dude.components.health:Respawn(dude.components.health:GetMaxHealth())
			end
			
			if dude.components.sanity then
				dude.components.sanity:SetPercent(1)
			end
			
			if dude.components.power then
				dude.components.power:SetPercent(0)
			end
			
			if dude.components.temperature then
				dude.components.temperature:SetTemperature(30)
			end
			
			dude.components.hunger:Resume()
			
			dude.sg:GoToState("wakeup")
			
			
			dude:DoTaskInTime(3, function(inst) 
				if dude.HUD then
					dude.HUD:Show()
				end
				GLOBAL.TheCamera:SetDefault()
				inst:RemoveTag("busy")
			end)
			
		end)
	end
end
-- Meat Effigy Tweak
local EffigyReturn = function(prefab)
	local oldFn = prefab.components.resurrector.doresurrect
	prefab.components.resurrector.doresurrect = function(inst, dude)
		if dude.prefab ~= "yakumoyukari" then
			return oldFn(inst, dude)
		end
		inst:AddTag("busy")	
		inst.persists = false
		inst:RemoveComponent("lootdropper")
		inst:RemoveComponent("workable")
		inst:RemoveComponent("inspectable")
		inst.MiniMapEntity:SetEnabled(false)
		if inst.Physics then
			GLOBAL.RemovePhysicsColliders(inst)
		end

		dude.components.hunger:Pause()
		GLOBAL.GetClock():MakeNextDay()
		dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
		dude:Hide()
		dude:ClearBufferedAction()

		if dude.HUD then
			dude.HUD:Hide()
		end
		if dude.components.playercontroller then
			dude.components.playercontroller:Enable(false)
		end

		GLOBAL.TheCamera:SetDistance(12)
		dude.components.hunger:Pause()
		
		GLOBAL.scheduler:ExecuteInTime(3, function()
			dude:Show()

			inst:Hide()
			inst.AnimState:PlayAnimation("debris")
			inst.components.resurrector.penalty = 0                
			
			dude.sg:GoToState("rebirth")
			
			dude:DoTaskInTime(3, function() 
				if dude.HUD then
					dude.HUD:Show()
				end
				if dude.components.hunger then
					dude.components.hunger:SetPercent(1)
				end
				
				if dude.components.health then
					dude.components.health:RecalculatePenalty()
					dude.components.health:Respawn(dude.components.health:GetMaxHealth())
					dude.components.health:SetInvincible(true)
				end
				
				if dude.components.sanity then
					dude.components.sanity:SetPercent(1)
				end
				if dude.components.playercontroller then
					dude.components.playercontroller:Enable(true)
				end
			
				if dude.components.temperature then
					dude.components.temperature:SetTemperature(30)
				end

				if dude.components.power then
					dude.components.power:SetPercent(0)
				end
				
				dude.components.hunger:Resume()
				
				GLOBAL.TheCamera:SetDefault()
				inst:RemoveTag("busy")
			end)
			inst:DoTaskInTime(4, function() 
				dude.components.health:SetInvincible(false)
				inst:Show()
			end)
			inst:DoTaskInTime(7, function()
				local tick_time = TheSim:GetTickTime()
				local time_to_erode = 4
				inst:StartThread( function()
					local ticks = 0
					while ticks * tick_time < time_to_erode do
						local erode_amount = ticks * tick_time / time_to_erode
						inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
						ticks = ticks + 1
						GLOBAL.Yield()
					end
					inst:Remove()
				end)
			end)
			
		end)
	end
end
local function InventoryDamage(self)
	local function NewTakeDamage(self, damage, attacker, weapon, ...)
		-- GRAZE MECHANISM
		local Chara = GetPlayer()
		if self.inst.prefab == "yakumoyukari" then
			local totaldodge = Chara.dodgechance + Chara.components.upgrader.hatdodgechance
			if math.random() < totaldodge then
				local pt = GLOBAL.Vector3(Chara.Transform:GetWorldPosition())
				for i = 1, math.random(3,5), 1 do
					local fx = SpawnPrefab("graze_fx")
					fx.Transform:SetPosition(pt.x + math.random() / 2, pt.y + 0.7 + math.random() / 2 , pt.z + math.random() / 2 )
				end
				Chara:PushEvent("grazed")
				
				return 0
			end
		end
		--check resistance
		for k,v in pairs(self.equipslots) do
			if v.components.resistance and v.components.resistance:HasResistance(attacker, weapon) then
				return 0
			end
		end
		--check specialised armor
		for k,v in pairs(self.equipslots) do
			if v.components.armor and v.components.armor.tags then
				damage = v.components.armor:TakeDamage(damage, attacker, weapon)
				if damage <= 0 then
					return 0
				end
			end
		end
		--check general armor
		for k,v in pairs(self.equipslots) do
			if v.components.armor then
				damage = v.components.armor:TakeDamage(damage, attacker, weapon)
				if damage <= 0 then
					return 0
				end
			end
		end
		-- custom damage reduction
		if self.inst.prefab == "yakumoyukari" then
			if Chara.components.upgrader:IsHatValid(Chara) then
				local hatabsorb = 0
				for i = 2, 5, 1 do
					if Chara.components.upgrader.hatskill[i] then
						hatabsorb = hatabsorb + 0.2
					end
				end
				damage = damage * (1 - hatabsorb)
			end
			
			if Chara.components.upgrader.IsDamage then
				damage = damage * 0.7
			end
			
			if Chara:HasTag("IsDamage") then
				damage = damage * 0.5
			end
		end
		
		return damage
	end
	self.ApplyDamage = NewTakeDamage
end
-- Bunnyman Retarget Function
local function BunnymanNormalRetargetFn(inst)

	local function is_meat(item)
		return item.components.edible and item.components.edible.foodtype == "MEAT" 
	end
	
	local function NormalRetargetFn(inst)
		return FindEntity(inst, TUNING.PIG_TARGET_DIST,
			function(guy)
				if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
					if guy:HasTag("monster") or guy:HasTag("youkai") then return guy end
					if guy:HasTag("player") 
					and guy.components.inventory 
					and guy:GetDistanceSqToInst(inst) < TUNING.BUNNYMAN_SEE_MEAT_DIST * TUNING.BUNNYMAN_SEE_MEAT_DIST 
					and guy.components.inventory:FindItem(is_meat) then 
					return guy end
				end
			end, nil ,notags)
	end
	inst.components.combat:SetRetargetFunction(1, NormalRetargetFn)
end
-- spider retargetfn
local function SpiderRetargetFn(inst)
	local function NormalRetarget(inst)
		local targetDist = TUNING.SPIDER_TARGET_DIST
		if inst.components.knownlocations:GetLocation("investigate") then
			targetDist = TUNING.SPIDER_INVESTIGATETARGET_DIST
		end
		if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
			targetDist = targetDist * TUNING.SPRING_COMBAT_MOD
		end
		
		return FindEntity(inst, targetDist, 
			function(guy) 
				if inst.components.combat:CanTarget(guy)
				   and not (inst.components.follower and inst.components.follower.leader == guy)
				   and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion")) then
					return (guy:HasTag("character") and (not guy:HasTag("monster") or guy:HasTag("youkai") ))
				end
		end, nil, notags)
	end
	inst.components.combat:SetRetargetFunction(1, NormalRetarget)
end
-- spider warrior retargetfn
local function WarriorRetargetFn(inst)
	local function WarriorRetarget(inst)
		local targetDist = TUNING.SPIDER_WARRIOR_TARGET_DIST
		if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
			targetDist = targetDist * TUNING.SPRING_COMBAT_MOD
		end
		return FindEntity(inst, targetDist, function(guy)
			return ((guy:HasTag("character") and not guy:HasTag("monster")) or guy:HasTag("pig")) or guy:HasTag("youkai")
				   and inst.components.combat:CanTarget(guy)
				   and not (inst.components.follower and inst.components.follower.leader == guy)
				   and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion"))
		end, nil, notags)
	end
	inst.components.combat:SetRetargetFunction(2, WarriorRetarget)
end
-- Wildbore Retarget Function
local function WildboreNormalRetargetFn(inst)
	local function NormalRetargetFn(inst)
		local musttags = {"monster"}
		return FindEntity(inst, TUNING.PIG_TARGET_DIST,
			function(guy)
				if not guy.LightWatcher or guy.LightWatcher:IsInLight() then
					if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
						return not (inst.components.follower.leader ~= nil and guy:HasTag("abigail")) or guy:HasTag("youkai")
					end
				end
			end, musttags, notags)
	end
end
local function SetNormalBoreFn(inst)
	local function SetNormalPig(inst)
		inst:RemoveTag("werepig")
		inst:RemoveTag("guard")
		inst:SetBrain(brain)
		inst:SetStateGraph("SGwildbore")
		inst.AnimState:SetBuild(inst.build)
		
		inst.components.werebeast:SetOnNormalFn(SetNormalPig)
		inst.components.sleeper:SetResistance(2)

		inst.components.combat:SetDefaultDamage(TUNING.PIG_DAMAGE)
		inst.components.combat:SetAttackPeriod(TUNING.PIG_ATTACK_PERIOD)
		inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
		inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
		inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED
		
		inst.components.sleeper:SetSleepTest(NormalShouldSleep)
		inst.components.sleeper:SetWakeTest(DefaultWakeTest)
		
		inst.components.lootdropper:SetLoot({})
		inst.components.lootdropper:AddRandomLoot("meat",3)
		inst.components.lootdropper:AddRandomLoot("pigskin",1)
		inst.components.lootdropper.numrandomloot = 1

		inst.components.health:SetMaxHealth(TUNING.PIG_HEALTH)
		inst.components.combat:SetRetargetFunction(3, WildboreNormalRetargetFn)
		inst.components.combat:SetTarget(nil)
		inst:ListenForEvent("suggest_tree_target", function(inst, data)
			if data and data.tree and inst:GetBufferedAction() ~= ACTIONS.CHOP then
				inst.tree_target = data.tree
			end
		end)
		
		inst.components.trader:Enable()
		inst.components.talker:StopIgnoringAll()
	end
	inst.components.werebeast:SetOnNormalFn(SetNormalPig)
end
-- Pigman Retarget Function
local function PigmanNormalRetargetFn(inst)
	
	local function NormalRetargetFn(inst)
		return FindEntity(inst, TUNING.PIG_TARGET_DIST,
			function(guy)
				if not guy.LightWatcher or guy.LightWatcher:IsInLight() then
					return guy:HasTag("monster") or guy:HasTag("youkai") and guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not 
					(inst.components.follower.leader ~= nil and guy:HasTag("abigail"))
				end
			end, nil, notags)
	end
end
local function SetNormalPigFn(inst)
	local function SetNormalPig(inst)
		inst:RemoveTag("werepig")
		inst:RemoveTag("guard")
		local brain = require "brains/pigbrain"
		inst:SetBrain(brain)
		inst:SetStateGraph("SGpig")
		inst.AnimState:SetBuild(inst.build)
		
		inst.components.sleeper:SetResistance(2)
		inst.components.werebeast:SetOnNormalFn(SetNormalPig)

		inst.components.combat:SetDefaultDamage(TUNING.PIG_DAMAGE)
		inst.components.combat:SetAttackPeriod(TUNING.PIG_ATTACK_PERIOD)
		inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
		inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
		inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED
		
		inst.components.sleeper:SetSleepTest(NormalShouldSleep)
		inst.components.sleeper:SetWakeTest(DefaultWakeTest)
		
		inst.components.lootdropper:SetLoot({})
		inst.components.lootdropper:AddRandomLoot("meat",3)
		inst.components.lootdropper:AddRandomLoot("pigskin",1)
		inst.components.lootdropper.numrandomloot = 1

		inst.components.health:SetMaxHealth(TUNING.PIG_HEALTH)
		inst.components.combat:SetRetargetFunction(3, PigmanNormalRetargetFn)
		inst.components.combat:SetTarget(nil)
		inst:ListenForEvent("suggest_tree_target", function(inst, data)
			if data and data.tree and inst:GetBufferedAction() ~= ACTIONS.CHOP then
				inst.tree_target = data.tree
			end
		end)
		
		inst.components.trader:Enable()
		inst.components.talker:StopIgnoringAll()
	end
	inst.components.werebeast:SetOnNormalFn(SetNormalPig)
end
-- Bat Retarget Function
local function BatRetargetFn(inst)

	local function NoError(inst, attacker, ...) 
		local leader = SpawnPrefab("teamleader")
		leader:AddTag("bat")
		leader.components.teamleader.threat = attacker
		leader.components.teamleader.team_type = inst.components.teamattacker.team_type
		leader.components.teamleader:NewTeammate(inst)
		leader.components.teamleader:BroadcastDistress(inst)
	end
	
	local function Retarget(inst)
		local ta = inst.components.teamattacker
		
		local newtarget = FindEntity(inst, TUNING.BISHOP_TARGET_DIST, function(guy)
				return (guy:HasTag("character") or guy:HasTag("monster") )
					   and not guy:HasTag("bat")
					   and inst.components.combat:CanTarget(guy)
		end, nil, notags)
		if newtarget and not ta.inteam and not ta:SearchForTeam() then
			NoError(inst, newtarget)
		end
		if ta.inteam and not ta.teamleader:CanAttack() then
			return newtarget
		end
	end
	
	inst.components.combat:SetRetargetFunction(3, Retarget)
end
-- Spring Bee Retarget Function
local function BeeRetargetFn(inst)
	local function SpringBeeRetarget(inst)
		if GetSeasonManager() and GetSeasonManager():IsSpring() then
			return FindEntity(inst, 4, function(guy)
				return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") )
					and not guy:HasTag("insect")
					and inst.components.combat:CanTarget(guy)
			end, nil, notags)
		else
			return false
		end
	end
	inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
end
-- Killer bee retarget Function
local function KillerRetargetFn(inst)
	local function KillerRetarget(inst)
		return FindEntity(inst, 8, function(guy)
			return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") )
				and not guy:HasTag("insect")
				and inst.components.combat:CanTarget(guy)
		end, nil, notags)
	end
	inst.components.combat:SetRetargetFunction(2, KillerRetarget)
end
-- frog Retarget Function
local function FrogRetargetFn(inst)
	local function retargetfn(inst)
		if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
			return FindEntity(inst, TUNING.FROG_TARGET_DIST, function(guy) 
				if guy.components.combat and guy.components.health 
				and not guy.components.health:IsDead() then
					return guy.components.inventory ~= nil
				end
			end, nil, notags)
		end
	end
	inst.components.combat:SetRetargetFunction(3, retargetfn)
end

local function SetInspectable(inst)
	if Inspect then
		inst:AddComponent("inspectable") 
		if inst:HasTag("NOCLICK") then
			inst:RemoveTag("NOCLICK")
		end
	end
end

local armorlist = {
	"grass",
	"marble",
	"ruins",
	"sanity",
	"snurtleshell",
	"wood"
}
local function GetName(i)
	return "armor_"..armorlist[i]
end

for i = 1, #armorlist, 1 do
	AddPrefabPostInit(GetName(i), function(inst)
		local function Blocked(owner)
		
		end
		
		local function equip(inst, owner)
			owner.AnimState:OverrideSymbol("swap_body", GetName(i), "swap_body")
			inst:ListenForEvent("blocked", Blocked, owner)
		end
		
		local function unequip(inst, owner)
			owner.AnimState:ClearOverrideSymbol("swap_body")
			inst:RemoveEventCallback("blocked", Blocked, owner)
		end

		inst.components.equippable:SetOnEquip( equip )
		inst.components.equippable:SetOnUnequip( unequip )
	end)
end

local function ToolEfficientFn(self)

	local function ToolEfficient(self, act, effectiveness, ...)
		effectiveness = effectiveness or 1
		
		if GetPlayer() and GetPlayer().prefab == "yakumoyukari" then
			if GetPlayer().components.upgrader and GetPlayer().components.upgrader.IsEfficient then
				if act == GLOBAL.ACTIONS.HAMMER then else
					effectiveness = effectiveness + 0.5
				end
			end
		end
		
		if not self.action then
			self.action = {}
		end
		
		self.action[act] = effectiveness
	end
	
	self.SetAction = ToolEfficient
end


---------- print current upgrade & ability
function DebugUpgrade()
	if GetPlayer() and GetPlayer().components.upgrader then
		local HP = GetPlayer().health_level
		local HN = GetPlayer().hunger_level
		local SA = GetPlayer().sanity_level
		local PO = GetPlayer().power_level
		
		local str = "Health Upgrade - "..HP.."\nHunger Upgrade - "..HN.."\nSanity Upgrade - "..SA.."\nPower Upgrade - "..PO
		if Language == "chinese" then
			str = "生 命 升 级 - "..HP.."\n饥 饿 升 级 - "..HN.."\n心 智 升 级 - "..SA.."\n妖 力 升 级 - "..PO
		end
		GetPlayer().components.talker:Say(str)
	end
end

function DebugAbility()
	local HP = 0
	local HN = 0
	local SA = 0
	local PO = 0
	
	for i = 1, 4, 1 do
		for j = 1, 6, 1 do
			if GetPlayer() and GetPlayer().components.upgrader and GetPlayer().components.upgrader.ability[i][j] then
				if i == 1 then
					HP = HP + 1
				elseif i == 2 then
					HN = HN + 1
				elseif i == 3 then
					SA = SA + 1
				elseif i == 4 then
					PO = PO + 1
				end
			end
		end
	end
	local str = "Health Ability - lev."..HP.."\nHunger Ability - lev."..HN.."\nSanity Ability - lev."..SA.."\nPower Ability - lev."..PO
	if Language == "chinese" then
		str = "生 命 能 力 - lev."..HP.."\n饥 饿 能 力 - lev."..HN.."\n心 智 能 力 - lev."..SA.."\n妖 力 能 力 - lev."..PO
	end
	GetPlayer().components.talker:Say(str)
end

function DebugCooltime()
	
	local Invincible = ""
	
	if GetPlayer() and GetPlayer().components.upgrader.InvincibleLearned then
		if GetPlayer().invin_cool then
			if Language == "chinese" then
				if GetPlayer().invin_cool >= 1440 then
					Invincible = "無 敵  -  ? 行"
				elseif GetPlayer().invin_cool > 0 then
					Invincible = "無 敵  -  "..GetPlayer().invin_cool.." 秒 "
				elseif GetPlayer().invin_cool == 0 then
					Invincible = "無 敵  -  準 備"
				end
			else
				if GetPlayer().invin_cool >= 1440 then
					Invincible = "Invincibility - On"
				elseif GetPlayer().invin_cool > 0 then
					Invincible = "Invincibility - "..GetPlayer().invin_cool.."s"
				elseif GetPlayer().invin_cool == 0 then
					Invincible = "Invincibility - Ready"
				end
			end
		end
	end
	
	local str = Invincible
	if str == "" then 
		GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "DESCRIBE_NOSKILL"))
	else
		GetPlayer().components.talker:Say(str)
	end
end

function DoDebug_1()
	if GetPlayer() and GetPlayer():HasTag("yakumoyukari") then 
		if not IsPaused() 
		and not TheInput:IsKeyDown(GLOBAL.KEY_CTRL) 
		-- and not TheInput:IsKeyDown(GLOBAL.KEY_ALT) <<<<<<<<<<<<<<<<<< This cause alt+tab issue!!
		and TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then 
			DebugUpgrade() 
		end
	end
end

function DoDebug_2()
	if GetPlayer() and GetPlayer():HasTag("yakumoyukari") then 
		if not IsPaused() 
		and not TheInput:IsKeyDown(GLOBAL.KEY_CTRL) 
		and TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then 
			DebugAbility() 
		end
	end
end

function DoDebug_3()
	if GetPlayer() and GetPlayer():HasTag("yakumoyukari") then 
		if not IsPaused() 
		and not TheInput:IsKeyDown(GLOBAL.KEY_CTRL) 
		and TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then 
			DebugCooltime() 
		end
	end
end

TheInput:AddKeyDownHandler(98, DoDebug_1)
TheInput:AddKeyDownHandler(118, DoDebug_2)
TheInput:AddKeyDownHandler(110, DoDebug_3)

-- Custom Intro

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
					string = "Who Are You",
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

modimport "scripts/power_init.lua" -- load "scripts/power_init.lua"
modimport "scripts/actions_yukari.lua"
modimport "scripts/recipes_yukari.lua"
modimport "scripts/strings_yukari.lua"
modimport "scripts/tunings_yukari.lua"
AddPrefabPostInit("resurrectionstone", TouchstoneReturn) -- Override function TouchstoneReturn to "prefabs/resurrectionstone.lua"
AddPrefabPostInit("resurrectionstatue", EffigyReturn)
AddPrefabPostInit("maxwellintro", YukariIntro)                                            
AddPrefabPostInit("wallyintro", YukariIntro)                                            
AddPrefabPostInit("forest", AddSchemeManager)
AddPrefabPostInit("cave", AddSchemeManager)
AddPrefabPostInit("flotsam", AddSchemeManager)
AddPrefabPostInit("world", AddSchemeManager)
AddPrefabPostInit("bunnyman", BunnymanNormalRetargetFn)
AddPrefabPostInit("pigman", PigmanNormalRetargetFn)
AddPrefabPostInit("pigman", SetNormalPigFn)
AddPrefabPostInit("wildbore", WildboreNormalRetargetFn)
AddPrefabPostInit("wildbore", SetNormalBoreFn)
AddPrefabPostInit("bat", BatRetargetFn)
AddPrefabPostInit("bee", BeeRetargetFn)
AddPrefabPostInit("frog", FrogRetargetFn)
AddPrefabPostInit("spider", SpiderRetargetFn)
AddPrefabPostInit("spider_warrior", WarriorRetargetFn)
AddPrefabPostInit("shadowwatcher", SetInspectable)
AddPrefabPostInit("shadowskittish", SetInspectable)
AddPrefabPostInit("shadowskittish_water", SetInspectable)
AddPrefabPostInit("creepyeyes", SetInspectable)
AddPrefabPostInit("crawlinghorror", SetInspectable)
AddPrefabPostInit("terrorbeak", SetInspectable)
AddPrefabPostInit("swimminghorror", SetInspectable)
AddPrefabPostInit("crawlingnightmare", SetInspectable)
AddPrefabPostInit("nightmarebeak", SetInspectable)
AddComponentPostInit("inventory", InventoryDamage)
AddComponentPostInit("tool", ToolEfficientFn)