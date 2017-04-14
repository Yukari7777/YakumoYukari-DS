local require = GLOBAL.require
local TUNING = GLOBAL.TUNING
local GetPlayer = GLOBAL.GetPlayer

local YokaiBadge = require "widgets/yokaibadge"

table.insert(Assets, Asset("ANIM", "anim/power.zip"))

local function CombindIsModEnabled(name)
	for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
		if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Combined Status"  then
			return true
		end
	end
	return false
end

local function StatusDisplaysInit(class)

	if GetPlayer().components.power then
	 
		class.power = class:AddChild(YokaiBadge(class.owner))
		-- /////// TEMP Support, only works with default settings. ///////
		if CombindIsModEnabled("Combined Status") then
			class.brain:SetPosition(0, 35, 0)
			class.stomach:SetPosition(-62, 35, 0)
			class.heart:SetPosition(62, 35, 0)
			class.power:SetScale(.9,.9,.9)
			class.power:SetPosition(-62, -50, 0)
		else
			if class.moisturemeter then -- it also checks dlc
				class.power:SetPosition(-40, -50,0)
				class.brain:SetPosition(40, -50, 0)
				class.stomach:SetPosition(-40,17,0) -- default by (-40, 20, 0). Because my youkaibadge's height is little shorter than other badges.
			elseif not class.moisturemeter.moisture then
				class.power:SetPosition(0,-105,0) -- where the moisture widget was.
			end
		end

		
		class.power.anim:GetAnimState():SetBank("health")
		class.power.anim:GetAnimState():SetBuild("sprint")
		class.power:SetPercent(class.owner.components.power:GetPercent(), class.owner.components.power.max)
			
		class.inst:ListenForEvent("powerdelta", function(inst, data) 
			class.power:SetPercent(data.newpercent, class.owner.components.power.max)
		end, class.owner)
			
	end
	
end

AddClassPostConstruct("widgets/statusdisplays", StatusDisplaysInit)
