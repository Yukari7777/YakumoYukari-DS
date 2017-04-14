local schemeteleport = Class(function(self, inst)
    self.inst = inst
	self.target = nil
end)

function schemeteleport:CollectSceneActions(doer, actions) 
	if self.target ~= nil and self.target.components.schemeteleport then
		table.insert(actions, ACTIONS.JUMPIN)
	elseif #actions > 0 then
		table.remove(actions)
	end
end

function schemeteleport:OnActivate(doer)
	if doer:HasTag("player") then
		doer.SoundEmitter:KillSound("wormhole_travel")
		doer.SoundEmitter:PlaySound("tunnel/common/travel")
		doer.components.health:SetInvincible(true)
		doer.components.playercontroller:Enable(false)

		GetPlayer().HUD:Hide()
		TheFrontEnd:SetFadeLevel(1)
		doer:DoTaskInTime(1, function() 
			TheFrontEnd:Fade(true,2)
			GetPlayer().HUD:Show()
		end)
		doer:DoTaskInTime(2, function()
			doer:PushEvent("tunneltravel")
			doer.components.health:SetInvincible(false)
			doer.components.playercontroller:Enable(true)
		end)
	end
end

function schemeteleport:OnActivateOther(other, doer) 
	other.sg:GoToState("open")
end

function schemeteleport:Activate(doer)
	if self.target == nil then
		return
	end
	
	self:OnActivate(doer)
	self:OnActivateOther(self.target, doer)
	
	self:Teleport(doer)

	if doer.components.leader then
		for follower,v in pairs(doer.components.leader.followers) do
			self:Teleport(follower)
		end
	end

	local eyebone = nil

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower)
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower,v in pairs(eyebone.components.leader.followers) do
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then
					for j,item in pairs(follower.components.container.slots) do
						if item.components.leader then
							for follower,v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									self:Teleport(follower)
								end
							end
						end
					end
				end
			end
		end
	end
end

function schemeteleport:Teleport(obj)
	if self.target ~= nil then
		local offset = 2.0
		local angle = math.random()*360
		local target_x, target_y, target_z = self.target.Transform:GetWorldPosition()
		target_x = target_x + math.sin(angle)*offset
		target_z = target_z + math.cos(angle)*offset
		if obj.Physics then
			obj.Physics:Teleport( target_x, target_y, target_z )
		elseif obj.Transform then
			obj.Transform:SetPosition( target_x, target_y, target_z )
		end
	end
end


function schemeteleport:Target(otherschemeteleport)
	self.target = otherschemeteleport
end

return schemeteleport