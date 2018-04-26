Upgrader = Class(function(self, inst) -- hmm.. This is more like upgrade manager..
    self.inst = inst
	
	self.healthbonus = 0
	self.hungerbonus = 0
	self.sanitybonus = 0
	self.powerbonus = 0
	self.hatpowerbonus = 0
	self.powergenbonus = 0
	self.bonusspeed = 0
	self.hatbonusspeed = 0
	
	self.resisttemp = 1
	self.powerupvalue = 0
	self.regenamount = 0
	self.regencool = 1
	self.curecool = 1
	self.dtmult = 1.2
	self.SightDistance = 0
	self.dodgechance = 0

	self.emergency = nil
	
	self.IsPoisonCure = false
	self.IsDamage = false
	self.IsVampire = false
	self.IsAOE = false
	self.IsEfficient = false
	self.IsFight = false
	self.ResistDark = false
	self.ResistCave = false
	self.InvincibleLearned = false
	self.CanbeInvincible = false
	self.WaterProofed = false
	self.FireResist = false
	self.PoisonResist = false
	self.GodTelepoirt = false
	
	self.ability = {}
	self.skillsort = 4
	self.skilllevel = 6
	for i = 1, self.skillsort, 1 do
		self.ability[i] = {}
		for j = 1, self.skilllevel, 1 do
			self.ability[i][j] = false
		end
	end -- This is a table that stores skills.
	
	self.hatskill = {}
	for i = 1, 5, 1 do
		self.hatskill[i] = false
	end
	
	
	self.old_tiny = 100/(TUNING.SEG_TIME*32)
	self.old_small = 100/(TUNING.SEG_TIME*8)
	self.old_med = 100/(TUNING.SEG_TIME*5)
	self.old_large = 100/(TUNING.SEG_TIME*2)
	self.old_huge = 100/(TUNING.SEG_TIME*0.5)
	
	self.old_crazysmall = TUNING.CRAZINESS_SMALL 
	self.old_crazymed = TUNING.CRAZINESS_MED
	
end)

function GetUpgradeCount()
	local G = GetPlayer()
	return {G.health_level, G.hunger_level, G.sanity_level, G.power_level}
end

function Upgrader:IsHatValid(inst)
	return inst.hatequipped 
end

function Upgrader:AbilityManager(inst)

	local ability = inst.components.upgrader.ability
	local hatskill = inst.components.upgrader.hatskill
	local level = GetUpgradeCount()
	local point = {5, 10, 17, 25}

	for i = 1, 4, 1 do
		for j = 1, 4, 1 do
			if not ability[i][j] and level[i] >= point[j] then
				ability[i][j] = true
			end
		end
	end

	for i = 1, inst.hatlevel, 1 do
		hatskill[i] = true
	end
	
	inst.components.upgrader:SkillManager(inst)
	inst.components.upgrader:HatSkillManager(inst)
end

function Upgrader:SkillManager(inst)

	local skill = inst.components.upgrader.ability
	
	if skill[1][1] then
		inst.components.upgrader.healthbonus = 10
		TUNING.HEALING_TINY = 2
	    TUNING.HEALING_SMALL = 5
	    TUNING.HEALING_MEDSMALL = 12
	    TUNING.HEALING_MED = 30
	    TUNING.HEALING_MEDLARGE = 35
	    TUNING.HEALING_LARGE = 50
	    TUNING.HEALING_HUGE = 75
	    TUNING.HEALING_SUPERHUGE = 300
	end
	
	if skill[1][2] then
		inst.components.upgrader.healthbonus = 30
		inst.components.upgrader.regenamount = 1
		inst.components.upgrader.regencool = 60
	end
	
	if skill[1][3] then
		inst.components.upgrader.IsPoisonCure = true
		inst.components.upgrader.healthbonus = 50
		inst.components.upgrader.regenamount = 2
		inst.components.upgrader.regencool = 60
		inst.components.upgrader.curecool = 180
	end
	
	if skill[1][4] then
		inst.components.upgrader.healthbonus = 95
		inst.components.upgrader.regenamount = 2
		inst.components.upgrader.regencool = 30
		inst.components.upgrader.curecool = 120
	end
	
	if skill[1][5] then	
		inst.components.upgrader.InvincibleLearned = true
		inst.components.upgrader.regenamount = 4
		inst.components.upgrader.regencool = 30
		inst.components.upgrader.curecool = 80
	end
	
	if skill[1][6] then
		inst.components.upgrader.IsVampire = true  
	end
	
	if skill[2][1] then
		inst.components.upgrader.hungerbonus = 25
		inst.components.upgrader.powerupvalue = 1
		TUNING.INSULATION_TINY = 60
		TUNING.INSULATION_SMALL = 120
		TUNING.INSULATION_MED = 240
		TUNING.INSULATION_LARGE = 480
	end
	
	if skill[2][2] then
		inst.components.upgrader.hungerbonus = 50
		inst.components.upgrader.powerupvalue = 2
		TUNING.INSULATION_TINY = 90
		TUNING.INSULATION_SMALL = 180
		TUNING.INSULATION_MED = 360
		TUNING.INSULATION_LARGE = 720
	end
	
	if skill[2][3] then
		inst.components.upgrader.hungerbonus = 75
		inst.components.upgrader.powerupvalue = 3
		TUNING.INSULATION_TINY = 120
		TUNING.INSULATION_SMALL = 240
		TUNING.INSULATION_MED = 480
		TUNING.INSULATION_LARGE = 960
	end
	
	if skill[2][4] then
		inst.components.upgrader.hungerbonus = 100
		inst.components.upgrader.powerupvalue = 4
		TUNING.INSULATION_TINY = 150
		TUNING.INSULATION_SMALL = 300
		TUNING.INSULATION_MED = 600
		TUNING.INSULATION_LARGE = 1200
	end
	
	if skill[2][5] then
		inst.components.upgrader.IsDamage = true
		inst.components.upgrader.powerupvalue = 5
	end	
	
	if skill[2][6] then
		inst.components.upgrader.IsAOE = true
	end
	
	if skill[3][1] then	
		TUNING.SANITYAURA_TINY = inst.components.upgrader.old_tiny * 0.7 
		TUNING.SANITYAURA_SMALL = inst.components.upgrader.old_small * 0.75
		TUNING.SANITYAURA_MED = inst.components.upgrader.old_med * 0.8
		TUNING.SANITYAURA_LARGE = inst.components.upgrader.old_large * 0.9
		TUNING.SANITYAURA_HUGE = inst.components.upgrader.old_huge * 0.95
	end
	
	if skill[3][2] then
		inst.components.upgrader.ResistDark = true
		inst.components.upgrader.sanitybonus = 25	
		TUNING.CRAZINESS_SMALL = inst.components.upgrader.old_crazysmall * 0.3
		TUNING.CRAZINESS_MED = inst.components.upgrader.old_crazysmall * 0.4
	end
	
	if skill[3][3] then
		inst.components.upgrader.sanitybonus = 50
		inst.components.upgrader.ResistCave = true		
		TUNING.SANITYAURA_TINY = inst.components.upgrader.old_tiny * 0.2 
		TUNING.SANITYAURA_SMALL = inst.components.upgrader.old_small * 0.3
		TUNING.SANITYAURA_MED = inst.components.upgrader.old_med * 0.4
		TUNING.SANITYAURA_LARGE = inst.components.upgrader.old_large * 0.65
		TUNING.SANITYAURA_HUGE = inst.components.upgrader.old_huge * 0.8
	end
	
	if skill[3][4] then
		inst.components.upgrader.sanitybonus = 75	
		TUNING.SANITYAURA_TINY = 0
		TUNING.SANITYAURA_SMALL = inst.components.upgrader.old_small * 0.1
		TUNING.SANITYAURA_MED = inst.components.upgrader.old_med * 0.2
		TUNING.SANITYAURA_LARGE = inst.components.upgrader.old_large * 0.3
		TUNING.SANITYAURA_HUGE = inst.components.upgrader.old_huge * 0.4
	end
	
	if skill[3][5] then
		inst.components.upgrader.NightVision = true
	end	
	
	if skill[3][6] then
		inst.components.upgrader.IsFight = true
		TUNING.SANITYAURA_TINY = 0
		TUNING.SANITYAURA_SMALL = 0
		TUNING.SANITYAURA_MED = 0
		TUNING.SANITYAURA_LARGE = 0
		TUNING.SANITYAURA_HUGE = 0
	end	
	
	if skill[4][1] then
		inst.components.upgrader.bonusspeed = 1
		inst.components.upgrader.powerbonus = 25
		inst.components.upgrader.powergenbonus = 0.25
		TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY = 0.025
		TUNING.ARMOR_SANITY_DMG_AS_SANITY = 0.05
		if IsDLCEnabled(CAPY_DLC) then
			TUNING.ARMORMARBLE_SLOW = -0.1
		else
			TUNING.ARMORMARBLE_SLOW = 0.9
		end
	end
	
	if skill[4][2] then
		inst:RemoveTag("youkai")
		inst:RemoveTag("monster")
		inst.components.upgrader.powerbonus = 50
		inst.components.upgrader.powergenbonus = 0.5
		TUNING.NIGHTSWORD_USES = 140
		TUNING.ARMOR_SANITY = 1000
	    TUNING.ICESTAFF_USES = 25 -- increased by 20~25%
	    TUNING.FIRESTAFF_USES = 25
	    TUNING.TELESTAFF_USES = 6
		TUNING.REDAMULET_USES = 25
		TUNING.YELLOWSTAFF_USES = 25
		TUNING.ORANGESTAFF_USES = 25
		TUNING.GREENAMULET_USES = 6
		TUNING.GREENSTAFF_USES = 6
		TUNING.PANFLUTE_USES = 12
		TUNING.HORN_USES = 12
	end
	
	if skill[4][3] then
		inst.components.upgrader.powerbonus = 75
		inst.components.upgrader.bonusspeed = 2
		inst.components.upgrader.powergenbonus = 1
	end
	
	if skill[4][4] then
		inst:AddTag("realyoukai")
		inst.components.upgrader.powerbonus = 175
		inst.components.upgrader.bonusspeed = 3
	end
	
	if skill[4][5] then
		inst.components.combat:SetAttackPeriod(0)
        inst.components.combat:SetRange(3.2)
	end
	
	if skill[4][6] then
		inst.components.upgrader.IsEfficient = true
		inst.components.upgrader.bonusspeed = 4
		GetPlayer().components.moisture.baseDryingRate = 0.5
	end
	
end

function Upgrader:HatSkillManager(inst)

	local IsValid = inst.components.upgrader:IsHatValid(inst)

	if IsValid then
		local skill = inst.components.upgrader.hatskill
		
		if skill[2] then
			inst.components.upgrader.SightDistance = 1
			inst.components.upgrader.hatdodgechance = 0.1
		end
		
		if skill[3] then
			inst.components.upgrader.WaterProofed = true
			inst.components.upgrader.hatpowerbonus = 20
			inst.components.upgrader.hatdodgechance = 0.2
			inst.components.upgrader.dtmult = 1.5
		end
		
		if skill[4] then
			inst.components.upgrader.FireResist = true
			inst.components.upgrader.PoisonResist = true
			inst.components.upgrader.SightDistance = 2
			inst.components.upgrader.hatpowerbonus = 50
			inst.components.upgrader.hatbonusspeed = 1
			inst.components.upgrader.hatdodgechance = 0.3
			inst.components.upgrader.dtmult = 1.7
		end
		
		if skill[5] then
			inst.components.upgrader.hatpowerbonus = 100
			inst.components.upgrader.dtmult = 2.5
			inst.components.upgrader.hatdodgechance = 0.4
			inst.components.upgrader.GodTelepoirt = true
		end
		
	else
		inst.components.upgrader.WaterProofed = false
		inst.components.upgrader.FireResist = false
		inst.components.upgrader.PoisonResist = false
		inst.components.upgrader.GodTelepoirt = false
		inst.components.upgrader.SightDistance = 0
		inst.components.upgrader.hatpowerbonus = 0
		inst.components.upgrader.hatdodgechance = 0
		inst.components.upgrader.dtmult = 1.2
	end
end

function Upgrader:DoUpgrade(inst, stat) 
	local hunger_percent = inst.components.hunger:GetPercent()
	local health_percent = inst.components.health:GetPercent()
	local sanity_percent = inst.components.sanity:GetPercent()
	local power_percent = inst.components.power:GetPercent()
	
	local difficulty = GetModConfigData("difficulty", "YakumoYukari")
	local STATUS = TUNING.STATUS_DEFAULT
	if difficulty == "easy" then
		STATUS = TUNING.STATUS_EASY
	elseif difficulty == "hard" then
		STATUS = TUNING.STATUS_HARD
	end
	
	if stat then
		if stat == 1 then
			inst.health_level = inst.health_level + 1
			inst.HUD.controls.status.heart:PulseGreen()
			inst.HUD.controls.status.heart:ScaleTo(1.3,1,.7)
			inst.components.health.maxhealth = STATUS.DEFAULT_HP + inst.health_level * STATUS.HP_RATE + self.healthbonus + math.max(0, (inst.health_level - 30) * 7.5)
			inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_UPGRADE_HEALTH")) -- will add random more talk
		elseif stat == 2 then
			inst.hunger_level = inst.hunger_level + 1
			inst.HUD.controls.status.stomach:PulseGreen()
			inst.HUD.controls.status.stomach:ScaleTo(1.3,1,.7)
			inst.components.hunger.hungerrate = math.max( 0, (STATUS.DEFAULT_HR - inst.hunger_level * STATUS.HR_RATE - math.max(0, (inst.hunger_level - 30) * 0.025 )) * TUNING.WILSON_HUNGER_RATE )
			inst.components.hunger.max = STATUS.DEFAULT_HU + self.hungerbonus
			inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_UPGRADE_HUNGER"))
		elseif stat == 3 then
			inst.sanity_level = inst.sanity_level + 1
			inst.HUD.controls.status.brain:PulseGreen()
			inst.HUD.controls.status.brain:ScaleTo(1.3,1,.7)
			inst.components.sanity.max = STATUS.DEFAULT_SN + inst.sanity_level * STATUS.SN_RATE + self.sanitybonus + math.max(0, (inst.sanity_level - 30) * 5)
			inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_UPGRADE_SANITY"))
		elseif stat == 4 then
			inst.power_level = inst.power_level + 1
			inst.HUD.controls.status.power:PulseGreen()
			inst.HUD.controls.status.power:ScaleTo(1.3,1,.7)
			inst.components.power.max = STATUS.DEFAULT_PW + inst.power_level * STATUS.PO_RATE + self.powerbonus + self.hatpowerbonus + math.max(0, (inst.power_level - 30) * 5)
			inst.components.power.regenrate = STATUS.DEFAULT_PR + inst.power_level * STATUS.PR_RATE + self.powergenbonus
			inst.components.locomotor.walkspeed = 4 + self.bonusspeed + self.hatbonusspeed
			inst.components.locomotor.runspeed = 6 + self.bonusspeed + self.hatbonusspeed
			inst.components.talker:Say(GetString(inst.prefab, "DESCRIBE_UPGRADE_POWER"))	
		end	
	else 
		inst.components.health.maxhealth = STATUS.DEFAULT_HP + inst.health_level * STATUS.HP_RATE + self.healthbonus + math.max(0, (inst.health_level - 30) * 7.5)
		inst.components.hunger.hungerrate = math.max( 0, (STATUS.DEFAULT_HR - inst.hunger_level * STATUS.HR_RATE - math.max(0, (inst.hunger_level - 30) * 0.025 )) ) * TUNING.WILSON_HUNGER_RATE 
		inst.components.hunger.max = STATUS.DEFAULT_HU + self.hungerbonus
		inst.components.sanity.max = STATUS.DEFAULT_SN + inst.sanity_level * STATUS.SN_RATE + self.sanitybonus + math.max(0, (inst.sanity_level - 30) * 5)
		inst.components.power.max = STATUS.DEFAULT_PW + inst.power_level * STATUS.PO_RATE + self.powerbonus + self.hatpowerbonus + math.max(0, (inst.power_level - 30) * 5)
		inst.components.power.regenrate = STATUS.DEFAULT_PR + inst.power_level * STATUS.PR_RATE + self.powergenbonus
		inst.components.locomotor.walkspeed = 4 + self.bonusspeed + self.hatbonusspeed
		inst.components.locomotor.runspeed = 6 + self.bonusspeed + self.hatbonusspeed
	end
	
	inst.components.upgrader:AbilityManager(inst)
	inst.components.health:SetPercent(health_percent)
	inst.components.hunger:SetPercent(hunger_percent)
	inst.components.sanity:SetPercent(sanity_percent)
	inst.components.power:SetPercent(power_percent)
	
end

return Upgrader