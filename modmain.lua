PrefabFiles = {
	"yakumoyukari",
	"yukariumbre",
	"yukarihat",
	"upgradepanel",
	"ultpanel",
	"spellcards",
	"barrierfield_fx",
	"graze_fx",
	"scheme",
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
	Asset( "ANIM" , "anim/ypower.zip"),
	
	Asset("SOUNDPACKAGE", "sound/soundpack.fev"),
	Asset("SOUND", "sound/spell.fsb"),
}
AddMinimapAtlas("images/map_icons/yakumoyukari.xml")
AddMinimapAtlas("images/map_icons/yukarihat.xml")
AddMinimapAtlas("images/map_icons/yukariumbre.xml")
AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/scheme.xml")

----- GLOBAL & require set -----
local require = GLOBAL.require
require "class"
GLOBAL.YUKARI_LANGUAGE = GetModConfigData("language")
GLOBAL.YUKARI_DIFFICULTY = GetModConfigData("diff")

local SCHEME_ENABLED = GLOBAL.getmetatable(GLOBAL).__declared["SCHEME_ENABLED"] -- bypass the strict rule that global(_G) variables should be declared.
if SCHEME_ENABLED then
	print("[YAKUMOYUKARI] DETECTED SCHEME MOD")
else
	print("[YAKUMOYUKARI] UNABLED TO DETECT SCHEME MOD")
	GLOBAL.SCHEME_ENABLED = false
end


require "constants_yukari"

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
local TheFrontEnd = GLOBAL.TheFrontEnd
local GetSeasonManager = GLOBAL.GetSeasonManager

modimport "scripts/tunings_yukari.lua"
TUNING.YUKARI_STATUS = TUNING["YUKARI_STATUS"..(GLOBAL.YUKARI_DIFFICULTY or "")]

modimport "scripts/power_init.lua"
modimport "scripts/strings_yukari.lua"
modimport "scripts/custom_intro.lua"
modimport "scripts/actions_yukari.lua" -- actions must be loaded before stategraph loads
modimport "scripts/stategraph_yukari.lua"

------ Function ------

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

function GodTelePort()
	if true then return end
	local Chara = GetPlayer()
	if Chara and Chara:HasTag("yakumoyukari") then
		if Chara.components.upgrader.GodTelepoirt and Chara.istelevalid and not IsPaused() then
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
				Chara:DoTaskInTime(0.2, function() Chara:Show() end)
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

local function IsSprintSeason()
	return GetSeasonManager() and (GetSeasonManager():IsSpring() or (GetSeasonManager().IsGreenSeason and GetSeasonManager():IsGreenSeason()))
end

local function GetSpringMod(range)
	if IsSprintSeason() then
		range = range * TUNING.SPRING_COMBAT_MOD
	end
	return range
end

local function BunnymanNormalRetargetFn(inst)
	local function is_meat(item)
		return item.components.edible and item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT
	end
	
	local function NormalRetargetFn(inst)
		return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
            if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
                if guy:HasTag("monster") or guy:HasTag("youkai") then return guy end
                if guy:HasTag("player") and guy.components.inventory and guy:GetDistanceSqToInst(inst) < TUNING.BUNNYMAN_SEE_MEAT_DIST*TUNING.BUNNYMAN_SEE_MEAT_DIST and guy.components.inventory:FindItem(is_meat) then return guy end
            end
        end, nil, {"realyoukai"})
	end
	inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
end

local function PigmanNormalRetargetFn(inst)
	local function NormalRetargetFn(inst)
		return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
            if not guy.LightWatcher or guy.LightWatcher:IsInLight() then
                return (guy:HasTag("monster") or guy:HasTag("youkai")) and guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not 
                (inst.components.follower.leader ~= nil and guy:HasTag("abigail"))
            end
        end, nil, {"realyoukai"})
	end
	inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
end

local function BatRetargetFn(inst)
	local function MakeTeam(inst, attacker) 
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
		end, nil, {"realyoukai"})

		if newtarget and not ta.inteam and not ta:SearchForTeam() then
			MakeTeam(inst, newtarget)
		end

		if ta.inteam and not ta.teamleader:CanAttack() then
			return newtarget
		end
	end
	
	inst.components.combat:SetRetargetFunction(3, Retarget)
end

local function MosquitoRetargetFn(inst)
	local function KillerRetarget(inst)
		local range = GetSpringMod(20)
		local notags = {"FX", "NOCLICK","INLIMBO", "insect", "realyoukai"}
		local yestags = {"character", "animal", "monster", "youkai"}
		return FindEntity(inst, range, function(guy)
			return inst.components.combat:CanTarget(guy)
		end, nil, notags, yestags)
	end
	inst.components.combat:SetRetargetFunction(2, KillerRetarget)
end

local function KillerbeeRetargetFn(inst)
	local function KillerRetarget(inst)
		local range = GetSpringMod(8)
		return FindEntity(inst, range, function(guy)
				return inst.components.combat:CanTarget(guy)
			end, nil, {"insect", "realyoukai"}, {"character", "animal", "monster", "youkai"})
	end
	inst.components.combat:SetRetargetFunction(2, KillerRetarget)
end

local function BeeRetargetFn(inst)
	local function SpringBeeRetarget(inst)
		if IsSprintSeason() then
			local range = 4
			return FindEntity(inst, range, function(guy)
				return inst.components.combat:CanTarget(guy)
			end, nil, {"insect", "realyoukai"}, {"character", "animal", "monster", "youkai"})
		else
			return false
		end
	end
	inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
end

local function FrogRetargetFn(inst)
	local function retargetfn(inst)
		if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
			local notags = {"FX", "NOCLICK","INLIMBO", "realyoukai"}
			return FindEntity(inst, TUNING.FROG_TARGET_DIST, function(guy) 
				if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
					return guy.components.inventory ~= nil
				end
			end, nil, notags)
		end
	end

	inst.components.combat:SetRetargetFunction(3, retargetfn)
end

local function SpiderRetargetFn(inst)
	local function NormalRetarget(inst)
		local targetDist = inst.components.knownlocations:GetLocation("investigate") and GetSpringMod(TUNING.SPIDER_INVESTIGATETARGET_DIST) or GetSpringMod(TUNING.SPIDER_TARGET_DIST)
		local notags = {"FX", "NOCLICK","INLIMBO", "monster", "realyoukai"}
		return FindEntity(inst, targetDist, 
			function(guy) 
				if inst.components.combat:CanTarget(guy)
				   and not (inst.components.follower and inst.components.follower.leader == guy)
				   and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion")) then
					return (guy:HasTag("character") and not guy:HasTag("monster"))
				end
		end, nil, notags)
	end
	inst.components.combat:SetRetargetFunction(1, NormalRetarget)
end

local function WarriorRetarget(inst)
    local targetDist = GetSpringMod(TUNING.SPIDER_WARRIOR_TARGET_DIST)
    local notags = {"FX", "NOCLICK","INLIMBO"}
    return FindEntity(inst, targetDist, function(guy)
		return ((guy:HasTag("character") and not guy:HasTag("monster")) or guy:HasTag("pig"))
               and inst.components.combat:CanTarget(guy)
               and not (inst.components.follower and inst.components.follower.leader == guy)
               and not (inst.components.follower and inst.components.follower.leader == GetPlayer() and guy:HasTag("companion"))
	end, nil, notags)
end

local function SpiderqueenRetargetFn(inst)
	local function Retarget(inst)
		if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
			local oldtarget = inst.components.combat.target
			local notags = {"FX", "NOCLICK","INLIMBO", "monster", "realyoukai"}
			local newtarget = FindEntity(inst, 10, 
				function(guy) 
					if inst.components.combat:CanTarget(guy) then
						return (guy:HasTag("character") and not guy:HasTag("monster"))
					end
				end, nil, notags)
        
			if newtarget and newtarget ~= oldtarget then
				inst.components.combat:SetTarget(newtarget)
			end
		end
	end

	inst.components.combat:SetRetargetFunction(3, Retarget)
end

AddPrefabPostInit("bunnyman", BunnymanNormalRetargetFn)
AddPrefabPostInit("pigman", PigmanNormalRetargetFn)
AddPrefabPostInit("bat", BatRetargetFn)
AddPrefabPostInit("mosquito", MosquitoRetargetFn)
AddPrefabPostInit("bee", BeeRetargetFn)
AddPrefabPostInit("killerbee", KillerbeeRetargetFn)
AddPrefabPostInit("frog", FrogRetargetFn)
AddPrefabPostInit("spider", SpiderRetargetFn)
AddPrefabPostInit("spider_warrior", WarriorRetargetFn)
AddPrefabPostInit("spiderqueen", SpiderqueenRetargetFn)

if IsDLCEnabled(2) or IsDLCEnabled(3) then
	AddPrefabPostInit("mosquito_poison", MosquitoRetargetFn)
end

local function GetModOptionKeyData(option)
	local KEY = GetModConfigData(option)
	return GLOBAL[KEY]
end

local function SayInfo()
	local inst = GetPlayer()
	if GLOBAL.GetWorld() == nil or not inst:HasTag("yakumoyukari") then return end

	local HP = 0
	local HN = 0
	local SA = 0
	local PO = 0
	local str = ""
	local skilltable = {}
	local inspect = GetModConfigData("skill") or 1
	inst.infopage = inst.infopage >= (inst.components.upgrader.SkillTextPage or TUNING.YUKARI.SKILLPAGE_BASE) and 0 or inst.infopage

	if inst.infopage == 0 then
		HP = inst.components.upgrader.health_level
		HN = inst.components.upgrader.hunger_level
		SA = inst.components.upgrader.sanity_level
		PO = inst.components.upgrader.power_level

		str = STRINGS.NAMES.HEALTHPANEL.." : "..HP.."\n"..STRINGS.NAMES.HUNGERPANEL.." : "..HN.."\n"..STRINGS.NAMES.SANITYPANEL.." : "..SA.."\n"..STRINGS.NAMES.POWERPANEL.." : "..PO.."\n"
	elseif inst.infopage == 1 then
		for i = 1, #GLOBAL.YUKARISTATINDEX do
			for j = 1, TUNING.YUKARI.MAX_SKILL_LEVEL do
				if inst.components.upgrader.ability[i][j] then
					if i == 1 then HP = HP + 1
					elseif i == 2 then HN = HN + 1
					elseif i == 3 then SA = SA + 1
					elseif i == 4 then PO = PO + 1
					end
				end
			end
		end

		str = STRINGS.HEALTH.." "..STRINGS.ABILITY.." : lev."..HP.."\n"..STRINGS.HUNGER.." "..STRINGS.ABILITY.." : lev."..HN.."\n"..STRINGS.SANITY.." "..STRINGS.ABILITY.." : lev."..SA.."\n"..STRINGS.POWER.." "..STRINGS.ABILITY.." : lev."..PO.."\n"
	else
		local skillindex = 0
		inst.components.upgrader:UpdateSkillStatus()

		for k, v in pairs(inst.components.upgrader.skill) do
			skillindex = skillindex + 1
			skilltable[skillindex] = v
		end
		inst.components.upgrader.SkillTextPage = (skillindex ~= 0 and 2 + math.ceil(skillindex / 3) or 3)

		for k = 1, 3 do
			str = str..(skilltable[(inst.infopage - 2) * 3 + k] or "").."\n"
		end

		if str == "\n\n\n" then
			str = STRINGS.YUKARI_NOSKILL.."\n"
		end
	end

	inst.infopage = inst.infopage + 1
	if inspect > 1 then print(str) end
	if inspect % 2 == 1 then inst.components.talker:Say(str) end
end

TheInput:AddKeyDownHandler(GetModOptionKeyData("skillkey"), SayInfo)

AddModCharacter("yakumoyukari")
table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "yakumoyukari")