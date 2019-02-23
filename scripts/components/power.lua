local Power = Class(function(self, inst)
    self.inst = inst
    self.max = 75
    self.current = 50

	self.rate = 0
	self.ratescale = RATE_SCALE.NEUTRAL
	
	self.inst:ListenForEvent("respawn", function(inst) self:OnRespawn() end)
	self.inst:StartUpdatingComponent(self)
	
end)

function Power:SetModifier(key, value)
    if value == nil or value == 0 then
        return self:RemoveModifier(key)
    elseif self._modifiers == nil then
        self._modifiers = { [key] = value }
        self.rate = value
        return 
    end
    local m = self._modifiers[key]
    if m == value then
        return 
    end
    self._modifiers[key] = value
    self.rate = self.rate + value - (m or 0)
end

function Power:RemoveModifier(key)
    if self._modifiers == nil then
        return 
    end
    local m = self._modifiers[key]
    if m == nil then
        return 
    end
    self._modifiers[key] = nil
    if next(self._modifiers) == nil then
        self._modifiers = nil
        self.rate = 0
    else
        self.rate = self.rate - m
    end
end

function Power:OnRespawn()
	self.current = 75
end

function Power:OnSave()
	return {power = self.current}
end

function Power:OnLoad(data)
    if data.power then
        self.current = data.power
        self:DoDelta(0)
    end
end

function Power:LongUpdate(dt)
	self:DoDec(dt, true)
end

function Power:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max, self.ratescale)
end

function Power:SetMax(amount)
    self.max = amount
end

function Power:DoDelta(delta, overtime)
    local old = self.current
	self.current = self.current + delta
    if self.current < 0 then 
        self.current = 0
    elseif self.current > self.max then
        self.current = self.max
    end
	
    self.inst:PushEvent("powerdelta", {oldpercent = old/self.max, newpercent = self.current/self.max, overtime = overtime})
end

function Power:GetPercent()
    return self.current / self.max
end

function Power:GetCurrent()
	return self.current
end

function Power:SetPercent(p)
    local old = self.current
    self.current = p * self.max
    self.inst:PushEvent("powerdelta", {oldpercent = old/self.max, newpercent = p})
end

function Power:GetRateScale()
	return self.ratescale
end

function Power:RecalcRateScale()
	self.ratescale =
		(self.rate <= -2 and RATE_SCALE.DECREASE_HIGH) or
        (self.rate <= -1 and RATE_SCALE.DECREASE_MED) or
        (self.rate < 0 and RATE_SCALE.DECREASE_LOW) or
		(self.current == self.max and RATE_SCALE.NEUTRAL) or
        (self.rate >= .2 and RATE_SCALE.INCREASE_HIGH) or
        (self.rate >= .13 and RATE_SCALE.INCREASE_MED) or
        (self.rate > 0 and RATE_SCALE.INCREASE_LOW) or
        RATE_SCALE.NEUTRAL
end

function Power:OnUpdate(dt)
	self:RecalcRateScale()
	self:DoDelta(self.rate * dt, true)
end

Power.LongUpdate = Power.OnUpdate

return Power