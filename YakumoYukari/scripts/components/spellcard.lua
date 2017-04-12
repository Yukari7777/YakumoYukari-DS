local spellcard = Class(function(self, inst)
	self.inst = inst
	self.spell = nil
	self.onfinish = nil
	self.othercondition = nil
	
	self.duration = nil
	self.costpower = nil
	self.index = nil
	self.name = nil
	self.level = nil
	self.maxlevel = nil
	
	self.isusableitem = true
	self.canuseonpoint = false
	self.canuseontargets = false
	self.tick = 0
	
	self.action = ACTIONS.CASTTOHO
end)

function spellcard:SetSpellFn(fn)
	self.spell = fn
end

function spellcard:SetOnFinish(fn)
	self.onfinish = fn
end

function spellcard:SetCondition(fn)
	self.othercondition = fn
end

function spellcard:GetLevel(inst, index)
	if index == 1 then
		return inst.health_level
	elseif index == 2 then
		return inst.hunger_level
	elseif index == 3 then
		return inst.sanity_level
	elseif index == 4 then
		return inst.power_level
	end
end

function spellcard:CastSpell(target, pos)
	if self.spell then
		self.spell(self.inst, target, pos)
		
		if self.onfinish then
			self.onfinish(self.inst, target, pos)
		end
	end
end

function spellcard:CanCast(doer, target, pos, inst)

	local hands = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil
	local currentpower = doer.components.power:GetCurrent()
	
	if hands then
		return false
	else
		if self.costpower then
			if currentpower >= self.costpower then else
				return false
			end
		end
	end
	
	if self.othercondition ~= nil then
		return self.othercondition
	end

	return self.spell ~= nil

end

function spellcard:SetAction(act)
	self.action = act
end

function spellcard:CollectInventoryActions(doer, actions)
	if self:CanCast(doer) and self.isusableitem then
		table.insert(actions, self.action)
	end
end

return spellcard