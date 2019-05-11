local STRINGS = GLOBAL.STRINGS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local Action = GLOBAL.Action

local YTELE = Action({}, 10, nil, true, 14)
YTELE.id = "YTELE"
YTELE.str = STRINGS.ACTION_YTELE
YTELE.fn = function(act)
	if act.invobject then
		if act.invobject.components.makegate then
			return act.invobject.components.makegate:Teleport(act.pos, act.doer)
		elseif act.invobject.components.spellcard then
			return act.invobject.components.spellcard:Teleport(act.pos, act.doer)
		end
	end
end
AddAction(YTELE)

local CASTTOHO = Action({}, -1, nil, true)
CASTTOHO.id = "CASTTOHO"
CASTTOHO.str = STRINGS.ACTION_CASTTOHO
CASTTOHO.fn = function(act)
	local item = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if item and item.components.spellcard ~= nil then
		item.components.spellcard:CastSpell(act.doer, act.target)
		return true
	end
end
AddAction(CASTTOHO)

local CASTTOHOH = Action({}, -1, nil, true)
CASTTOHOH.id = "CASTTOHOH"
CASTTOHOH.str = STRINGS.ACTION_CASTTOHOH
CASTTOHOH.fn = function(act)
	local item = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if item and item.components.spellcard ~= nil then
		item.components.spellcard:CastSpell(act.doer, act.target)
		return true
	end
end
AddAction(CASTTOHOH)