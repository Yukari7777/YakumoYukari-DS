local Recipe = GLOBAL.Recipe
local RECIPETABS = GLOBAL.RECIPETABS
local RECIPE_GAME_TYPE = GLOBAL.RECIPE_GAME_TYPE
local TECH = GLOBAL.TECH
local IsDLCEnabled = GLOBAL.IsDLCEnabled

AddClassPostConstruct("widgets/crafttabs", function(inst)
    if inst.prefab == "yakumoyukari" then
	GLOBAL.RECIPETABS['TOUHOU'] = {str = "TOUHOU", sort = 10, icon = "touhoutab.tex", icon_atlas = "images/inventoryimages/touhoutab.xml"}
    end
end)

local function RecipePostInit(yakumoyukari)
	
	if IsDLCEnabled(GLOBAL.CAPY_DLC) then
		if Difficulty == "easy" then
			local healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("log", 5), Ingredient("honey", 2)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
			healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local sw_healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("log", 3), Ingredient("honey", 3)}, RECIPETABS.TOUHOU, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("meatballs", 2)}, RECIPETABS.TOUHOU, {SCIENCE = 2} )
			hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sw_hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("fishsticks", 2)}, RECIPETABS.TOUHOU, {SCIENCE = 2}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("petals", 4), Ingredient("nightmarefuel", 1)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
			sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local sw_sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("seashell", 4)}, RECIPETABS.TOUHOU, {MAGIC = 1}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("purplegem", 1), Ingredient("livinglog", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
			powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
			local sw_powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("goldnugget", 3), Ingredient("livinglog", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
		else
			local healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("log", 10), Ingredient("honey", 5)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
			healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local sw_healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("log", 7), Ingredient("honey", 7)}, RECIPETABS.TOUHOU, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("meatballs", 3), Ingredient("bonestew", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 2} )
			hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sw_hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("fishsticks", 3), Ingredient("surfnturf", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 2}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("petals_evil", 4), Ingredient("nightmarefuel", 2)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
			sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local sw_sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("seashell", 10), Ingredient("nightmarefuel", 2)}, RECIPETABS.TOUHOU, {MAGIC = 1}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("purplegem", 3), Ingredient("livinglog", 3)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
			powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
			local sw_powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("goldnugget", 10), Ingredient("livinglog", 3)}, RECIPETABS.TOUHOU, {MAGIC = 2}, RECIPE_GAME_TYPE.SHIPWRECKED )
			sw_powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
		end
		
		
		local spellcardbaitrecipe = Recipe( ("spellcard_bait"), {Ingredient("honey", 4), Ingredient("armorgrass", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1}, RECIPE_GAME_TYPE.ROG, nil, nil, true )
		spellcardbaitrecipe.atlas = "images/inventoryimages/spellcard_bait.xml"
		local sw_spellcardbaitrecipe = Recipe( ("spellcard_bait"), {Ingredient("honey", 2), Ingredient("armorseashell", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true )
		sw_spellcardbaitrecipe.atlas = "images/inventoryimages/spellcard_bait.xml"
		local spelllamentrecipe = Recipe( ("spellcard_lament"), {Ingredient("boards", 3), Ingredient("nightmarefuel", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
		spelllamentrecipe.atlas = "images/inventoryimages/spellcard_lament.xml"
		local spellbutterrecipe = Recipe( ("spellcard_butter"), {Ingredient("butter", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1})
		spellbutterrecipe.atlas = "images/inventoryimages/spellcard_butter.xml"
		local spellawayrecipe = Recipe( ("spellcard_away"), {Ingredient("cutreeds", 10), Ingredient("goose_feather", 3)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
		spellawayrecipe.atlas = "images/inventoryimages/spellcard_away.xml"
		local spellbalancerecipe = Recipe( ("spellcard_balance"), {Ingredient("seeds", 5), Ingredient("poop", 3)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
		spellbalancerecipe.atlas = "images/inventoryimages/spellcard_balance.xml"
		local spelladdictiverecipe = Recipe( ("spellcard_addictive"), {Ingredient("poop", 10), Ingredient("ice", 10), Ingredient("nitre", 5), Ingredient("seeds", 5)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spelladdictiverecipe.atlas = "images/inventoryimages/spellcard_addictive.xml"
		local spellmatterrecipe = Recipe( ("spellcard_matter"), {Ingredient("rocks", 20), Ingredient("flint", 20), Ingredient("goldnugget", 5), Ingredient("nitre", 3)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellmatterrecipe.atlas = "images/inventoryimages/spellcard_matter.xml"
		local spellmeshrecipe = Recipe( ("spellcard_mesh"), {Ingredient("nightmarefuel", 5), Ingredient("nitre", 5)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellmeshrecipe.atlas = "images/inventoryimages/spellcard_mesh.xml"
		local spellcurserecipe = Recipe( ("spellcard_curse"), {Ingredient("nightmarefuel", 5), Ingredient("livinglog", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellcurserecipe.atlas = "images/inventoryimages/spellcard_curse.xml"
		local spelllaplacerecipe = Recipe( ("spellcard_laplace"), {Ingredient("nightmarefuel", 5), Ingredient("purplegem", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spelllaplacerecipe.atlas = "images/inventoryimages/spellcard_laplace.xml"
		local healthultrecipe = Recipe( ("healthult"), {Ingredient("dragon_scales", 1), Ingredient("trunk_winter", 1), Ingredient("ice", 30)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, RECIPE_GAME_TYPE.ROG, nil, nil, true)
		healthultrecipe.atlas = "images/inventoryimages/healthult.xml"
		local hungerultrecipe = Recipe( ("hungerult"), {Ingredient("bearger_fur", 1), Ingredient("armormarble", 1), Ingredient("bonestew", 5)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, RECIPE_GAME_TYPE.ROG, nil, nil, true)
		hungerultrecipe.atlas = "images/inventoryimages/hungerult.xml"
		local sanityultrecipe = Recipe( ("sanityult"), {Ingredient("deerclops_eyeball", 1), Ingredient("orangegem", 3), Ingredient("yellowgem", 3), Ingredient("greengem", 3)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, RECIPE_GAME_TYPE.ROG, nil, nil, true)
		sanityultrecipe.atlas = "images/inventoryimages/sanityult.xml"
		local powerultrecipe = Recipe( ("powerult"), {Ingredient("minotaurhorn", 1), Ingredient("goose_feather", 5), Ingredient("transistor", 10), Ingredient("gears", 10)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, RECIPE_GAME_TYPE.ROG, nil, nil, true)
		powerultrecipe.atlas = "images/inventoryimages/powerult.xml"
		local spellnecrorecipe = Recipe( ("spellcard_necro"), {Ingredient("thulecite", 10), Ingredient("purplegem", 10), Ingredient("greengem", 2)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, RECIPE_GAME_TYPE.ROG, nil, nil, true)
		spellnecrorecipe.atlas = "images/inventoryimages/spellcard_necro.xml"
		local sw_healthultrecipe = Recipe( ("healthultsw"), {Ingredient("ruins_bat", 1), Ingredient("nightsword", 2), Ingredient("antivenom", 5), Ingredient("obsidian", 10)}, RECIPETABS.TOUHOU, TECH.OBSIDIAN_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true)
		sw_healthultrecipe.atlas = "images/inventoryimages/healthultsw.xml"
		local sw_hungerultrecipe = Recipe( ("hungerultsw"), {Ingredient("volcanostaff", 1), Ingredient("obsidiancoconade", 3), Ingredient("dragoonheart", 3)}, RECIPETABS.TOUHOU, TECH.OBSIDIAN_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true)
		sw_hungerultrecipe.atlas = "images/inventoryimages/hungerultsw.xml"
		local sw_sanityultrecipe = Recipe( ("sanityultsw"), {Ingredient("magic_seal", 1), Ingredient("tigereye", 1), Ingredient("coral_brain", 4)}, RECIPETABS.TOUHOU, TECH.OBSIDIAN_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true)
		sw_sanityultrecipe.atlas = "images/inventoryimages/sanityultsw.xml"
		local sw_powerultrecipe = Recipe( ("powerultsw"), {Ingredient("doydoyegg", 3), Ingredient("shark_gills", 3), Ingredient("shark_fin", 4), Ingredient("doydoyfeather", 6)}, RECIPETABS.TOUHOU, TECH.OBSIDIAN_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true)
		sw_powerultrecipe.atlas = "images/inventoryimages/powerultsw.xml"
		local sw_spellnecrorecipe = Recipe( ("spellcard_necro"), {Ingredient("obsidian", 10), Ingredient("purplegem", 3), Ingredient("magic_seal", 1)}, RECIPETABS.TOUHOU, TECH.OBSIDIAN_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, true)
		sw_spellnecrorecipe.atlas = "images/inventoryimages/spellcard_necro.xml"
	else
	
		if Difficulty == "easy" then
			local healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("healingsalve", 1), Ingredient("log", 2)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
			healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("meatballs", 3)}, RECIPETABS.TOUHOU, {SCIENCE = 2} )
			hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("petals", 3), Ingredient("nightmarefuel", 1)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
			sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("purplegem", 1), Ingredient("livinglog", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
			powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
		else
			local healthpanelrecipe = Recipe( ("healthpanel"), {Ingredient("healingsalve", 2), Ingredient("log", 3)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
			healthpanelrecipe.atlas = "images/inventoryimages/healthpanel.xml"
			local hungerpanelrecipe = Recipe( ("hungerpanel"), {Ingredient("bonestew", 1), Ingredient("meatballs", 2)}, RECIPETABS.TOUHOU, {SCIENCE = 2} )
			hungerpanelrecipe.atlas = "images/inventoryimages/hungerpanel.xml"
			local sanitypanelrecipe = Recipe( ("sanitypanel"), {Ingredient("petals", 4), Ingredient("nightmarefuel", 2)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
			sanitypanelrecipe.atlas = "images/inventoryimages/sanitypanel.xml"
			local powerpanelrecipe = Recipe( ("powerpanel"), {Ingredient("purplegem", 2), Ingredient("livinglog", 3)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
			powerpanelrecipe.atlas = "images/inventoryimages/powerpanel.xml"
		end
		
		local spellcardbaitrecipe = Recipe( ("spellcard_bait"), {Ingredient("honey", 4), Ingredient("armorgrass", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
		spellcardbaitrecipe.atlas = "images/inventoryimages/spellcard_bait.xml"
		local spelllamentrecipe = Recipe( ("spellcard_lament"), {Ingredient("boards", 3), Ingredient("nightmarefuel", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1} )
		spelllamentrecipe.atlas = "images/inventoryimages/spellcard_lament.xml"
		local spellbutterrecipe = Recipe( ("spellcard_butter"), {Ingredient("butter", 1)}, RECIPETABS.TOUHOU, {SCIENCE = 1})
		spellbutterrecipe.atlas = "images/inventoryimages/spellcard_butter.xml"
		local spellawayrecipe = Recipe( ("spellcard_away"), {Ingredient("cutreeds", 10), Ingredient("goose_feather", 3)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
		spellawayrecipe.atlas = "images/inventoryimages/spellcard_away.xml"
		local spellbalancerecipe = Recipe( ("spellcard_balance"), {Ingredient("seeds", 5), Ingredient("poop", 3)}, RECIPETABS.TOUHOU, {MAGIC = 1} )
		spellbalancerecipe.atlas = "images/inventoryimages/spellcard_balance.xml"
		local spelladdictiverecipe = Recipe( ("spellcard_addictive"), {Ingredient("poop", 10), Ingredient("ice", 10), Ingredient("nitre", 5), Ingredient("seeds", 5)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spelladdictiverecipe.atlas = "images/inventoryimages/spellcard_addictive.xml"
		local spellmatterrecipe = Recipe( ("spellcard_matter"), {Ingredient("rocks", 20), Ingredient("flint", 20), Ingredient("goldnugget", 5), Ingredient("nitre", 3)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellmatterrecipe.atlas = "images/inventoryimages/spellcard_matter.xml"
		local spellmeshrecipe = Recipe( ("spellcard_mesh"), {Ingredient("nightmarefuel", 5), Ingredient("nitre", 5)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellmeshrecipe.atlas = "images/inventoryimages/spellcard_mesh.xml"
		local spellcurserecipe = Recipe( ("spellcard_curse"), {Ingredient("nightmarefuel", 5), Ingredient("livinglog", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spellcurserecipe.atlas = "images/inventoryimages/spellcard_curse.xml"
		local spelllaplacerecipe = Recipe( ("spellcard_laplace"), {Ingredient("nightmarefuel", 5), Ingredient("purplegem", 2)}, RECIPETABS.TOUHOU, {MAGIC = 2} )
		spelllaplacerecipe.atlas = "images/inventoryimages/spellcard_laplace.xml"
		local healthultrecipe = Recipe( ("healthult"), {Ingredient("dragon_scales", 1), Ingredient("trunk_winter", 1), Ingredient("ice", 30)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, nil, nil, true)
		healthultrecipe.atlas = "images/inventoryimages/healthult.xml"
		local hungerultrecipe = Recipe( ("hungerult"), {Ingredient("bearger_fur", 1), Ingredient("armormarble", 1), Ingredient("bonestew", 5)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, nil, nil, true)
		hungerultrecipe.atlas = "images/inventoryimages/hungerult.xml"
		local sanityultrecipe = Recipe( ("sanityult"), {Ingredient("deerclops_eyeball", 1), Ingredient("orangegem", 3), Ingredient("yellowgem", 3), Ingredient("greengem", 3)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, nil, nil, true)
		sanityultrecipe.atlas = "images/inventoryimages/sanityult.xml"
		local powerultrecipe = Recipe( ("powerult"), {Ingredient("minotaurhorn", 1), Ingredient("goose_feather", 5), Ingredient("transistor", 10), Ingredient("gears", 10)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR, nil, nil, true)
		powerultrecipe.atlas = "images/inventoryimages/powerult.xml"
		local spellnecrorecipe = Recipe( ("spellcard_necro"), {Ingredient("thulecite", 10), Ingredient("purplegem", 10), Ingredient("greengem", 2)}, RECIPETABS.TOUHOU, TECH.ANCIENT_FOUR)
		spellnecrorecipe.atlas = "images/inventoryimages/spellcard_necro.xml"
	end
end

AddPrefabPostInit("yakumoyukari", RecipePostInit)