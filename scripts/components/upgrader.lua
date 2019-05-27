require "constants_yukari"
local CONST = TUNING.YUKARI
local STATUS = TUNING.YUKARI_STATUS

local Upgrader = Class(function(self, inst)
    self.inst = inst

	self.health_level = 0
	self.hunger_level = 0
	self.sanity_level = 0
	self.power_level = 0
	self.HatLevel = 1
	self.SkillTextPage = 3

	self.HealthBonus = 0
	self.HungerBonus = 0
	self.SanityBonus = 0
	self.PowerBonus = 0
	self.HatPowerGain = 0.1
	self.BonusSpeedMult = 1
	self.FastActionLevel = 0
	self.PowerGainMultiplier = 1
	
	self.PowerUpValue = 0
	self.RegenAmount = 0
	self.EmergencyRegenAmount = 0
	self.RegenCool = 0
	self.CureCool = 0
	self.ResistDark = 0
	self.SanityAbsorption = 0 

	self.HatSpeedMult = 1
	self.DodgeChance = 0.1
	self.SchemeCost = 30
	self.HatDodgeChance = 0
	self.HatDamageAbsorption = 0
	
	self.FastPicker = false
	self.FastCrafter = false
	self.FastCutter = false
	self.FastHarvester = false
	self.FastResetter = false
	self.IsPoisonCure = false
	self.CanbeInvincibled = false
	self.InvincibleLearned = false
	self.NoHealthPanelty = false
	self.IsDamage = false
	self.IsVampire = false
	self.IsAOE = false
	self.IsEfficient = false
	self.IsFight = false
	self.SpikeEater = false
	self.RotEater = false
	self.Ability_45 = false
	self.NightVision = false

	self.HatEquipped = false
	self.FireImmuned = false
	self.Insulator = false
	self.WaterProofer = false
	self.GasBlocker = false
	self.PoisonBlocker = false
	self.FireResist = false
	self.GodTeleport = false
	
	self:InitializeList()
end)

function Upgrader:InitializeList()
	self.ability = {}
	self.skill = {}
	self.skillsort = #YUKARISTATINDEX
	self.maxlevel = CONST.MAX_SKILL_LEVEL
	self.maxhatlevel = CONST.MAX_HATSKILL_LEVEL
	for i = 1, self.skillsort, 1 do
		self.ability[i] = {}
		for j = 1, self.maxlevel, 1 do
			self.ability[i][j] = false
		end
	end
	
	self.hatskill = {}
	for i = 1, self.maxhatlevel, 1 do
		self.hatskill[i] = false
	end
end

function Upgrader:SetFireDamageScale()
	local shouldimmune = self.FireImmuned or (self.HatEquipped and self.FireResist)
	if self.inst.components.health then
		self.inst.components.health.fire_damage_scale = shouldimmune and 0 or 1
	end
end

function Upgrader:AbilityManager()
	if #self.ability == 0 then self:InitializeList() end

	local ability = self.ability
	local hatskill = self.hatskill
	local unlockpoint = STATUS.UNLOCKABILITY

	for i = 1, self.skillsort do
		for j = 1, self.skillsort do
			if not ability[i][j] and self[YUKARISTATINDEX[i].."_level"] >= unlockpoint[j] then
				ability[i][j] = true
			end
		end
	end

	for i = 1, self.HatLevel, 1 do
		hatskill[i] = true
	end
	
	self:UpdateAbilityStatus()
end

function Upgrader:UpdateAbilityStatus()
	local ability = self.ability
	
	if ability[1][1] then
		self.InvincibleLearned = true
		self.EmergencyRegenAmount = 3
		self.HealthBonus = 10
	end
	
	if ability[1][2] then
		self.HealthBonus = 30
		self.EmergencyRegenAmount = 5
		self.RegenAmount = 1
		self.RegenCool = 60
	end
	
	if ability[1][3] then
		self.HealthBonus = 50
		self.RegenAmount = 2
		self.EmergencyRegenAmount = 10
		self.RegenCool = 45
		self.CureCool = 180
	end
	
	if ability[1][4] then
		self.NoHealthPanelty = true
		self.EmergencyRegenAmount = 20
		self.HealthBonus = 95
		self.RegenAmount = 2
		self.RegenCool = 30
		self.CureCool = 120
	end
	
	if ability[1][5] then	
		self.IsFight = false
		self.EmergencyRegenAmount = 40
		self.RegenAmount = 4
		self.RegenCool = 15
		self.CureCool = 60
	end
	
	if ability[1][6] then
		self.IsVampire = true  
		self.HealthBonus = 195
	end
	
	if ability[2][1] then
		self.HungerBonus = 25
		self.PowerUpValue = 1
		self.inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY
		self.inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY
	end
	
	if ability[2][2] then
		self.HungerBonus = 50
		self.PowerUpValue = 2
		self.inst.components.temperature.inherentinsulation = TUNING.INSULATION_SMALL
		self.inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_SMALL
	end
	
	if ability[2][3] then
		self.HungerBonus = 75
		self.PowerUpValue = 3
		self.SpikeEater = true
		self.inst.components.eater.strongstomach = true
		self.inst.components.temperature.inherentinsulation = TUNING.INSULATION_MED
		self.inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED
	end
	
	if ability[2][4] then
		self.HungerBonus = 100
		self.PowerUpValue = 4
		self.RotEater = true
		self.inst.components.eater.ignoresspoilage = true
		self.inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE
		self.inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
	end
	
	if ability[2][5] then
		self.IsDamage = true
		self.PowerUpValue = 5
	end	
	
	if ability[2][6] then
		self.HungerBonus = 150
		self.IsAOE = true
	end
	
	if ability[3][1] then	
		self.inst.components.sanity.neg_aura_mult = 0.9
	end
	
	if ability[3][2] then
		self.SanityAbsorption = 0.3
		self.ResistDark = 0.05
		self.SanityBonus = 25
		self.inst.components.sanity.neg_aura_mult = 0.8
	end
	
	if ability[3][3] then
		self.SanityAbsorption = 0.6
		self.SanityBonus = 50
		self.ResistDark = 0.13
		self.inst.components.sanity.neg_aura_mult = 0.7
	end
	
	if ability[3][4] then
		self.SanityAbsorption = 0.9
		self.ResistDark = 0.2
		self.SanityBonus = 75	
		self.inst.components.sanity.neg_aura_mult = 0.66
	end
	
	if ability[3][5] then
		self.ResistDark = 0.46
		self.NightVision = true
	end	
	
	if ability[3][6] then
		self.DodgeChance = 0.2
		self.SanityBonus = 175
		self.inst.components.sanity.neg_aura_mult = 0.33
	end	
	
	if ability[4][1] then
		if self.inst.components.moisture ~= nil then
			self.inst.components.moisture.baseDryingRate = 0.7
		end
		self.PowerGainMultiplier = 1.5
		self.BonusSpeedMult = 1.033
	end
	
	if ability[4][2] then
		self.inst:RemoveTag("youkai")
		self.FastActionLevel = 1
		self.FastPicker = true
		self.PowerBonus = 25
		self.BonusSpeedMult = 1.066
		self.PowerGainMultiplier = 1.75
	end
	
	if ability[4][3] then
		self.inst:AddTag("realyoukai")
		self.FastActionLevel = 2
		self.FastCrafter = true
		self.PowerBonus = 50
		self.BonusSpeedMult = 1.1
		self.PowerGainMultiplier = 2.25
	end
	
	if ability[4][4] then
		self.inst:AddTag("spiderwhisperer")
		self.inst:RemoveTag("scarytoprey")
		self.FastActionLevel = 3
		self.FastResetter = true
		self.IsEfficient = true
		self.inst.components.locomotor:SetTriggersCreep(false)
		self.PowerGainMultiplier = 3
		self.PowerBonus = 75
		self.BonusSpeedMult = 1.133
	end
	
	if ability[4][5] then
		self.inst:AddTag("woodcutter")
		self.FastCutter = true
		self.Ability_45 = true
        self.inst.components.combat:SetRange(3)
	end
	
	if ability[4][6] then
		self.FastActionLevel = 4
		self.FastHarvester = true
		self.BonusSpeedMult = 1.2
	end

	self.inst.FastActionLevel = self.FastActionLevel
end

function Upgrader:ApplyHatAbility(hat)	
	if self.HatEquipped then
		local skill = self.hatskill
		
		self.HatDamageAbsorption = 0.2
		self.HatPowerGain = CONST.HAT_BASE_POWER_GAIN_RATE

		if skill[2] then
			self.HatDodgeChance = 0.05
			self.HatDamageAbsorption = 0.3
			self.HatSpeedMult = 1.05
			self.HatPowerGain = CONST.HAT_BASE_POWER_GAIN_RATE + 0.01
		end
		
		if skill[3] then
			self.PoisonBlocker = true
			self.Insulator = true
			self.HatDodgeChance = 0.1
			self.HatDamageAbsorption = 0.5
			self.HatSpeedMult = 1.1
			self.HatPowerGain = CONST.HAT_BASE_POWER_GAIN_RATE + 0.03
		end
		
		if skill[4] then
			self.FireResist = true
			self.WaterProofer = true
			self.GasBlocker = true
			self.HatDodgeChance = 0.15
			self.HatDamageAbsorption = 0.7
			self.HatSpeedMult = 1.15
			self.HatPowerGain = CONST.HAT_BASE_POWER_GAIN_RATE + 0.05
		end
		
		if skill[5] then
			self.GodTeleport = true
			self.HatDodgeChance = 0.2
			self.HatDamageAbsorption = 0.8
			self.HatSpeedMult = 1.2
			self.HatPowerGain = CONST.HAT_BASE_POWER_GAIN_RATE + 0.1
		end
	else
		self.WaterProofer = false
		self.FireResist = false
		self.GodTeleport = false
		self.GasBlocker = false
		self.PoisonBlocker = false
		self.Insulator = false
		self.HatPowerGain = 0
		self.HatDodgeChance = 0
		self.HatDamageAbsorption = CONST.HAT_NO_DAMAGE_REDUCTION
		self.HatSpeedMult = 1
	end
	
	if hat ~= nil then
		hat:SetSpeedMult(self.HatSpeedMult)
		hat:SetAbsorbPercent(self.HatDamageAbsorption)
		hat:SetWaterProofness(self.WaterProofer)
		hat:SetGasBlocker(self.GasBlocker)
		hat:SetPoisonBlocker(self.PoisonBlocker)
		hat:SetInsulator(self.Insulator)
		self:SetFireDamageScale()
	end

	self.inst.components.power:SetModifier("hatrate", self.HatPowerGain)
end

function Upgrader:UpdateSkillStatus()
	local skill = self.skill

	if self.PowerUpValue ~= 0 then
		skill.dmgmult = "Damage multiplier : "..string.format("%.2f", self.inst.components.combat.damagemultiplier).." (max : "..TUNING.YUKARI.BASE_DAMAGE_MULT + 0.2 * self.PowerUpValue..")"
	end

	if self.ResistDark ~= 0 then
		skill.resistdark = "Reduces sanity decrement from darkness by "..(self.ResistDark * 100).."%" 
	end	

	local winter, summer = self.inst.components.temperature:GetInsulation()
	if winter ~= 0 or summer ~= 0 then
		skill.insulation =  "Total insulation : "..summer.."(summer), "..winter.."(winter)"
	end

	if self.BonusSpeedMult ~= 1 and self.HatSpeedMult ~= 1 then
		skill.speed = "Speed Bonus : "..self.BonusSpeedMult * (self.HatEquipped and self.HatSpeedMult or 1)
	end	

	if self.HatDodgeChance ~= 0 then
		skill.graze = "Graze(Evasion) chance : "..((self.DodgeChance + (self.HatEquipped and self.HatDodgeChance or 0)) * 100).."%"
	end

	if self.PowerGainMultiplier ~= 1 then
		skill.powermult = "Gain more power by "..((self.PowerGainMultiplier - 1) * 100).."%"
	end

	if self.IsVampire then
		skill.lifeleech = "Heals "..(self.IsAOE and 2 or 1).." every hit"
	end

	local friendlylevel = 0 + (self.inst:HasTag("youkai") and 0 or 1) + (self.inst:HasTag("realyoukai") and 1 or 0) + (self.inst:HasTag("spiderwhisperer") and 1 or 0)
	if friendlylevel ~= 0 then
		skill.friendlylevel = "Friendship Level : "..friendlylevel
	end

	if self.SanityAbsorption ~= 0 then
		skill.SanityAbsorption = "Reduces sanity penalty from armor by "..(self.SanityAbsorption * 100).."%"
	end

	if self.inst.components.sanity.neg_aura_mult ~= 1 then
		skill.insanityresist = "Insanity Aura resist : "..((1 - self.inst.components.sanity.neg_aura_mult) * 100).."%"
	end

	if self.RegenAmount ~= 0 and self.RegenCool ~= 0 then
		skill.healthregen = "Heals "..self.RegenAmount.." every "..self.RegenCool.." seconds"
	end

	if self.CureCool ~= 0 then
		skill.cure = "Cure poison every "..self.CureCool.." seconds"
	end

	if self.InvincibleLearned and skill.invincibility == nil then
		local invincibility
		if self.IsInvincible then
			invincibility = STRINGS.INVINCIBILITY.." : "..STRINGS.ACTIVATED
		elseif self.inst.invin_cool > 0 then
			invincibility = STRINGS.INVINCIBILITY.." : "..self.inst.invin_cool..STRINGS.SECONDS
		else
			invincibility = STRINGS.INVINCIBILITY.." : "..STRINGS.READY
		end

		skill.invincibility = invincibility
	end

	if self.inst.components.moisture and self.inst.components.moisture.baseDryingRate ~= 0 and skill.dry == nil then
		skill.dry = "Additional drying speed by "..self.inst.components.moisture.baseDryingRate
	end

	if self.NoHealthPanelty and skill.NoHealthPanelty == nil then
		skill.NoHealthPanelty = "No health penalty after reviving"
	end

	if self.FastPicker and skill.picker == nil then
		skill.picker = "Picks faster"
	end

	if self.FastCrafter and skill.crafter == nil then
		skill.crafter = "Crafts faster"
	end

	if self.FastHarvester and skill.harvester == nil then
		skill.harvester = "Harvests faster"
	end

	if self.FastResetter and skill.resetter == nil then
		skill.resetter = "Reset mines faster"
	end

	if self.FastCutter and skill.woodie == nil then
		skill.woodie = "Chops faster"
	end

	if self.IsAOE and skill.AOE == nil then
		skill.AOE = "40% chance to do area-of-effect with the damage amount of 60% in range 3"
	end

	if self.NightVision and skill.nightvision == nil then
		skill.nightvision = "Enables nightvision when sanity is over 80%"
	end

	if self.IsFight and skill.isfight == nil then
		skill.isfight = "Absorbs incoming damage by 30%"
	end

	if self.Ability_45 and skill.longattack == nil then
		skill.longattack = "Inscreased attack range"
	end

	if self.Ability_45 and skill.realgraze == nil then
		skill.realgraze = "Grazing grants invincibility for a short time"
	end

	if self.IsEfficient and skill.efficient == nil then
		skill.efficient = "Uses tool more effectively"
	end

	if self.SpikeEater and skill.spikeeater == nil then
		skill.spikeeater = "Can eat monster meat."
	end

	if self.RotEater and skill.roteater == nil then
		self.roteater = "Not a picky eater."
	end
end

function Upgrader:ApplyScale(source, scale)
	-- copy of ApplyScale() in DST
	local inst = self.inst
	if scale ~= 1 and scale ~= nil then
        if inst._scalesource == nil then
            inst._scalesource = { [source] = scale }
            inst.Transform:SetScale(scale, scale, scale)
        elseif inst._scalesource[source] ~= scale then
            inst._scalesource[source] = scale
            local scale = 1
            for k, v in pairs(inst._scalesource) do
                scale = scale * v
            end
            inst.Transform:SetScale(scale, scale, scale)
        end
    elseif inst._scalesource ~= nil and inst._scalesource[source] ~= nil then
        inst._scalesource[source] = nil
        if next(inst._scalesource) == nil then
            inst._scalesource = nil
            inst.Transform:SetScale(1, 1, 1)
        else
            local scale = 1
            for k, v in pairs(inst._scalesource) do
                scale = scale * v
            end
            inst.Transform:SetScale(scale, scale, scale)
        end
    end
end

function Upgrader:ApplyStatus()
	local inst = self.inst
	local hunger_percent = inst.components.hunger:GetPercent()
	local health_percent = inst.components.health:GetPercent()
	local sanity_percent = inst.components.sanity:GetPercent()
	local power_percent = inst.components.power:GetPercent()
	local ignoresanity = inst.components.sanity.ignore
    inst.components.sanity.ignore = false
	
	self:AbilityManager()
	inst.components.combat:SetAttackPeriod(self.Ability_45 and 0 or TUNING.WILSON_ATTACK_PERIOD)
	inst.components.health.maxhealth = STATUS.DEFAULT_HP + self.health_level * STATUS.HP_RATE + self.HealthBonus + math.max(0, (self.health_level - 30) * 7.5)
	inst.components.health:SetAbsorptionAmount(1 - (self.IsDamage and 0.7 or 1) * (inst:IsSpellActive("bait") and 0.5 or 1) )
	inst.components.hunger.hungerrate = math.max( 0, (STATUS.DEFAULT_HR - self.hunger_level * STATUS.HR_RATE - math.max(0, (self.hunger_level - 30) * 0.025 )) ) * TUNING.WILSON_HUNGER_RATE 
	inst.components.hunger.max = STATUS.DEFAULT_HU + self.HungerBonus
	inst.components.sanity.max = STATUS.DEFAULT_SN + self.sanity_level * STATUS.SN_RATE + self.SanityBonus + math.max(0, (self.sanity_level - 30) * 5)
	inst.components.power.max = STATUS.DEFAULT_PW + self.power_level * STATUS.PO_RATE + self.PowerBonus + math.max(0, (self.power_level - 30) * 5)
	if _G.DLC_ENABLED_FLAG >= 2 then
		inst.components.locomotor:AddSpeedModifier_Additive("dreadful", self.BonusSpeedMult)
	else
		local speedmod = (self.BonusSpeedMult - 1) * 30
		inst.components.locomotor.runspeed = 6 + speedmod
		inst.components.locomotor.walkspeed = 4 + speedmod
	end
	
	inst.components.health:SetPercent(health_percent)
	inst.components.hunger:SetPercent(hunger_percent)
	inst.components.sanity:SetPercent(sanity_percent)
	inst.components.power:SetPercent(power_percent)
	inst.components.sanity.ignore = ignoresanity
end

return Upgrader