require "util"
local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"

local text_font = UIFONT

StatScreen = Class(Screen, function(self, inst_entity)
	Widget._ctor(self, "statscreen")

	self.active = true
	SetPause(true, "pause")
	
		--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.5,1.2,1.2)
	
	

end)


function StatScreen:OnUpdate(dt)
	self.hover:Update()
	self.inv:Update(dt)
end


function StatScreen:OnBecomeActive()
	StatScreen._base.OnBecomeActive(self)
	-- Hide the topfade, it'll obscure the pause menu if paused during fade. Fade-out will re-enable it
	TheFrontEnd:HideTopFade()
end

return StatScreen