local STRINGS = GLOBAL.STRINGS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local ACTIONS = GLOBAL.ACTIONS

----------------------------------------------------------------------------------------------------

local YTELE = AddAction("YTELE", "Teleport", function(act)
	if act.invobject and act.invobject.components.makegate then
		return act.invobject.components.makegate:Teleport(act.pos, act.doer)
	end
end)
YTELE.priority = 10
YTELE.distance = 14
YTELE.rmb = true
YTELE.mount_valid = false

---------------------------------------------------------------------------------------------------

local CASTTOHO = AddAction("CASTTOHO", "castspell", function(act)
	local item = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if item and item.components.spellcard ~= nil then
		item.components.spellcard:CastSpell(act.doer, act.target)
		return true
	end
end)
CASTTOHO.priority = -1
CASTTOHO.rmb = true
CASTTOHO.mount_valid = false

---------------------------------------------------------------------------------------------------

local CASTTOHOH = AddAction("CASTTOHOH", "castspell", function(act)
	local item = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if item and item.components.spellcard then
		item.components.spellcard:CastSpell(act.doer, act.target)
		return true
	end
end)
CASTTOHOH.priority = -1
CASTTOHOH.rmb = true
CASTTOHOH.mount_valid = false