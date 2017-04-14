local idir = "images/stat_screens/"
local Widget = require "widgets/widget"

local StatusBar = Class(Widget, function(self)
	Widget._ctor(self, "StatusBadge")
	self.owner = GetPlayer()
	self:SetScale(1,1,1)

	self.bg = self:AddChild(Image(idir.."bar.xml", "bar.tex"))
	self.bg:SetClickable(false)
	self.bg:MoveToBack()
	
	self.bar = self:AddChild(Image(idir.."whitebar.xml", "whitebar.tex"))
	self.bar:SetClickable(false)
	
	self.text = self:AddChild(Text(BODYTEXTFONT, 33))
	self.text:SetHAlign(ANCHOR_MIDDLE)
	self.text:SetClickable(false)
	self.text:MoveToFront() 
end)

function StatusBar:OnUpdate(dt)
	self.text:SetString(tostring())
end

return StatusBar
--[[
뱃지 합치기, HHSP 패널 각각 만들기
뒷배경 2개 만들기, 활성화 비활성화용 텍스트 
]]