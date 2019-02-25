local difficulty = _G.YUKARI_DIFFICULTY 

local Recipes = {}
local IsWorldDLCEnabled = GLOBAL.DLC_ENABLED_FLAG % 4 >= 2 or GLOBAL.DLC_ENABLED_FLAG % 8 >= 4
local IsRoGEnabled = GLOBAL.DLC_ENABLED_FLAG % 2 == 1

local function AddRecipe(name, ingredients, level, game_type, nounlock, recipetab)
	if IsWorldDLCEnabled then
		recipe = Recipe(name, ingredients, recipetab or RECIPETABS.TOUHOU, level, game_type, nil, nil, nounlock)
	elseif game_type == RECIPE_GAME_TYPE.COMMON or (gmae_type == RECIPE_GAME_TYPE.ROG and IsRoGEnabled) then
		-- Vanilla's code doesn't support game_type argument.
		recipe = Recipe(name, ingredients, recipetab or RECIPETABS.TOUHOU, level, nil, nil, nounlock)
	end
	
	if recipe ~= nil then
		recipe.atlas = "images/inventoryimages/"..name..".xml"
		table.insert(Recipes, recipe)
	end
end

local function GetRecipes()
	if not GetPlayer():HasTag("yakumoyukari") then return end

	if difficulty == "EASY" then
		AddRecipe("healthpanel", {Ingredient("spidergland", 2), Ingredient("honey", 1)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("healthpanel", {Ingredient("log", 5), Ingredient("honey", 2)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("hungerpanel", {Ingredient("meatballs", 2)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("hungerpanel", {Ingredient("fishsticks", 2)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("sanitypanel", {Ingredient("petals", 4), Ingredient("nightmarefuel", 1)}, {MAGIC = 2}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("sanitypanel", {Ingredient("seashell", 4)}, {MAGIC = 2}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("powerpanel", {Ingredient("houndstooth", 3), Ingredient("livinglog", 1)}, {MAGIC = 3}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("powerpanel", {Ingredient("shark_fin", 3), Ingredient("livinglog", 1)}, {MAGIC = 3}, RECIPE_GAME_TYPE.SHIPWRECKED)
	else
		AddRecipe("healthpanel", {Ingredient("spidergland", 5), Ingredient("honey", 2)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("healthpanel", {Ingredient("honey", 3), Ingredient("venomgland", 2)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("hungerpanel", {Ingredient("meatballs", 3), Ingredient("bonestew", 1)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("hungerpanel", {Ingredient("fishsticks", 3), Ingredient("surfnturf", 1)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("sanitypanel", {Ingredient("petals_evil", 4), Ingredient("nightmarefuel", 2)}, {MAGIC = 2}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("sanitypanel", {Ingredient("seashell", 6), Ingredient("tar", 6), Ingredient("nightmarefuel", 1)}, {MAGIC = 2}, RECIPE_GAME_TYPE.SHIPWRECKED)
		AddRecipe("powerpanel", {Ingredient("houndstooth", 5), Ingredient("livinglog", 2)}, {MAGIC = 3}, RECIPE_GAME_TYPE.COMMON)
		AddRecipe("powerpanel", {Ingredient("shark_fin", 6), Ingredient("livinglog", 2)}, {MAGIC = 3}, RECIPE_GAME_TYPE.SHIPWRECKED)
	end

	AddRecipe("spellcard_bait", {Ingredient("honey", 4), Ingredient("armorgrass", 1)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_bait", {Ingredient("honey", 2), Ingredient("armorseashell", 1)}, {SCIENCE = 1}, RECIPE_GAME_TYPE.SHIPWRECKED)
	AddRecipe("spellcard_lament", {Ingredient("boards", 2), Ingredient("nightmarefuel", 3)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_butter", {Ingredient("butter", 1)}, {SCIENCE = 2}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_away", {Ingredient("cutreeds", 10), Ingredient("goose_feather", 3)}, {MAGIC = 2}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_balance", {Ingredient("seeds", 5), Ingredient("poop", 3)}, {MAGIC = 2}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_mesh", {Ingredient("nightmarefuel", 5), Ingredient("nitre", 5)}, {MAGIC = 2}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_addictive", {Ingredient("poop", 10), Ingredient("ice", 10), Ingredient("nitre", 5), Ingredient("seeds", 5)}, {MAGIC = 3}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_matter", {Ingredient("rocks", 20), Ingredient("flint", 20), Ingredient("goldnugget", 5), Ingredient("nitre", 3)}, {MAGIC = 3}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_laplace", {Ingredient("nightmarefuel", 5), Ingredient("purplegem", 2)}, {MAGIC = 3}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_necro", {Ingredient("nightmarefuel", 10), Ingredient("thulecite", 4), Ingredient("purplegem", 4)}, {SCIENCE = 2, MAGIC = 3, ANCIENT = 4}, RECIPE_GAME_TYPE.COMMON)
	AddRecipe("spellcard_necro", {Ingredient("nightmarefuel", 8), Ingredient("obsidian", 4), Ingredient("dragoonheart", 2)}, {SCIENCE = 2, MAGIC = 3, OBSIDIAN = 2}, RECIPE_GAME_TYPE.SHIPWRECKED)
	AddRecipe("healthult", {Ingredient("redgem", 10), Ingredient("trunk_winter", 1), Ingredient("trunk_summer", 1)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.COMMON, true)
	AddRecipe("healthult", {Ingredient("dragon_scales", 1), Ingredient("ice", 30), Ingredient("trunk_winter", 1), Ingredient("trunk_summer", 1)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.ROG, true)
	AddRecipe("hungerult", {Ingredient("bluegem", 10), Ingredient("bonestew", 5), Ingredient("armormarble", 1)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.COMMON, true)
	AddRecipe("hungerult", {Ingredient("bearger_fur", 1), Ingredient("bonestew", 5), Ingredient("armormarble", 1)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.ROG, true)
	AddRecipe("sanityult", {Ingredient("purplegem", 10), Ingredient("deerclops_eyeball", 1)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.COMMON, true)
	AddRecipe("sanityult", {Ingredient("deerclops_eyeball", 1), Ingredient("orangegem", 5), Ingredient("yellowgem", 5), Ingredient("greengem", 5) }, {ANCIENT = 4}, RECIPE_GAME_TYPE.ROG, true)
	AddRecipe("powerult", {Ingredient("minotaurhorn", 1), Ingredient("orangegem", 5), Ingredient("yellowgem", 5), Ingredient("greengem", 5)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.COMMON, true)
	AddRecipe("powerult", {Ingredient("minotaurhorn", 1), Ingredient("goose_feather", 5), Ingredient("transistor", 10), Ingredient("gears", 10)}, {ANCIENT = 4}, RECIPE_GAME_TYPE.ROG, true)
	AddRecipe("healthultsw", {Ingredient("ruins_bat", 1), Ingredient("obsidian", 10), Ingredient("nightsword", 2), Ingredient("antivenom", 5)}, {OBSIDIAN = 2}, RECIPE_GAME_TYPE.SHIPWRECKED, true)
	AddRecipe("hungerultsw", {Ingredient("obsidiancoconade", 3), Ingredient("tigereye", 1), Ingredient("doydoyegg", 3)}, {OBSIDIAN = 2}, RECIPE_GAME_TYPE.SHIPWRECKED, true)
	AddRecipe("sanityultsw", {Ingredient("magic_seal", 1), Ingredient("volcanostaff", 1), Ingredient("coral_brain", 4)}, {OBSIDIAN = 2}, RECIPE_GAME_TYPE.SHIPWRECKED, true)
	AddRecipe("powerultsw", {Ingredient("quackenbeak", 1), Ingredient("shark_gills", 3), Ingredient("shark_fin", 20), Ingredient("doydoyfeather", 6)}, {OBSIDIAN = 2}, RECIPE_GAME_TYPE.SHIPWRECKED, true)

	return Recipes
end

return {
	RECIPETAB = {str = "TOUHOU", sort = 10, icon = "touhoutab.tex", icon_atlas = "images/inventoryimages/touhoutab.xml"},
	RECIPES = GetRecipes()
}