name = "Yakumo Yukari"
description = "Yakumo Yukari comes from unknown world to manipulate Don't Starve world!"
author = "Yakumo Yukari"
version = "0.10.0.13"
forumthread = ""
api_version = 6

dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = {

	{
		name = "language",
		label = "Language",
		options =
		{
			{ description = "中 文", data = "chinese" },
			{ description = "English", data = "default" },
		},
		default = "default",
	},
	
	{
		name = "difficulty",
		label = "Difficulty",
		options =
		{
			{ description = "Easy", data = "easy" },
			{ description = "Default", data = "default" },
			{ description = "Farmer", data = "hard" },
		},
		default = "default",
	},
	
	{
		name = "inspect",
		label = "Inspectable Shadow Creatures",
		options = 
		{
			{ description = "true", data = true },
			{ description = "false", data = false },
		},
		default = true,
	}
}