local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local yokaibadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "health", owner)
	self.anim:GetAnimState():SetBuild("ypower")
	self.owner = owner

	self.powerarrow = self.underNumber:AddChild(UIAnim())
	self.powerarrow:SetPosition(0, -1, 0)
    self.powerarrow:GetAnimState():SetBank("sanity_arrow")
    self.powerarrow:GetAnimState():SetBuild("sanity_arrow")
    self.powerarrow:GetAnimState():PlayAnimation("neutral")
    self.powerarrow:SetClickable(false)

	self:StartUpdating()
end)

function yokaibadge:OnGainFocus()
	Badge._base:OnGainFocus(self)
	if self.combinedmod then
		self.maxnum:Show()
	else
		self.num:Show()
	end
end
	
function yokaibadge:OnLoseFocus()
	Badge._base:OnLoseFocus(self)
	if self.combinedmod then
		self.maxnum:Hide()
		self.num:Show()
	else
		self.num:Hide()
	end
end

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function yokaibadge:OnUpdate(dt)
	local power = self.owner.components.power
	local ratescale = power:GetRateScale()
	local maxpower = power.max
	local anim = RATE_SCALE_ANIM[ratescale] or "neutral"

	if self.arrowdir ~= anim then	
        self.arrowdir = anim
        self.powerarrow:GetAnimState():PlayAnimation(anim, true)
    end

	if self.owner ~= nil then
		self.num:SetString(tostring(math.floor(ratescale)))
		if self.combinedmod then
			local maxtxt = self.showmaxonnumbers and "Max:\n" or ""

			self.maxnum:SetString(maxtxt..tostring(math.floor(maxpower)))
		end
		self:SetPercent(self.owner.replica.power:GetPercent(), maxpower)
	end
end

return yokaibadge