local require = GLOBAL.require
local KnownModIndex = GLOBAL.KnownModIndex
local Text = require "widgets/text"
local Image = require "widgets/image"
local NUMBERFONT = GLOBAL.NUMBERFONT

local function GetModName(modname) -- modinfo's modname and internal modname is different.
	for _, knownmodname in ipairs(KnownModIndex:GetModsToLoad()) do
		if KnownModIndex:GetModInfo(knownmodname).name == modname  then
			return knownmodname
		end
	end
end

local function GetModOptionValue(knownmodname, known_option_name)
	local modinfo = KnownModIndex:GetModInfo(knownmodname)
	for _,option in pairs(modinfo.configuration_options) do
		if option.name == known_option_name then
			return option.saved
		end
	end
end

local function StatusDisplaysInit(self)
	if self.owner:HasTag("yakumoyukari") then
		local YokaiBadge = require "widgets/yokaibadge"

		self.combinedmod = GetModName("Combined Status")

		self.power = self:AddChild(YokaiBadge(self.owner))
		if self.combinedmod ~= nil then
			self.brain:SetPosition(0, 35, 0)
			self.stomach:SetPosition(-62, 35, 0)
			self.heart:SetPosition(62, 35, 0)

			self.power:SetScale(.9,.9,.9)
			self.power:SetPosition(-62, -50, 0)
			self.power.combinedmod = true
			self.power.showmaxonnumbers = GetModOptionValue(self.combinedmod, "SHOWMAXONNUMBERS")

			self.power.bg = self.power:AddChild(Image("images/status_bgs.xml", "status_bgs.tex"))
			self.power.bg:SetScale(.4,.43,0)
			self.power.bg:SetPosition(-.5, -40, 0)
		
			self.power.num:SetFont(NUMBERFONT)
			self.power.num:SetSize(28)
			self.power.num:SetPosition(3.5, -40.5, 0)
			self.power.num:SetScale(1,.78,1)

			self.power.num:MoveToFront()
			self.power.num:Show()

			self.power.maxnum = self.power:AddChild(Text(NUMBERFONT, self.power.showmaxonnumbers and 25 or 33))
			self.power.maxnum:SetPosition(6, 0, 0)
			self.power.maxnum:MoveToFront()
			self.power.maxnum:Hide()
		else
			self.power:SetPosition(-40, -50,0)
			self.brain:SetPosition(40, -50, 0)
			self.stomach:SetPosition(-40,17,0)
		end
		
		self.inst:ListenForEvent("powerdelta", function(inst, data) self.power:SetPercent(data.newpercent, self.owner.components.power.max) end, self.owner)
	end
end

AddClassPostConstruct("widgets/statusdisplays", StatusDisplaysInit)