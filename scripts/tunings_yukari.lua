TUNING.YUKARI = { -- constants
	MAX_SKILL_LEVEL = 6,
	MAX_HATSKILL_LEVEL = 5,

	BASE_SCALE = 0.95,
	SCALING_MULT = 0.15,

	SIGHT_RADIUS = 6,
	HAT_NIGHT_DRAIN_ABSORB_MULT = 0.2,
	REGEN_HEALTH = 0.5,
	NIGHT_VISION_SANITY = 0.9,

	SKILLPAGE_BASE = 3,
	STACK_SIZE_SPELLCARD = 20,

	BASE_DAMAGE_MULT = 1.2,
	POWERUP_MULT = 0.2,
	AOE_DAMAGE_PERCENT = 0.6,
	AOE_RADIUS = 3,

	TELEPORT_POWER_COST = 33,
	SPAWNG_POWER_COST = 75,

	HAT_BASE_POWER_GAIN_RATE = 0.1,
	HAT_NO_DAMAGE_REDUCTION = 0.01,

	UMBRE_DAMAGE = 6,
	UMBRE_DAMAGE_SMALL = 1,

	SPELL_POWERCOST_NORMAL = 1,
	SPELLTEST_POWERCOST = 5,
	SPELLTEST_USES = 3,
	SPELLMESH_POWERCOST = 60,
	SPELLMESH_USES = 3,
	SPELLAWAY_USES = 200,
	SPELLNECRO_POWERCOST = 300,
	SPELLCURSE_USES = 200,
	SPELLBALANCE_POWERCOST = 100,
	SPELLBALANCE_SANITYCOST = 75,
	SPELLLAPLACE_USES = 1500,
	SPELLLAPLACE_SANITYCOST = 30,
	SPELLBUTTER_POWERCOST = 80,
	SPELLBAIT_USES = 300,
	SPELLADDICTIVE_POWERCOST = 300,
	SPELLADDICTIVE_SANITYCOST = 200,
	SPELLLAMENT_POWERCOST = 60,
	SPELLMATTER_POWERCOST = 150,
	SPELLMATTER_SANITYCOST = 100,

	UPGRADEPANEL_INGREDIENT = {
		{"honey", "healingsalve", "bandage"},
		{"berries", "meatballs", "bonestew"},
		{"petals", "nightmarefuel", "purplegem"},
		{"goldnugget", "livinglog", "thulecite"}
	},

	UPGRADEPANEL_INGREDIENT_SW = {
		{"spidergland", "healingsalve", "bandage"},
		{"berries", "fishsticks", "surfnturf"},
		{"petals", "taffy", "livinglog"},
		{"goldnugget", "nightmarefuel", "obsidian"}
	},

	SCHEME_INGREDIENT = {
		{{"rocks", 80}, {"log", 80}, {"rope", 20}},
		{{"silk", 30}, {"pigskin", 20}, {"tentaclespots", 10}, {"deserthat", 1}},
		{{"monstermeat", 60}, {"nightmarefuel", 50}, {"livinglog", 20}, {"armordragonfly", 1}},
		{{"thulecite", 20}, {"spellcard_away", 10}, {"spellcard_matter", 5}, {"spellcard_laplace", 2}, {"spellcard_necro", 1}}
	},
	
	SCHEME_INGREDIENT_SW = {
		{{"rocks", 30}, {"log", 30}, {"bamboo", 10}, {"vine", 10}},
		{{"tar", 30}, {"silk", 20}, {"pigskin", 10}, {"limestone", 10}, {"strawhat", 1}},
		{{"monstermeat", 30}, {"fish", 30}, {"antivenom", 10}, {"quackenbeak", 1}, {"shark_gills", 1}},
		{{"obsidian", 40}, {"dragoonheart", 20}, {"spellcard_away", 10}, {"spellcard_matter", 5}, {"spellcard_balance", 5}, {"spellcard_curse", 3}, {"spellcard_laplace", 3}, {"spellcard_necro", 1}}
	},
}

TUNING.YUKARI_STATUS = {
	UNLOCKABILITY = {5, 10, 17, 25},
	MAX_UPGRADE = 25,
	DEFAULT_HP = 80,
	DEFAULT_HU = 150,
	DEFAULT_HR = 1.5,
	DEFAULT_SN = 75,
	DEFAULT_PW = 75,
	DEFAULT_PR = 0.1,
	HP_RATE = 225/25,
	HR_RATE = 0.6/25,
	SN_RATE = 150/25,
	PO_RATE = 150/25,
	PR_RATE = 1/50,

	POWER_RESTORE_PERISH_MULT = 0.5,
	INVINCIBLE_COOLTIME = 1440,
}

TUNING.YUKARI_STATUSHARD = {
	UNLOCKABILITY = {5, 10, 20, 30},
	MAX_UPGRADE = 30,
	DEFAULT_HP = 80,
	DEFAULT_HU = 150,
	DEFAULT_HR = 1.5,
	DEFAULT_SN = 75,
	DEFAULT_PW = 75,
	DEFAULT_PR = 0.1,
	HP_RATE = 225/30,
	HR_RATE = 0.6/30,
	SN_RATE = 150/30,
	PO_RATE = 150/30,
	PR_RATE = 1/50,

	POWER_RESTORE_PERISH_MULT = 1,
	INVINCIBLE_COOLTIME = 2160,
}

TUNING.YUKARI_STATUSEASY = {
	UNLOCKABILITY = {5, 10, 15, 20},
	MAX_UPGRADE = 20,
	DEFAULT_HP = 125,
	DEFAULT_HU = 150,
	DEFAULT_HR = 1.2,
	DEFAULT_SN = 105,
	DEFAULT_PW = 120,
	DEFAULT_PR = 0.1,
	HP_RATE = 180/20,
	HR_RATE = 0.46/20,
	SN_RATE = 120/20,
	PO_RATE = 105/20,
	PR_RATE = 1/25,

	POWER_RESTORE_PERISH_MULT = 0.75,
	INVINCIBLE_COOLTIME = 720,
}