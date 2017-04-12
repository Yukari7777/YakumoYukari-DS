require "prefabs/tunnel"

local scheme_manager = Class(function(self, inst)
    self.inst = inst
	self.isb = false
	self.islinked = false
	self.gate_a = nil
	self.gate_b = nil
end)


function scheme_manager:InitGate(inst)

	self = GetWorld().components.scheme_manager
	
	local function SchemeConnect()
		self.gate_a.components.schemeteleport:Target(self.gate_b)
		self.gate_b.components.schemeteleport:Target(self.gate_a)
	end

	if self.islinked then
		if self.isb == false then
			self.gate_a:Remove()
			self.gate_a = inst
			self.isb = true
			SchemeConnect()
		else
			self.gate_b:Remove()
			self.gate_b = inst
			self.isb = false
			SchemeConnect()
		end
	else
		if self.isb == false then
			self.gate_a = inst
			self.isb = true
		else
			self.gate_b = inst
			self.isb = false
			self.islinked = true
			SchemeConnect()
		end	
	end
	
end

return scheme_manager