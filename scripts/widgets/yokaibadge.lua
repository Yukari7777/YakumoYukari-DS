local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Stat = require "widgets/statusdisplays"

if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(REIGN_OF_GIANTS) then
	local MoistureMeter = require "widgets/moisturemeter"
end

local function CombindIsModEnabled(name)
	for _, moddir in ipairs(KnownModIndex:GetModsToLoad()) do
		if KnownModIndex:GetModInfo(moddir).name == "Combined Status"  then
			return true
		end
	end
	return false
end

local yokaibadge = Class(Widget, function(self, owner)
	Widget._ctor(self, "yokaibadge")
	self.owner = GetPlayer()
	
	self.percent = 0
    self:SetPosition(0,0,0)

    self.active = false

    self.anim = self:AddChild(UIAnim())
	   
	self.anim:GetAnimState():SetBank("health")
	self.anim:GetAnimState():SetBuild("sprint")
	
	self.anim:SetClickable(true)

	self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")
	
	self.arrow = self.anim:AddChild(UIAnim())
	self.arrow:GetAnimState():SetBank("sanity_arrow")
	self.arrow:GetAnimState():SetBuild("sanity_arrow")
	self.arrow:GetAnimState():PlayAnimation("neutral")
	self.arrow:SetClickable(false)
	
    self.underNumber = self:AddChild(Widget("undernumber"))

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(5, 0, 0)
	
	self.num:SetClickable(false)
	
    self.num:Hide()
	if CombindIsModEnabled("Combined Status") then
		self.bg = self:AddChild(Image("images/status_bgs.xml", "status_bgs.tex"))
		self.bg:SetScale(.4,.43,0)
		self.bg:SetPosition(-.5, -40, 0)
		
		self.num:SetFont(NUMBERFONT)
		self.num:SetSize(28)
		self.num:SetPosition(3.5, -40.5, 0)
		self.num:SetScale(1,.78,1)

		self.num:MoveToFront()
		self.num:Show()

		self.maxnum = self:AddChild(Text(NUMBERFONT, 33))
		self.maxnum:SetPosition(6, 0, 0)
		self.maxnum:MoveToFront()
		self.maxnum:Hide()
	end

	self:StartUpdating()
end)

function yokaibadge:PulseGreen()
    self.pulse:GetAnimState():SetMultColour(0.5,0.25,0.87,0.25)
	self.pulse:GetAnimState():PlayAnimation("pulse")
end

function yokaibadge:SetPercent(val, max)
	self.owner = GetPlayer()	
    val = val or self.percent
	
	self.power = self.owner.components.power.current
	self.power_m = self.owner.components.power.max
    self.anim:GetAnimState():SetPercent("anim", 1 - self.power/self.power_m)
            
    self.percent = val
end

function yokaibadge:OnGainFocus()
	if CombindIsModEnabled("Combined Status") then
		self.maxnum:Show()
	else
		yokaibadge._base:OnGainFocus(self)
		self.num:Show()
	end
end

function yokaibadge:OnLoseFocus()
	if CombindIsModEnabled("Combined Status") then
		self.maxnum:Hide()
		self.num:Show()
	else
		yokaibadge._base:OnLoseFocus(self)
		self.num:Hide()
	end
end


function yokaibadge:OnUpdate(dt)
	
	self.num:SetString(tostring(math.floor(self.owner.components.power.current)))
	if CombindIsModEnabled("Combined Status") then
		self.maxnum:SetString(tostring(math.floor(self.owner.components.power.max)))
	end
	
end

return yokaibadge