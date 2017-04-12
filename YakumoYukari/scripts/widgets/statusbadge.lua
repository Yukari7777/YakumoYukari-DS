local mdir = "inventoryimages"
local rdir = mdir.."/"
local idir = "images/"..rdir
local Widget = require "widgets/widget"

local StatusBadge = Class(Widget, function(self, imagexml, imagetex, name)
	Widget._ctor(self, "StatusBadge")
	self.owner = GetPlayer()
	self:SetScale(1,1,1)

	self.text = self:AddChild(Text(BODYTEXTFONT, 33))
    self.text:SetPosition(5, 0, 0)
	self.text:SetString(name)
	self.text:SetClickable(false)
	self.text:MoveToFront() 
	
	self.icon = self:AddChild(Image(imagexml..".xml", imagetex..".tex"))
	self.icon:SetScale(1,1,1)
end)

function StatusBadge:OnGainFocus()
	StatusBadge._base:OnGainFocus(self)
	self.text:Show()
end

function StatusBadge:OnLoseFocus()
	StatusBadge._base:OnLoseFocus(self)
	self.text:Hide()
end

return StatusBadge