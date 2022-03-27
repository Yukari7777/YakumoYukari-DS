name = "Yakumo Yukari"
description = "Yakumo Yukari comes from unknown world to manipulate Don't Starve world!"
author = "Yakumo Yukari"
version = "0.11.16"
forumthread = ""
api_version = 6

restart_required = true
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
porkland_compatible = true
hamlet_compatible = true
dst_compatible = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- This mod contains major prefab tweaks(AddPrefabPostInit). 
-- Have enough low priority so the mod can be loaded after any other mods to be loaded.
priority = -1

folder_name = folder_name or ""
if not folder_name:find("workshop-") then
    name = name.." - Test"
end

local inspectflag = {}
for i = 1, 3 do inspectflag[i] = { description = "", data = i } end
inspectflag[1].description = "character"
inspectflag[2].description = "console"
inspectflag[3].description = "console, character"

local Keys = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "PERIOD", "SLASH", "SEMICOLON", "TILDE", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "MINUS", "EQUALS", "BACKSPACE", "CAPSLOCK", "SCROLLOCK", "BACKSLASH"}

local KeyOptions = {}
for i = 1, #Keys do KeyOptions[i] = { description = ""..Keys[i].."", data = "KEY_"..Keys[i] } end

configuration_options = {
	{
		name = "language",
		label = "Language",
		hover = "Set Language",
		options = {
			{ description = "Auto", data = "AUTO" },
			--{ description = "한국어", data = "kr" },
			{ description = "English", data = "en" },
			{ description = "中文", data = "ch" },
			--{ description = "русский", data = "ru" },
		},
		default = "AUTO",
	},

	{
		name = "diff",
		label = "Difficulty",
		hover = "Set difficulty.",
		options =
		{
			{ description = "Easy", data = "EASY" },
			{ description = "Normal", data = "" },
			{ description = "Hard", data = "HARD" },
		},
		default = "",
	},

	{
		name = "skill",
		label = "Print status info in",
		hover = "Set where to show the status info should display in.",
		options = inspectflag,
		default = 3,
	},

	{
		name = "skillkey",
		label = "Print status key by",
		hover = "Set which key to press to show the status info.",
		options = KeyOptions,
		default = "KEY_V",
	},
}